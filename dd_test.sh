#!/bin/bash

#Description:Testing storage node disk raw io performance
#Author     :song.w
#Date       :2018-5-14


#file can be filename or raw disk device
DATES=$(date "+%Y-%m-%d")
file="/dev/vdd"
BS_COUNT_8K=(8K 12K)
BS_COUNT_16K=(16K 8K)
BS_COUNT_64K=(64K 6K)
BS_COUNT_1M=(1M 1K)
BS_COUNT_4M=(4M 1K)
list="8K 16K 64K 1M 4M"
wlog=/tmp/ddwrite.log.${DATES}
rlog=/tmp/ddread.log.${DATES}
#write
Write()
{
        echo "[INFO]WRITE"
        for i in $list;do
                bs=$(eval echo \$\{BS_COUNT_$i\[0\]\})
                count=$(eval echo \$\{BS_COUNT_$i\[1\]\})
                sum=0
                avg=0
                echo "dd if=/dev/zero of=$file conv=fsync oflag=direct bs=$bs count=$count"
                for ((n=1;n<=3;n++));do
                    dd if=/dev/zero of=$file conv=fsync oflag=direct bs=$bs count=$count 2>>$wlog
                    output=$(tail -n1 ${wlog}|cut -d' ' -f8)
                    sum=$(echo ${output}|awk '{print $1+"'$sum'"}')
                    sleep 3
                done
                avg=$(echo ${sum}|awk '{print $1/3}')
                echo "bs=${bs} count=${count} avg WRITE io:${avg} MB/s" >>$wlog
                echo "Write End"
                echo " "
        done
}

#read
Read()
{
        echo "[INFO]READ"
        for i in $list;do
                bs=$(eval echo \$\{BS_COUNT_$i\[0\]\})
                count=$(eval echo \$\{BS_COUNT_$i\[1\]\})
                sum=0
                avg=0
                echo "dd if=$file of=/dev/null iflag=direct bs=$bs count=$count"
                for ((n=1;n<=3;n++));do
                   dd if=$file of=/dev/null iflag=direct bs=$bs count=$count 2>> $rlog
                   output=$(tail -n1 ${rlog}|cut -d' ' -f8)
                   sum=$(echo ${output}|awk '{print $1+"'$sum'"}')
                   sleep 3
                done 
                avg=$(echo ${sum}|awk '{print $1/3}')
                echo "bs=${bs} count=${count} avg READ io:${avg} MB/s" >>$rlog  
                echo "Read End"
                echo " "
        done
}

Write|tee -a $wlog
echo "please wait 5 seconds......"
sleep 5
Read|tee -a $rlog
