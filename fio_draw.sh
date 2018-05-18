#!/bin/bash

#Description:fio tools test disk io performance
#Author     :song.w
#Date       :2018-5-15
set -x
DATES=$(date "+%Y-%m-%d")
WORKDIR="/opt/fiotest"

DrawAll()
{
    /usr/bin/which fio2gnuplot
    if [ $? -eq 0 ];then
        echo "Beginning draw result pictures"
        for i in $(ls ${WORKDIR});do
            cd ${WORKDIR}/${i}
            #BandWidth
            fio2gnuplot -b -g

            #IOPS
            fio2gnuplot -i -g
        done    

    else
        echo "fio2gnuplot tools not install,Draw Pic failure"
        echo "Ubuntu:apt install -y gnuplot"
        echo "CentOS:yum install -y gnuplot"

        exit 1
    fi
	
    
}

main()
{
	
  DrawAll
}

main $@