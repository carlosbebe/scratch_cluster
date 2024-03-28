#!/bin/bash
set -e
    gosu munge /usr/sbin/munged
    exec /usr/sbin/slurmd -Dvvv

