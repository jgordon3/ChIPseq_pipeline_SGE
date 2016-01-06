#!/bin/bash

#  launch_ChIPseq_pipeline.sh
#

#########################################################################
####### CONFIG FILE                                         #############
####### EDIT PARAMETERS HERE: SEE USAGE FOR DETAILS         #############
#########################################################################

# For best results:  each experiment create a folder containing fastqs
# and an edited version of this script. Launch Script as "nohup launch_ChIPseq_pipeline.sh &" or behind a screen

## EXPERIMENT_NAME ### #-E flag
EXP_NAME="Some_histone_analysis"

## USER_NAME ##### #-u flag
USER="Jonathan Gordon"

## PATH_TO_FASTQ_FILES #### #-F flag
PATH_TO_FASTQS="/slipstream/home/jonathan/"

## GENOME_TO_ALIGN ####### #-G flag
GENOME=

## GENOME_TO_ALIGN ####### #-G flag

################################################################################
###### END CONFIG  #############################################################
################################################################################
DATE=`date`

DIV1=`eval printf '=%.0s' {1..100}`
DIV2=`eval printf '=%.0s' {1..25}`

usage ()
{
printf "%s\n" "" "$DIV1"
printf "%s\t" "$DIV2" "LAUNCH ChIPseq PIPELINE" "" "" "" "$DIV2"
printf "%s\n" "" "$DIV1" ""
printf "%s\n" "This script launches several scripts comprising the entire pipeline for a ChIPseq experiment."
printf "%s\n" "all configurations can be done by editing this script before launching or supplying optional"
printf "%s\n" "flags for individual programs. Flags will override modifications to the script." ""
printf "%s\n" "$DIV1" ""
printf "%s\n" "run_Bowtie2_on_SGE.sh" ""
printf "%s\n" "REQUIRES (NON OPTIONAL): A list of fastq files to align."
printf "%s\n" "This can be providied by editing the PATH_TO_FASTQS variable in this file."
printf "%s\n" "OR with the -F flag with a path to a folder with multiple fastq files OR"
printf "%s\n" "with the -C flag containing the path/file names in the first column of a tab-deliniated file" ""
printf "%s\n" "REQUIRES: A reference genome to align to"
printf "%s\n" "The script will default to hg38 but it can be modified by setting GENOME variable in this file"
printf "%s\n" "OR with the -G flag"
printf "%s\n" "REQUIRES: A reference genome to align to"
printf "%s\n" "The script will default to hg38 but it can be modified by setting GENOME variable in this file"
printf "%s\n" "OR with the -G flag"

exit 1;
}


# OPTIONS

while getopts "F:c:E:i:l:t:w:m:R:u:G:" opt; do
    case $opt in
        F) PATH_TO_FASTQS=$OPTARG;;
        c) COMPRESS=$OPTARG;; #trimm
        i) ILLUMINACLIP_FILE=$OPTARG;;#trim
        l) CLIP_LEADING=$OPTARG;; #trimm
        t) CLIP_TRAILING=$OPTARG;; #trimm
        w) WINDOW=$OPTARG;; #trim
        m) MINLEN=$OPTARG;; #trim
        R) RECIPE=$OPTARG;; #trim
        E) EXP_NAME=$OPTARG;;
        u) USER=$OPTARG;; #trimm
        G) GENOME=$OPTARG;;
        h) usage;;
        :) usage;;
        *) usage;;
    esac
done

if [[ ! -d $PATH_TO_FASTQS ]]; then echo "Need valid path to fastq or fastq.gz file"; usage; fi
shift $(($OPTIND -1))

# Matches a list of JOBIDs to currently running /queued jobs in SGE
qstat_query () {
    SUBMITS="$1" # Note: it is not easy to pass an array to a function in bash so the JOBIDS are passed as a string variable
    unset SUBMIT_ARRAY # clear previous
        for i in $SUBMITS; do SUBMIT_ARRAY+=($i); done
            echo "Submitted: ${#SUBMIT_ARRAY[@]} jobs: ${SUBMIT_ARRAY[@]}"

    JOB_MATCH=1
        while [[ $JOB_MATCH -gt 0 ]]; do
            sleep 15    #change interval
            QSTAT_QUERY=`qstat -u "*"`
            JOB_QUERY=$(echo $QSTAT_QUERY |grep -Eo '[0-9]{5}') # not optimal .. returns all 5 digit numbers in qstat

            unset JOBIDS_QUERY # clear previous query and list running jobs
            for i in $JOB_QUERY; do JOBIDS_QUERY+=($i); done

            JOB_MATCH=0  #match jobs
            for i in "${SUBMIT_ARRAY[@]}"; do
                for j in "${JOBIDS_QUERY[@]}"; do
                    if [[ $i == $j ]]; then JOB_MATCH=$((JOB_MATCH+1));fi
                done
            done
        CURRENTTIME=$(date +%s); ELAPSED=$(($CURRENTTIME - $STARTTIME)); echo "checking for job(s): ${SUBMIT_ARRAY[@]}"; echo "$JOB_MATCH are still running. $ELAPSED seconds elapsed"
    done
    echo "all jobs complete"
}
# make summary file

SUMMARY=".$EXP_NAME_summary.txt"
printf "%s\t" "FASTQ_FILE" "" >> $SUMMARY

#######################################################################################################
######## TRIMMOMATIC    ###############################################################################
#######################################################################################################

for f in $PATH_TO_FASTQS; do
    JOB1=$(qsub ~/scripts/pipeline_trimmomatic.sh -F $f $TRIMFLAGS)
    TRIM_JOBID=$(awk -v RS=[0-9]+ '{print RT+0;exit}' <<< "$JOB1") #returns JOBID
    TRIM_JOBIDS="$TRIM_JOBIDS $TRIM_JOBID"

    FILT_FASTQ=$ABRV_NAME"_trim_filt.fastq";
done

qstat_query($TRIM_JOBS)

#######################################################################################################
######## BOWTIE         ###############################################################################
#######################################################################################################





