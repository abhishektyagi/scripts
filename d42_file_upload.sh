#!/bin/bash
#Simple script to upload logs to D42 using s3cmd
#Pass a list of logs in a file which you need to backup in D42 and remove from the machine
#
filename=$1
access_key=`cat ~/.s3cfg | grep ^access_key | awk '{print $3}'`
secret_key=`cat ~/.s3cfg | grep ^secret_key | awk '{print $3}'`
endpoint=`cat ~/.s3cfg | grep ^host_base | awk '{print $3}'`

#logLocation=/home/deepanshu.saxena
logLocation=/var/log/flipkart/erp/fk-crm-narsil

echo "Log Location :: $logLocation"

#timestamp=`date +%s_%d_%m_%Y`
host_name=`hostname`

if [ $# -eq 0 ]; then
 echo "Error. Filename argument is required."
 exit 1
fi

#Create bucket
bucket=logbackup_$host_name
create_it=`~/s3cmd/s3cmd -c  ~/.s3cfg mb s3://$bucket`

echo "Bucket created"

echo "creating bz2 zip files"

echo "" > $filename
/usr/bin/find $logLocation/*log* -type f -mtime +7 > $filename

while IFS= read -r line
do
echo "line $line"
echo "creating zip files"

bzip2 $line

done < "$filename"

echo "" > $filename

/usr/bin/find $logLocation/*log* -type f -mtime +7 > $filename

 
#Check for bzip2 type, upload and remove from local
for file in `cat $filename`; do
    if file $file | grep -q bzip2; then
        key=$(basename $file)
        upload_it=`~/s3cmd/s3cmd -c ~/.s3cfg put $file s3://$bucket`
        echo "uploaded $file"
        r_checksum=`~/s3cmd/s3cmd -c ~/.s3cfg info s3://$bucket/$key | grep "MD5 sum" | awk '{print \$3}'`
        l_checksum=`md5sum $file | awk '{print $1}'`
        if [ "$r_checksum" = "$l_checksum" ]; then 
            echo "Uploaded $file to Bucket $bucket. Removing local copy."
            `/bin/rm -f $file`
        fi
        else
        echo "$file - Not Allowed. Only bzip2 allowed"
        fi
done
