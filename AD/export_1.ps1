
$file = import-csv C:\Temp\salmo07\UsersList.csv

#The file that we are specifying above is the file which contains 2 columns. PMFKeyold and PMFKeynew

$data=@()
$count=0

foreach ($mailbox in $file)
{
     $old_mailbox = get-mailbox $mailbox.PMFKeyold
     $exportname=$mailbox.PMFKeyold+"_export"

     $ExportStatistics=Get-MailboxExportRequest -name $exportname | get-mailboxImportrequeststatistics
    
     $status=New-Object -TypeName PSObject -Property @{
                                PMFKeyold=$mailbox.PMFKeyold
                                PMFKeynew=$mailbox.PMFKeynew
                                ExportStatus="started"
                                
      } 


     $data=$data+$status
     $count=$count+1
     "$count is the number of export requests placed"
}

$data|Export-Csv C:\Temp\List.csv
