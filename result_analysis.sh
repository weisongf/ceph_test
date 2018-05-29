#!/bin/bash

cd /opt/fiotest/resultlog
echo "##################randread_test_result Begin##########################"
grep read $(ls|grep B_randread_test)|grep -E 'randread_test|IOPS'|grep -v 'rw='|grep -Ev 'Starting|Disk'|awk -F':' '{print$2$3$4}'
echo "##################randread_test_result End############################"

echo "##################seqread_test_result Begin##########################"
grep read $(ls|grep B_read_test)|grep -E 'read_test|IOPS'|grep -v 'rw='|grep -Ev 'Starting|Disk'|awk -F':' '{print$2$3$4}'
echo "##################seqread_test_result End############################"

echo "##################seqwrite_test_result Begin##########################"
grep write $(ls|grep B_write_test)|grep -E 'write_test|IOPS'|grep -v 'rw='|grep -Ev 'Starting|Disk'|awk -F':' '{print$2$3$4}'
echo "##################seqwrite_test_result End############################"

echo "##################randwrite_test Begin##########################"
grep write $(ls|grep B_randwrite_test)|grep -E 'randwrite_test|IOPS'|grep -v 'rw='|grep -Ev 'Starting|Disk'|awk -F':' '{print$2$3$4}'
echo "##################randwrite_test End############################"

echo "##################rw_test Begin##########################"
egrep 'write|read|rw_test' $(ls|grep B_rw_test)|grep -E 'rw_test|IOPS'|grep -v 'rw='|grep -Ev 'Starting|Disk'|awk -F':' '{print$2$3$4}'
echo "##################rw_test End############################"