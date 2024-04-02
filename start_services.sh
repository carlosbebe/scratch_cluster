#!/bin/bash

set -ex
if [ $HOSTNAME == slurmdbd ]
then
    /usr/sbin/sshd -D &
    gosu munge /usr/sbin/munged
    sleep 40
    exec gosu slurm /usr/sbin/slurmdbd -D
fi

if [ $HOSTNAME == slurmctld ]
then
    /usr/sbin/sshd -D &
    gosu munge /usr/sbin/munged
    sleep 50
    exec gosu slurm /usr/sbin/slurmctld -i -D
fi

if [ $HOSTNAME == node1 ] || [ $HOSTNAME == node2 ] 
then
    /usr/sbin/sshd -D &
    gosu munge /usr/sbin/munged
    sleep 60
    exec /usr/sbin/slurmd -D
fi

