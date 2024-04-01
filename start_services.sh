#!/bin/bash

set -ex
if [ $HOSTNAME == slurmdbd ]
then
    gosu munge /usr/sbin/munged
    sleep 60
    exec gosu slurm /usr/sbin/slurmdbd -D
fi

if [ $HOSTNAME == slurmctld ]
then
    gosu munge /usr/sbin/munged
    sleep 90
    exec gosu slurm /usr/sbin/slurmctld -i -D
fi

if [ $HOSTNAME == node1 ] || [ $HOSTNAME == node2 ] 
then
    gosu munge /usr/sbin/munged
    sleep 120
    exec /usr/sbin/slurmd -D
fi

