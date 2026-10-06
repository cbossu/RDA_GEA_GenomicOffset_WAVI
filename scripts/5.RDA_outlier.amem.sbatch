#!/bin/bash
#
#all commands that start with SBATCH contain commands that are just used by SLURM for scheduling
#################
#set a job name
#SBATCH --job-name=rda
#################
#a file for job output, you can check job progress
#SBATCH --output=rda.%j.out
#################
# a file for errors from the job
#SBATCH --error=rda.%j.err
#################
#time you think you need; default is one hour
#in minutes in this case
#SBATCH -t 24:00:00
#################
#quality of service; think of it as job priority
#SBATCH -p amem
#SBATCH --account=csu88_alpine2
#SBATCH --qos=mem-normal
#################
#number of nodes
#SBATCH --nodes=1
#SBATCH --ntasks-per-node 12
#################
#SBATCH --mem=240G
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

#Rscript RDA_ForwardSel.Rscript
Rscript RDA_outlier.Rscript
