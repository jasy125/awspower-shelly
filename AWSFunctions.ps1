
#What Functions are on this page
#1. Install Powershell Tools
#2. Create your AWS Profile Connection file
#3. Select a AWS Region
#4. Assign a new Tag to instance
 
#install AWS PowerShell Tools
Function InstallAWSPowerShell($Path) {
	 if($Path -eq $null) {
	     Install-Package -Name AWSPowerShell
	  } else {
		Install-Package -Name AWSPowerShell -Path $Path
	     }
}
#InstallAWSPowerShell($Path);
 
 
 
#Create AWS Profile for connections
Function CreateAWSProfile($AccessKey,$SecretKey,$ProfileName) {
    Set-AWSCredentials -AccessKey $AccessKey -SecretKey $SecretKey -StoreAs $ProfileName;
}
#CreateAWSProfile($AccessKey,$SecretKey,$ProfileName); #Use this to call the function to create your aws profile connection file


#Initalise Region
Function IntitialzeRegion($ProfileName,$Region) {
    Initialize-AWSDefaults -ProfileName $ProfileName -Region $Region
}
#IntitializeRegion($ProfileName,$Region); #Use this to call the funtion Change Region. 


#Assign a new Tag
Function TagInstance($instanceID,$tag) {
    New-EC2Tag -Resource $instanceID -Tag $tag
}
#TagInstance($instanceID,$key,$keyVal)
