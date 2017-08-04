
#Create AWS Profile for connections


Function CreateAWSProfile($AccessKey,$SecretKey,$ProfileName) {

    Set-AWSCredentials -AccessKey $AccessKey -SecretKey $SecretKey -StoreAs $ProfileName

}
#CreateAWSProfile("ouraccesskey","oursecureKey","MyProfile"); #Use this to call the function to create your aws profile connection file





#Initalise Region


Function IntitialzeRegion($ProfileName,$Region) {

    Initialize-AWSDefaults -ProfileName $ProfileName -Region $Region

}
#IntitializeRegion("myprofilename","Region"); #Use this to call the funtion Change Region. 



#Assign a new Tag

Function TagInstance($instanceID,$tag) {
	
    New-EC2Tag -Resource $instanceID -Tag $tag

}
#TagInstance($instanceID,$key,$keyVal)
