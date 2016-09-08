#!/bin/bash
yesterday=$(date --date=yesterday +"%Y-%m-%d")
echo $yesterday

function check_file()
{

        for z in /var/log/flipkart/erp/smartchk/fetch/$yesterday/*.xml; do
        if [ -s $z ]
        then
          echo "$z File has Data"
        else
          echo "$z file is empty moving to other directory"
          mv $z /var/log/flipkart/erp/smartchk/fetch/smartchck_empty_files
        fi
        done

}

check_file
