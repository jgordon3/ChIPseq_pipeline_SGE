#!/bin/bash
#  pipeline_bowtie.sh
#$ -cwd
#$ -j Y
# Request [num] amount of [type] nodes
#$ -pe threads 4

#########################################################################
####################### DEFAULTS GO HERE ################################
#########################################################################

BOWTIE_VERSION=`bowtie2 --version | head -n1`; COMPRESS="y"; DATE=`date`; FILTER="y"; GENOME="hg38";
NAME="J. Gordon"; RECIPE="SE"

###################### CHECK FASTQ(S) #####################################
if [[ -e $FASTQ ]]; then FASTQ=$FASTQ; else echo "Need valid path to fastq or fastq.gz file"; usage; fi
#if [[ $RECIPE == "PE" ]]; then check for pair ; fi

#CHECK FOR GZIP
EXT=${FASTQ##*.}
if [ $EXT = "gz" ]; then gunzip $FASTQ; FASTQ=${FASTQ%.gz}; fi

# FILE NAME
ABRV_NAME=${FASTQ%.fastq}


# GENOME ASSIGNMENT
if [ $GENOME == "hg38" ]; then INDEX=/slipstream/galaxy/data/hg38/hg38canon/bowtie2_index/hg38canon
    elif [ $GENOME == "hg19" ]; then INDEX=/slipstream/galaxy/data/hg19/hg19canon/bowtie2_index
    elif [ $GENOME == "mm10" ]; then INDEX=/slipstream/galaxy/data/mm10/bowtie2_index_canon
    elif [ $GENOME == "mm9" ]; then INDEX=/slipstream/galaxy/data/mm9/bowtie2_index_canon
    else echo "could not find specified index"; usage;
fi

######################################################################################
#################### run BOWTIE2 here ################################################
######################################################################################

printf "%s\n" "$DIVIDER" ""  "RUNNING BOWTIE2 ON: $FILT_FASTQ" ""
OUTPUT_NAME=$ABRV_NAME"_BAM.bowtie"
bowtie2 -p 4 -x $INDEX -U $FASTQ -S $OUTPUT_NAME

