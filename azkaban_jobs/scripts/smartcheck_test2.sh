#!/bin/bash
#yesterday=$(date --date=yesterday +"%Y-%m-%d")
yesterday=$(date --date="2 Days ago" +"%Y-%m-%d")
echo $yesterday
COUNTER=0

function check_file()
{

        for z in /home/deepanshu.saxena/scripts/$yesterday/*.xml; do
        if [ -s $z ]
        then
          echo "$z File has Data"
        else
          echo "$z file is empty moving to other directory"
          echo " $COUNTER "
          COUNTER=$[$COUNTER +1]
          mv $z /home/deepanshu.saxena/scripts/smartchck_empty_files
        fi
        done

}

check_file

echo " Sending mail "

if [[ "$COUNTER" -gt 0 ]];
then
echo "$COUNTER "
/usr/bin/mutt -s "Alert: Smart Check Mail" deepanshu.saxena@flipkart.com<< mail
No. Of SmartCheck Files Empty are : $COUNTER
mail

else
echo " No Empty Files "

/usr/bin/mutt -s "Smart Check Mail" deepanshu.saxena@flipkart.com<< mail
Smart check Script Run successfully.All Files are uploaded.
mail

fi


