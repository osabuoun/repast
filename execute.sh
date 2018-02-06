#!/bin/bash
echo "**************** checkpoint 00 *****************"
echo $@
echo "**************** checkpoint 01 *****************"
USERNAME=$1
PASSWORD=$2
OUTDIR=$3
MODEL=$4
## download the model
echo "**************** checkpoint 1 *****************"
echo "curl -O $MODEL" >> loggg
curl -O $MODEL
echo "**************** checkpoint 2 *****************"
#OUTDIR=`dirname $MODEL`
#OUTDIR=ftp://$(echo $MODEL | awk -F/ '{print $3}' | awk -F: '{print $1}')
#echo $OUTDIR

#OUTDIR="${OUTDIR}/output"

## remove the first parameter being the model archive 
shift 4


## for loop, for each parameters (minus the model archive) run repast
for batch in  $@; do
	echo "**************** checkpoint 3 *****************"
	echo "curl -O $batch" >> loggg
	curl -O $batch
    echo "mv $batch batch_params.xml" >> loggg

	NAME=$(echo "${batch##*/}")
	echo "NAME:" $NAME >> loggg
	#NAME=$batch
	mv $NAME batch_params.xml
	
	echo "bash /opt/repast/repast.sh" >> loggg
	bash /opt/repast/repast.sh
	retn_code=$?
	if [ $retn_code = "0" ]; then
		echo "NAME2:" $NAME >> loggg
		OUTPUT=out_${NAME}.tar
		echo "OUTPUT:" $OUTPUT >> loggg
		#echo "upload outpout"
        mv output.tar $OUTPUT
 		curl -T $OUTPUT $OUTDIR --user $USERNAME:$PASSWORD
		rm $OUTPUT
		echo "clean output" >> loggg
	else
		echo "*************************************" >> loggg
		echo "An Error happened : " $retn_code >> loggg
		echo "*************************************" >> loggg
		exit $retn_code
	fi
done
