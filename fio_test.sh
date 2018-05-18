#!/bin/bash

#Description:fio tools test disk io performance
#Author     :song.w
#Date       :2018-5-15
set -x
DATES=$(date "+%Y-%m-%d")
WORKDIR="/opt/fiotest"
file="/dev/vdd"
writemode="randwrite write"
readmode="randread read"
rwmode="randrw rw"
list="4K 8K 64K 512K 1M 4M"
fsize="20G"
runtime=120
#rwmixwrite set mix mode write ratio 40%
rwmixwrite=40
result="resultlog allw_result allr_result allrw_result"

work_dir()
{
    if [ -d "${WORKDIR}" ];
    then
        echo "${WORKDIR} already exist"
    else
    	mkdir -p ${WORKDIR}
    	echo "${WORKDIR} created"
    fi

for f in ${result};do
    if [ -d "${WORKDIR}"/"${f}" ];
    then
        echo "${WORKDIR}/${f}  already exist"
    else
    	mkdir -p ${WORKDIR}/${f}
    	echo "${f} created"
    fi 
done
    	
}

check_disk()
{
	
	if [ $# -lt 1 ] 
    then 
        echo -e "Warning:The script must have one parameters."
        echo "#########################################################################"
        echo "Usage: sh $0 device_info" 
        echo  -e "Example: sh $0 /dev/vdd"
        echo "#########################################################################"
        echo "Available disk list:"
        lsblk|grep disk
        echo "Warning:Don't select the system disk"
        exit 1
    else
        echo "The ${1} device will testing"    
   fi  
}

Write()
{
# Random or Seq Write
for n in ${writemode};do

    for i in ${list};do

        if [ -d "${WORKDIR}/${i}B_${n}_test" ]; then
	    	echo "${WORKDIR}/${i}B_${n}_test already exist"
        else
            mkdir -p ${WORKDIR}/${i}B_${n}_test 	
        fi
        cd ${WORKDIR}/${i}B_${n}_test

        fio -ioengine=libaio -bs=${i} -direct=1 -thread -rw=${n} -size=${fsize} -filename=${file} -name="${i}B_${n}_test" -iodepth=2 -runtime=${runtime} --output=${WORKDIR}/${i}B_${n}_test/${i}B_${n}_test.${DATES} -write_bw_log=${i}B_${n}_test -write_lat_log=${i}B_${n}_test -write_iops_log=${i}B_${n}_test --bandwidth-log -group_reporting

        sleep 3
        cp ${WORKDIR}/${i}B_${n}_test/${i}B_${n}_test.${DATES} ${WORKDIR}/resultlog/


        for j in clat lat slat bw iops;do 
            mv ${i}B_${n}_test_$j.1.log ${i}B_${n}_test_$j.log;
            cp ${i}B_${n}_test_$j.log ${WORKDIR}/allw_result/
        done

        #Result to Draw
        #Drawresult
    done
done    
}

Read()
{
# Random or Seq Read
for n in ${readmode};do

    for i in ${list};do

        if [ -d "${WORKDIR}/${i}B_${n}_test" ]; then
	    	echo "${WORKDIR}/${i}B_${n}_test already exist"
        else
            mkdir -p ${WORKDIR}/${i}B_${n}_test 	
        fi
        cd ${WORKDIR}/${i}B_${n}_test

        fio -ioengine=libaio -bs=${i} -direct=1 -thread -rw=${n} -size=${fsize} -filename=${file} -name="${i}B_${n}_test" -iodepth=2 -runtime=${runtime} --output=${WORKDIR}/${i}B_${n}_test/${i}B_${n}_test.${DATES} -write_bw_log=${i}B_${n}_test -write_lat_log=${i}B_${n}_test -write_iops_log=${i}B_${n}_test --bandwidth-log -group_reporting 

        sleep 3
        cp ${WORKDIR}/${i}B_${n}_test/${i}B_${n}_test.${DATES} ${WORKDIR}/resultlog/

        for j in clat lat slat bw iops;do 
            mv ${i}B_${n}_test_$j.1.log ${i}B_${n}_test_$j.log;
            cp ${i}B_${n}_test_$j.log ${WORKDIR}/allr_result/
        done
        #Result to Draw
        #Drawresult
    done
done    
}


Mixrw()
{
# Random or Seq Read and Write
for n in ${rwmode};do

    for i in ${list};do

        if [ -d "${WORKDIR}/${i}B_${n}_test" ]; then
	    	echo "${WORKDIR}/${i}B_${n}_test already exist"
        else
            mkdir -p ${WORKDIR}/${i}B_${n}_test 	
        fi
        cd ${WORKDIR}/${i}B_${n}_test

        fio -ioengine=libaio -bs=${i} -direct=1 -thread -rw=${n} -size=${fsize} -rwmixwrite=${rwmixwrite} -filename=${file} -name="${i}B_${n}_test" -iodepth=2 -runtime=${runtime} --output=${WORKDIR}/${i}B_${n}_test/${i}B_${n}_test.${DATES} -write_bw_log=${i}B_${n}_test -write_lat_log=${i}B_${n}_test -write_iops_log=${i}B_${n}_test --bandwidth-log -group_reporting 

        sleep 3
        cp ${WORKDIR}/${i}B_${n}_test/${i}B_${n}_test.${DATES} ${WORKDIR}/resultlog/

        for j in clat lat slat bw iops;do 
           mv ${i}B_${n}_test_$j.1.log ${i}B_${n}_test_$j.log;
           cp ${i}B_${n}_test_$j.log ${WORKDIR}/allrw_result/
        done

        #Result to Draw
        #Drawresult
    done
done    
}

Drawresult()
{
    /usr/bin/which fio2gnuplot
	if [ $? -eq 0 ];then
		echo "Beginning draw result pictures"
        fio2gnuplot -b -g
        fio2gnuplot -i -g
	else
	    echo "fio2gnuplot tools not install,Draw Pic failure"
	    echo "Ubuntu:apt install -y gnuplot"
	    echo "CentOS:yum install -y gnuplot"

	    #exit 1
	fi
}

DrawAll()
{
	for i in $(ls ${WORKDIR});do
		cd ${WORKDIR}/${i}
		#BandWidth
		fio2gnuplot -b -g

		#IOPS
		fio2gnuplot -i -g
	done	
}

main()
{
	
	check_disk $1

	file=$1

	work_dir
	
	Write
	Read
	Mixrw

	DrawAll

}

main $@