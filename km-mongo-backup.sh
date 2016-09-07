#!/bin/bash
today=$(date +"%Y-%m-%d")
#echo $today
user_dir="/var/mongo/backup"
#echo $user_dir

logFile=/var/mongo/backup/km-mongo-info.log
dbFile=/var/mongo/backup/db.log

msg=""

COUNTER=0

backup_archive()
{
      echo "*** In backup_archive $user_dir *** \n" >> $logFile 2>&1
      db_name=$1
      echo "DB Name  $db_name \n" >> $logFile 2>&1
      dir_name=$1_$today
      echo "Dir name $dir_name \n" >> $logFile 2>&1
      echo "$today" >> $logFile 2>&1
      `/usr/share/fk-3p-mongodb-3-0-x/bin/mongodump --host 10.32.5.17 --port 27300 --db $db_name --username kmread --password kmRead123 --out $user_dir/$dir_name` >> $logFile 2>&1
      COUNTER=`echo $?` 
      
      echo "Mongodump command status $COUNTER \n" >> $logFile 2>&1 

	  if [ "$COUNTER" -gt 0 ]
	  then
	  echo " Error Occured $COUNTER \n" >> $logFile 2>&1
	  msg="Error Occured in backup_archive $db_name"
	  onFailSendMail "$msg" "$COUNTER"
	  else
	  echo " No Error in back up \n"  >> $logFile 2>&1
	  fi
         
         echo "Creating Tar File \n"  >> $logFile 2>&1

         while :;do echo -n '#' >> $logFile 2>&1 ;sleep 1;done &
         trap "kill $!" EXIT  #Die with parent if we die prematurely 
     	
	 `tar cjvfP $user_dir/$dir_name.tar.bz2 $user_dir/$dir_name`
         
         kill $! && trap " " EXIT #Kill the loop and unset the trap or else the pid might get reassigned and we might end up killing a completely different process

     	 echo "tar file generated " >> $logFile 2>&1
      	`rm -rf $user_dir/$dir_name`
     	 echo "\n $? Directory Deleted or Not $user_dir/$dir_name \n" >> $logFile 2>&1
       
}

onFailSendMail()
{

    echo "Sending Fail mail $1 and $2  \n" >> $logFile 2>&1
    msg=$1
    val=$2
    echo $val
    # send an email if backup failed
	if [ $val -ge 0 ]
	then
        echo "$msg" | /usr/bin/mail -s "KM Mongo Backup failed" deepanshu.saxena@flipkart.com,k.mukesh@flipkart.com
        echo "faile mail done \n" >> $logFile 2>&1
	else
		 echo "Backup done \n" >> $logFile 2>&1
	fi
        exit 1
}

onSuccessSendMail()
{
    msg=$1
    echo "Sending mail for sucess \n" >> $logFile 2>&1
    echo "DB Name $msg" | /usr/bin/mail -s "KM Mongo Backup Successfull" deepanshu.saxena@flipkart.com,k.mukesh@flipkart.com
   # exit 0	
		
}

dirUploadInD42()
{
                db_name_upload=$1
                fileUpload=$1_$today

		echo "in dirUploadInD42 $fileUpload \n" >> $logFile 2>&1
	        
                echo "file going to upload :: $user_dir/$fileUpload.tar.bz2  \n" >> $logFile 2>&1
        	echo `$user_dir/s3cmd/s3cmd -c  $user_dir/.s3cfg put  $user_dir/$fileUpload.tar.bz2 s3://km-mongo-bucket` >> $logFile 2>&1

	  	COUNTER=`echo $?`
	  	if [ "$COUNTER" -gt 0 ]
	  	then
	  	echo " Error Occured in uplaod $COUNTER \n" >> $logFile 2>&1
	  	msg="Error Occured in uploading the file $db_name_upload"
	  	onFailSendMail "$msg" "$COUNTER"
	  	else
	 	 echo " No Error in upload \n" >> $logFile 2>&1
	  	fi

}

echo $today >> $logFile 2>&1
echo $user_dir >> $logFile 2>&1

while IFS= read -r line
do
echo "$line" >> $logFile 2>&1
backup_archive $line

echo  "Backup and Archive done \n" >> $logFile 2>&1

dirUploadInD42 $line

#onSuccessSendMail $line

done < "$dbFile"

echo " \n Deleting tar files \n " >> $logFile 2>&1

echo `ls -l  /var/mongo/backup/*.bz2` >> $logFile 2>&1

#rm /var/mongo/backup/*.bz2

echo `ls -l  /var/mongo/backup` >> $logFile 2>&1

echo "\n files deleted \n" >> $logFile 2>&1

echo "Back up Completed for the DAY $today" >> $logFile 2>&1

echo "**************** DONE **********************************" >> $logFile 2>&1
