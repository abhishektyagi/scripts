#!/bin/bash
#yesterday=$(date --date=yesterday +"%Y-%m-%d")
yesterday=$(date --date="2 Days ago" +"%Y-%m-%d")
echo $yesterday
COUNTER=0

function check_file()
{

        for z in /var/log/flipkart/erp/smartchk/fetch/$yesterday/*.xml; do
        if [ -s $z ]
        then
          echo "$z File has Data"
        else
          echo "$z file is empty moving to other directory"
          echo " $COUNTER "
          COUNTER=$[$COUNTER +1]
          mv $z /var/log/flipkart/erp/smartchk/fetch/smartchck_empty_files
        fi
        done

}

check_file


PATH=SmartCheck
dirPath=$yesterday

echo $PATH
echo $dirPath

USER='ftp_user_39'
PASSWD='flipkart@123'
HOST='10.65.90.39'

echo $USER
echo $PASSWD
echo $HOST

dirUploadPath=/$PATH/$yesterday

/usr/bin/ftp -n  $HOST << END_SCRIPT
quote USER $USER
quote PASS $PASSWD
cd /$PATH
ls
lcd /var/log/flipkart/erp/smartchk/fetch/$yesterday
lcd
prompt
mput *
ls
quit
END_SCRIPT

echo "Sending mail "

if [[ "$COUNTER" -gt 0 ]];
then
echo "$COUNTER "

/usr/bin/mutt -s "Alert: Smart Check Mail" deepanshu.saxena@flipkart.com,vivek.baskaran@flipkart.com,kaushik.mishra@flipkart.com << mail
No. Of File Empty is : $COUNTER
mail

else
echo " No Empty Files "

/usr/bin/mutt -s "Smart Check Mail" deepanshu.saxena@flipkart.com<< mail
Smart check Script Run successfully.All Files are uploaded.
mail

fi

