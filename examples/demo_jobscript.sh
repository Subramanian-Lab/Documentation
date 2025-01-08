#!/bin/bash
#PBS -N demo_script
#PBS -q iiser_s
#PBS -l select=1:ncpus=1:mpiprocs=1
#PBS -V
#PBS -l walltime=48:00:00
#PBS -o output.o
#PBS -e output.err

ncores=`cat $PBS_NODEFILE|wc -l`
cd $PBS_O_WORKDIR

python3.9 script.py
