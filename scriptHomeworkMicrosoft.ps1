<# 
.SYNOPSIS 
   Copy blob from the current subscription to a different subscription. 
.DESCRIPTION 
   Start's an asynchronous copy of blob to a different subscription and storage account. 
.EXAMPLE 
   .\azure blob copy.ps1  
         -azureSubscription "Azure Subscription"  
         -srcUri "Source blob"  
         -srcStorageAccount "Source Storage Account name" 
         -srcStorageKey "Source Storage Account Key" 
         -destStorageAccount "Target Storage Account name" 
         -destStorageKey "Target Storage Account Key" 
#> 
param  
( 
    [Parameter(Mandatory = $true)] 
    [String]$azureSubscription, 
    
    [Parameter(Mandatory = $true)] 
    [String]$srcUri, 
 
    [Parameter(Mandatory = $true)] 
    [String]$srcStorageAccount, 
 
    [Parameter(Mandatory = $true)] 
    [String]$srcStorageKey,

    [Parameter(Mandatory = $true)] 
    [String]$destStorageAccount, 
 
    [Parameter(Mandatory = $true)] 
    [String]$destStorageKey
    
)
 

Select-AzureSubscription $azureSubscription 

 
### Create the source storage account context ### 
$srcContext = New-AzureStorageContext  -StorageAccountName $srcStorageAccount `
                                        -StorageAccountKey $srcStorageKey  
 
### Create the destination storage account context ### 
$destContext = New-AzureStorageContext  -StorageAccountName $destStorageAccount `
                                        -StorageAccountKey $destStorageKey  
 
### Destination Container Name ### 
$containerName = "testf"
 
### Create the container on the destination ### 
New-AzureStorageContainer -Name $containerName -Context $destContext 
 
### Start the asynchronous copy - specify the source authentication with -SrcContext ### 
$blob1 = Start-AzureStorageBlobCopy -srcUri $srcUri `
                                    -SrcContext $srcContext `
                                    -DestContainer $containerName `
                                    -DestBlob "NEW BLOB NAME.FORMAT" `
                                    -DestContext $destContext
									

### Retrieve the current status of the copy operation ###
$status = $blob1 | Get-AzureStorageBlobCopyState 
 
### Print out status ### 
$status 
 
### Loop until complete ###                                    
While($status.Status -eq "Pending"){
  $status = $blob1 | Get-AzureStorageBlobCopyState 
  Start-Sleep 10
  ### display the formatted status information 
  (Get-Date).ToString() + ":" + ( "{0: P0}"  -f ( $status.BytesCopied / $status.TotalBytes))
  ### Print out status ###
  $status
}

"Azure Copy Successfully Complete!"
$status
