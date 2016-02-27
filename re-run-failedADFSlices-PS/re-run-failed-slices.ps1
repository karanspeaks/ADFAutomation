Login-AzureRmAccount
$slices= @()
$tableName=@()
$failedSlices= @()
$failedSlicesCount= @()
$tableNames=@()

$Subscription="Provide Subscription ID"  
  
  Select-AzureRMSubscription -SubscriptionId  $Subscription    
$DataFactoryName="Provide Data Factory Name"
$resourceGroupName ="Porvide Resource Group Name for Data Factory"
  
$startDateTime ="2015-05-01" #Start Date for Slices
$endDateTime="2015-08-01" # End Date for Slices


#Get Dataset names in Data Factory - you can exlicitly give a table name using $tableName variable if you like to run only for an individual tablename
$tableNames = Get-AzureRMDataFactoryDataset -DataFactoryName $DataFactoryName -ResourceGroupName $resourceGroupName | ForEach {$_.DatasetName}

$tableNames #lists tablenames

foreach ($tableName in $tableNames)
{
	$slices += Get-AzureRMDataFactorySlice -DataFactoryName $DataFactoryName -DatasetName $tableName -StartDateTime $startDateTime -EndDateTime $endDateTime -ResourceGroupName $resourceGroupName -ErrorAction Stop
}


$failedSlices = $slices | Where {$_.State -eq 'Failed'}

$failedSlicesCount = @($failedSlices).Count

if ( $failedSlicesCount -gt 0 ) 
{

	write-host "Total number of slices Failed:$failedSlicesCount"
	$Prompt = Read-host "Do you want to Rerun these failed slices? (Y | N)" 
	if ( $Prompt -eq "Y" -Or $Prompt -eq "y" )
	{

		foreach ($failed in $failedSlices)
		{
   			write-host "Rerunning slice of Dataset "$($failed.DatasetName)" with StartDateTime "$($failed.Start)" and EndDateTime "$($failed.End)"" 
			Set-AzureRMDataFactorySliceStatus -UpdateType UpstreamInPipeline -Status Waiting -DataFactoryName $($failed.DataFactoryName) -DatasetName $($failed.DatasetName) -ResourceGroupName $resourceGroupName -StartDateTime "$($failed.Start)" -EndDateTime "$($failed.End)" 
           

		}
	}
    		
}
else
{
	write-host "There are no Failed slices in the given time period."
}





