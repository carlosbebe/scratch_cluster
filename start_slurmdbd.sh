#!/bin/bash
set -e
    gosu munge /usr/sbin/munged
    . /etc/slurm/slurmdbd.conf
    exec gosu slurm /usr/sbin/slurmdbd -Dvvv

