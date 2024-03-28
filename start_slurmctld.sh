#!/bin/bash
set -e

    gosu munge /usr/sbin/munged
     exec gosu slurm /usr/sbin/slurmctld -i -Dvvv

