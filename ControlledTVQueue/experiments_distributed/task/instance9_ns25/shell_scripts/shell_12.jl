#!/bin/bash
#SBATCH -J SL9ns12
#SBATCH -p bdwall
#SBATCH -A NEXTGENOPT
#SBATCH -N 1
#SBATCH -t 3:00:00

julia /blues/gpfs/home/choy/QS/experiments_distributed/task/instance9_ns25/main_scripts/main_12.jl