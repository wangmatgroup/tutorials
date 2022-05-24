#!/bin/bash
make
qsub submit.job
sleep 10
cat hello.out
