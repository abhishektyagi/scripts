#!/bin/bash


logFileName=/var/log/flipkart/erp/fk-crm-excalibur/excalibur.log

mailTo=deepanshu.saxena@flipkart.com
subject="Count for No Free Slot "$yesterday

reportFilesDir=/home/deepanshu.saxena/scripts/daily_report_Files/
ExceptionReportFileName=$reportFilesDir/daily-count.txt


mkdir -p $reportFilesDir

rm  $ExceptionReportFileName

ssh deepanshu.saxena@crm-excalibur-prod-0001.nm.flipkart.com 'grep "No free slot" '"$logFileName"' | wc -l'  >> $ExceptionReportFileName
echo "done 1-"
ssh deepanshu.saxena@crm-excalibur-prod-0002.nm.flipkart.com 'grep "No free slot" '"$logFileName"' | wc -l'  >> $ExceptionReportFileName
echo "done 2-"
ssh deepanshu.saxena@crm-excalibur-prod-0003.nm.flipkart.com 'grep "No free slot" '"$logFileName"' | wc -l'  >> $ExceptionReportFileName
echo "done 3-"
ssh deepanshu.saxena@crm-excalibur-prod-0004.nm.flipkart.com 'grep "No free slot" '"$logFileName"' | wc -l'  >> $ExceptionReportFileName
echo "done 4-"


while read p; do
  echo $p
done <$ExceptionReportFileName

count=`awk '{s+=$1} END {print s}' $ExceptionReportFileName`

echo $count

echo "" > $ExceptionReportFileName

/usr/bin/mutt -s "Number of customers who were not able to see the Call Me Back button on website/app" deepanshu.saxena@flipkart.com << mail
Total Number is : $count
mail





