#!/bin/bash

fio rbd_4k_write.fio --output=rbd_4k_write.log
fio rbd_4k_randwrite.fio --output=rbd_4k_randwrite.log
mkdir ./rbd_16k_randwrite
fio rbd_16k_randwrite.fio --output=.rbd_16k_randwrite/rbd_16k_randwrite.log