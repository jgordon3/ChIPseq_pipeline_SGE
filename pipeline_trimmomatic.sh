#!/bin/sh
#  pipeline_trimmomatic.sh
#$ -cwd
#$ -j Y
# Request [num] amount of [type] nodes
#$ -pe threads 4

#########################################################################
####################### DEFAULTS GO HERE ################################
#########################################################################
DATE=`date`;
NAME="J. Gordon";
RECIPE="SE";
ILLUMINACLIP_FILE=/slipstream/home/jonathan/bin/Trimmomatic-0.35/adapters/TruSeq3-SE.fa
CLIP_LEADING=3
CLIP_TRAILING=3
WINDOW="4:20"
MINLEN=36

while getopts "F:G:t:u:i:l:w:R:h:" opt; do
    case $opt in
        F) FASTQ=$OPTARG;;
        u) NAME=$OPTARG;;
        i) ILLUMINACLIP_FILE=$OPTARG;;
        l) CLIP_LEADING=$OPTARG;;
        t) CLIP_TRAILING=$OPTARG;;
        w) WINDOW=$OPTARG;;
        m) MINLEN=$OPTARG;;
        R) RECIPE=$OPTARG;;
        h) usage;;
        :) usage;;
        *) usage;;
    esac
done
shift $(($OPTIND -1))


TRIMMOMATIC_DIR=/slipstream/home/jonathan/bin/Trimmomatic-0.35
$ABRV_NAME=${FASTQ%.fastq}
FILT_FASTQ=$ABRV_NAME"_trim_filt.fastq";

java -Djava.io.tmpdir=/slipstream/home/jonathan/bin/tmp -jar $TRIMMOMATIC_DIR/trimmomatic-0.35.jar $RECIPE -threads 4 -phred33 $FASTQ $FILT_FASTQ ILLUMINACLIP:$ILLUMINACLIP_FILE:2:30:10 LEADING:$CLIP_LEADING TRAILING:$CLIP_TRAILING SLIDINGWINDOW:$WINDOW MINLEN:$MINLEN;

gzip $FILT_FASTQ; gzip $FASTQ;