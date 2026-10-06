#!/bin/bash
#
#all commands that start with SBATCH contain commands that are just used by SLURM for scheduling
#################
#set a job name
#SBATCH --job-name=rda_out
#################
#a file for job output, you can check job progress
#SBATCH --output=rda_out.%j.out
#################
# a file for errors from the job
#SBATCH --error=rda_out.%j.err
#################
#time you think you need; default is one hour
#in minutes in this case
#SBATCH -t 24:00:00
#################
#quality of service; think of it as job priority
#SBATCH -p acpu
#SBATCH --account=csu88_alpine2
#SBATCH --qos=cpu-normal
#################
#number of nodes
#SBATCH --nodes=1
#SBATCH --ntasks-per-node 32
#################
#SBATCH --mem=119G
#################
#get emailed about job BEGIN, END, and FAIL
#SBATCH --mail-type=END
#################
#who to send email to; please change to your email
#SBATCH  --mail-user=cbossu@rams.colostate.edu
#################
#now run normal batch commands
##################
#echo commands to stdout

set -x


source ~/.bashrc
conda activate R-GEA

Rscript RDA_outlier.Rscript
