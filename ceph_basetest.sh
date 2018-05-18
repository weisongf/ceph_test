#!/bin/bash

#Description:Ceph base performance test.
#Author     :song.w
#Date       :2018-5-14

DATES=$(date "+%Y-%m-%d")
RUNTIME=120
RADOSWLOG=/tmp/radosbench_write.log.${DATES}
RADOSLOG_SR=/tmp/radosbench_seqr.log.${DATES}
RADOSLOG_RR=/tmp/radosbench_randr.log.${DATES}

createpool()
{
	if [ -z $(rados lspools|grep test) ]
    then
        echo "Creating test pool"		
	    ceph osd pool create test 128 128
        ceph osd pool get test size
        ceph osd pool get test pg_num
    else
    	echo "The test pool already exists"
    fi    
}

deletepool()

{
	echo "Removing test pool......"
	ceph osd pool delete test test --yes-i-really-really-mean-it 

}

radosbench_write()
{
	RUNTIME=$1
	echo "Runing rados bench wirte test"
	echo "rados bench -p test ${RUNTIME} write --no-cleanup" >>${RADOSWLOG}
	rados bench -p test ${RUNTIME} write --no-cleanup |tee -a ${RADOSWLOG}
	echo " "
}

radosbench_seqr()
{
	RUNTIME=$1
	#seq read
	#rados bench -p test 10 seq
	echo "Runing rados bench seq read test"
	echo "rados bench -p test ${RUNTIME} seq" >>${RADOSLOG_SR}
	rados bench -p test ${RUNTIME} seq |tee -a ${RADOSLOG_SR}
	echo " "
}

radosbench_randr()
{
	RUNTIME=$1
	#random read
	#rados bench -p test 10 rand
	echo "Runing rados bench random read test"
	echo "rados bench -p test ${RUNTIME} rand" >>${RADOSLOG_RR}
	rados bench -p test ${RUNTIME} rand |tee -a ${RADOSLOG_RR}
	echo " "
}

main()
{

    createpool
    radosbench_write ${RUNTIME}
    radosbench_seqr ${RUNTIME}
    radosbench_randr ${RUNTIME}
    deletepool
}

main $@