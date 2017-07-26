

Function CreateAWSProfile($AccessKey,$SecretKey,$ProfileName) {

    Set-AWSCredentials -AccessKey $AccessKey -SecretKey $SecretKey -StoreAs $ProfileName

}
#CreateAWSProfile("ouraccesskey","oursecureKey","MyProfile"); #Use this to call the function if included





#Initalise Region


Function IntitialzeRegion($ProfileName,$Region) {

    Initialize-AWSDefaults -ProfileName $ProfileName -Region $Region

}
#IntitializeRegion("myprofilename","Region"); #Use this to call the funtion Change Region. 




