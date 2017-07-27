Function getSQLVersion($server) {

    $out = $null;

    # Check if computer is online
    if (test-connection -computername $server -count 1 -ea 0 ) {
 
        try {
            # Define SQL instance registry keys
            $type = [Microsoft.Win32.RegistryHive]::LocalMachine;
            $regconnection = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($type, $server) ;
            $instancekey = "SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL";
 
                try {
                    # Open SQL instance registry key
                    $openinstancekey = $regconnection.opensubkey($instancekey);
                } catch {  $out = $server + ",No SQL registry keys found"; }
 
                        # Get installed SQL instance names
                        $instances = $openinstancekey.getvaluenames();
 
                        # Loop through each instance found
                        foreach ($instance in $instances) {
 
                            # Define SQL setup registry keys
                            $instancename = $openinstancekey.getvalue($instance);
                            $instancesetupkey = "SOFTWARE\Microsoft\Microsoft SQL Server\" + $instancename + "\Setup"; 
 
                            # Open SQL setup registry key
                            $openinstancesetupkey = $regconnection.opensubkey($instancesetupkey);
 
                            $edition = $openinstancesetupkey.getvalue("Edition");
 
                            # Get version and convert to readable text
                            $version = $openinstancesetupkey.getvalue("Version");
 
                                switch -wildcard ($version) {
                                    "13*" {$versionname = "SQL Server 2016";}
                                    "12*" {$versionname = "SQL Server 2014";}
                                    "11*" {$versionname = "SQL Server 2012";}
                                    "10.5*" {$versionname = "SQL Server 2008 R2";}
                                    "10.4*" {$versionname = "SQL Server 2008";}
                                    "10.3*" {$versionname = "SQL Server 2008";}
                                    "10.2*" {$versionname = "SQL Server 2008";}
                                    "10.1*" {$versionname = "SQL Server 2008";}
                                    "10.0*" {$versionname = "SQL Server 2008";}
                                    "9*" {$versionname = "SQL Server 2005";}
                                    "8*" {$versionname = "SQL Server 2000";}
                                    default {$versionname = $version;}
                                }
 
                            # Output value for Tag
                            $out =  $versionname + " - " + $edition ; #eg SQL Server 2016 - Express Edition
                            write-host $out
                        return $out;
                        }
 
               } catch { $out = $server + ",Could not open registry";  }       
 
     } else {
        $out = $server + ",Not online"
        }

  return $out;
 }



Initialize-AWSDefaults -ProfileName "profilename" -Region "region" #users profile details for aws connect
#get instances that need new tags ( CSV File or manually enter one )

$instanceIDArr =  import-csv -Path "c:\scripts\instanceIDS.csv"  -header("InstanceID") #headers are InstanceID
$instanceDescriptionsArr =  import-csv -Path "c:\scripts\awsNames.csv" -header("name","edition","license") #headers are name,edition,license


$instanceArrayName = $instanceIDArr.AssetName;

$tag = New-Object Amazon.EC2.Model.Tag
$tag.Key = "SQL"

#get all instances in region and start looping through the array

    #List all regions
    $regionStore = Get-AWSRegion

       #loop through the regions
        foreach($region in $regionStore) {

        Initialize-AWSDefaults -ProfileName "profilename" -Region $region.region; #users profile details for aws connect needed for the loop each region
        #get array of all the instances in this region
        $instanceArray = Get-EC2Instance -Region $region.region

            #loop thorugh the instance array for the region
             foreach($instance in $instanceArray.Instances) {
               $indexVal = ""; #index value for position within instanceDescriptionsArr
               $instanceID = $instance.InstanceId #current instance ID
               $instanceAMI = $instance.ImageId #current Instance Image AMI
               $instanceName =  $instance.Tags | ? { $_.key -eq "Name" } | select -expand Value; #gets the name of the current instance
             
               $instanceNameSub = $instanceName.Substring(0,8);#this may not be required for you this is the name on aws we take only the first 8 characters
               $version = getSQLVersion($instanceNameSub);


                  #if instance is in array then add tag
                  if($instanceIDArr.InstanceID.contains($instanceID)) {
                    #get arrayvalue of what this contains


                    $indexVal = [array]::IndexOf($instanceDescriptionsArr.name, $instanceNameSub)# get the position within the array to be used

                       write-host "name : $instanceName - ID : $instanceID - AMI : $instanceAMI - Postion in array : $indexVal";

                     if($indexVal -ne "-1"){
                        $Edition = $instanceDescriptionsArr[$indexVal].Edition; #get the edition details
                        $License = $instanceDescriptionsArr[$indexVal].License; #get the license details
                     } else {
                        $Edition = "";
                        $License = "Not Found in list";
                        }

                     $tag.Value = "$Edition - $License" #Set the Value
                     
                     if($edition -ne ""){
                       #add tag to the instance
                       #New-EC2Tag -Resource $instanceID -Tag $tag
                       write-host "TAG | $version"
                      }

                     #Add to csv output file
                     write-output "InstanceID :  $instanceID | Region : $region | Name :$instanceName | Tags Added: $Edition - $License" | add-content  C:\scripts\Results\awsTagging.txt
                  } else {

                    #write-host "No Instances Match for $region";
                    write-output "InstanceID :  $instanceID | Region : $region | Name :$instanceName | Not an SQL Instance" | add-content  C:\scripts\Results\awsTagging.txt
                    }
             }
        }
