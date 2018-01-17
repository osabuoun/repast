#!/bin/bash

USERNAME=$1
PASSWORD=$2
OUTDIR=$3
MODEL=$4
## download the model
echo "curl -O $MODEL"
curl -O $MODEL
#OUTDIR=`dirname $MODEL`
#OUTDIR=ftp://$(echo $MODEL | awk -F/ '{print $3}' | awk -F: '{print $1}')
#echo $OUTDIR

#OUTDIR="${OUTDIR}/output"

## remove the first parameter being the model archive 
shift 4


## for loop, for each parameters (minus the model archive) run repast
for batch in  $@; do
	echo "curl -O $batch"
	curl -O $batch
    echo "mv $batch param_batch.xml"

	NAME=$(echo "${batch##*/}")
	echo "NAME:" $NAME
	#NAME=$batch
	mv $NAME batch_params.xml
	
	echo "sh /opt/repast/repast.sh"
	bash /opt/repast/repast.sh
	echo "NAME2:" $NAME
	OUTPUT=out_${NAME}.tar
	echo "OUTPUT:" $OUTPUT
	#echo "upload outpout"
	ls 
        mv output.tar $OUTPUT
        ls
 	curl -T $OUTPUT $OUTDIR --user $USERNAME:$PASSWORD
	rm $OUTPUT
	echo "clean output"

done
