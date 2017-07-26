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
 
                        }
 
               } catch { $out = $server + ",Could not open registry";  }       
 
     } else {
        $out = $server + ",Not online"
        }

  return $out;
  }



Initialize-AWSDefaults -ProfileName "Jason.Stewart" -Region "eu-west-1" #users profile details for aws connect


$tag = New-Object Amazon.EC2.Model.Tag
$tag.Key = "SQL"
$profilename = "your profile name" # This is the profile file which grants access to aws see AWSCreateProfile.ps1


    #List all regions
    $regionStore = Get-AWSRegion

       #loop through the regions
        foreach($region in $regionStore) {

        #Initialize-AWSDefaults -ProfileName $profilename -Region $region.region; #users profile details for aws connect needed for the loop each region
        #get array of all the instances in this region
        $instanceArray = Get-EC2Instance -Region $region.region

       
            #loop thorugh the instance array for the region
             foreach($instance in $instanceArray.Instances) {
               $indexVal = ""; #index value for position within instanceDescriptionsArr
               $instanceID = $instance.InstanceId #current instance ID
               $instanceAMI = $instance.ImageId #current Instance Image AMI
               $instanceName =  $instance.Tags | ? { $_.key -eq "Name" } | select -expand Value; #gets the name of the current instance

                     $version = getSQLVersion("awssqltest"); #detect the version of SQL Server function


                             if($version -eq "$instanceName,Not online" -or $version -eq "$server,Could not open registry") {
                                #Logging
                                write-output "Region : $region - Name :$instanceName - $version" | add-content  C:\scripts\Results\awsTagging.txt #Logging
                             } else {

                                 #tag server
                                 $tag.Value = "$version" #Set the Value
                                     New-EC2Tag -Resource $instanceID -Tag $tag #this will add the tag or overwrite the existing SQL tag value 
                                     #Add to csv output file
                                     write-output "Region : $region - Name :$instanceName - Tags Added: $tag.Values" | add-content  C:\scripts\Results\awsTagging.txt
                               }               

             }
        }