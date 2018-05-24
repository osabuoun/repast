#!/bin/sh

compile() {

WRK=~/Model
rm -rf $WRK
mkdir -p $WRK

cd $WRK

if [ ! -e $SRCDIR/srcmodel.tar ]; then
    pwd
    ls -al
    echo "srcmodel.tar not found"
    exit 1
fi

tar -xf $SRCDIR/srcmodel.tar

MODEL_NAME=`tar -tf $SRCDIR/srcmodel.tar | head -1 | awk -F'/' '{ print $1 }'`

cd $MODEL_NAME
if [ $? -ne 0 ]; then
	echo "Unable to change to $WRK/$MODEL_NAME"
 	exit 1
fi

INTERNAL_NAME=`ls src`
SRC=$WRK/$MODEL_NAME/src/$INTERNAL_NAME
BIN=$WRK/$MODEL_NAME/bin/$INTERNAL_NAME

if [ ! -d "$SRC" ]; then
	echo "no source file directory $SRC, cannot proceed"
	exit 1
fi

if [ ! -d "$BIN" ]; then
	mkdir -p "$BIN"
fi

CP=$CP:$PLUGINS/libs.bsf_$VERSION/lib/*:$PLUGINS/libs.ext_$VERSION/lib/*:$PLUGINS/$ROOT.batch_$VERSION/lib/*
CP=$CP:$PLUGINS/$ROOT.batch_$VERSION/bin
CP=$CP:$PLUGINS/$ROOT.distributed.batch_$VERSION/lib/*
CP=$CP:$PLUGINS/$ROOT.distributed.batch_$VERSION/bin
CP=$CP:$PLUGINS/$ROOT.core_$VERSION/lib/*
CP=$CP:$PLUGINS/$ROOT.core_$VERSION/bin
CP=$CP:$PLUGINS/$ROOT.runtime_$VERSION/lib/*
CP=$CP:$PLUGINS/$ROOT.runtime_$VERSION/bin
CP=$CP:$PLUGINS/$ROOT.data_$VERSION/bin
CP=$CP:$PLUGINS/$ROOT.dataLoader_$VERSION/bin
CP=$CP:$PLUGINS/$ROOT.scenario_$VERSION/bin
CP=$CP:$PLUGINS/$ROOT.essentials_$VERSION/bin
CP=$CP:$PLUGINS/$ROOT.groovy_$VERSION/bin
CP=$CP:$PLUGINS/$ROOT.intergation_$VERSION/lib/*
CP=$CP:$PLUGINS/$ROOT.intergation_$VERSION/bin
CP=$CP:$PLUGINS/saf.core.ui_$VERSION/saf.core.v3d.jar
CP=$CP:$PLUGINS/saf.core.ui_$VERSION/lib/*
CP=$CP:$SRC
CP=$CP:$BIN
CP=$CP:$PLUGINS/JoSQL-2.2.jar

cd $SRC
CLIST=""
for f in *.java; do
 	BASE=`echo $f | awk -F'.' '{ print $1 }'`
	BINCAND=$BIN/$BASE.class
	if [ ! -e $BINCAND ]; then
	 	CLIST=$CLIST" "$BASE
     	fi
done

if [ "$CLIST" != "" ]; then
	/usr/bin/javac -cp $CP *.java
	if [ $? -ne 0 ]; then
		echo "unable to compile $s.java"
		exit 1
	fi
	cp *.class $BIN
fi
cd $WRK
tar -cf $SRCDIR/model.tar $MODEL_NAME
exit 0
}




SRCDIR=`pwd`
TEMP=`pwd`
VERSION=2.1.0
ROOT=repast.simphony
INSTALLATION=/opt/repast
ROOTA=$INSTALLATION/RepastTest2/MyModels
PLUGINS=$ROOTA/plugins

# Model directories

#if [ $# -ne 1 ]; then
#    echo $@
#    echo "usage: repast.sh ModelName"
#    exit 1
#fi

if [ "$1" = "compile" ]; then
	compile
	exit 0
fi


if [ ! -e $SRCDIR/batch_params.xml ]; then
    pwd
    ls -al
    echo "batch_params.xml not found"
    exit 1
fi

if [ ! -e $SRCDIR/model.tar ]; then
    pwd
    ls -al
    echo "model.tar not found"
    exit 1
fi

MODEL_NAME=`tar -tf $SRCDIR/model.tar | head -1 | awk -F'/' '{ print $1 }'`
MODEL_FOLDER=$ROOTA/$MODEL_NAME
echo $MODEL_NAME
echo $MODEL_FOLDER


cp $SRCDIR/batch_params.xml $INSTALLATION/RepastTest2
(cd $ROOTA;tar -xf $SRCDIR/model.tar)


# Add to classpath


CP=$CP:$PLUGINS/libs.bsf_$VERSION/lib/*:$PLUGINS/libs.ext_$VERSION/lib/*:$PLUGINS/$ROOT.batch_$VERSION/lib/*
CP=$CP:$PLUGINS/$ROOT.batch_$VERSION/bin
CP=$CP:$PLUGINS/$ROOT.distributed.batch_$VERSION/lib/*
CP=$CP:$PLUGINS/$ROOT.distributed.batch_$VERSION/bin
CP=$CP:$PLUGINS/$ROOT.core_$VERSION/lib/*
CP=$CP:$PLUGINS/$ROOT.core_$VERSION/bin
CP=$CP:$PLUGINS/$ROOT.runtime_$VERSION/lib/*
CP=$CP:$PLUGINS/$ROOT.runtime_$VERSION/bin
CP=$CP:$PLUGINS/$ROOT.data_$VERSION/bin
CP=$CP:$PLUGINS/$ROOT.dataLoader_$VERSION/bin
CP=$CP:$PLUGINS/$ROOT.scenario_$VERSION/bin
CP=$CP:$PLUGINS/$ROOT.essentials_$VERSION/bin
CP=$CP:$PLUGINS/$ROOT.groovy_$VERSION/bin
CP=$CP:$PLUGINS/$ROOT.intergation_$VERSION/lib/*
CP=$CP:$PLUGINS/$ROOT.intergation_$VERSION/bin
CP=$CP:$PLUGINS/saf.core.ui_$VERSION/saf.core.v3d.jar
CP=$CP:$PLUGINS/saf.core.ui_$VERSION/lib/*
CP=$CP:$MODEL_FOLDER/bin
CP=$CP:$MODEL_FOLDER/src
CP=$CP:$PLUGINS/JoSQL-2.2.jar
CP=$CP:$PLUGINS/jackson-all-1.9.0.jar
CP=$CP:$PLUGINS/log4j-api-2.1.jar
CP=$CP:$PLUGINS/portico.jar
CP=$CP:$PLUGINS/log4j-core-2.1.jar

# Change directory to the model default


cd $MODEL_FOLDER

# Run

java -cp $CP repast.simphony.runtime.RepastBatchMain -params "$TEMP/batch_params.xml" "$MODEL_FOLDER/$MODEL_NAME.rs"

if [ $? -ne 0 ]; then
    echo "Exiting with error status"
    exit 1
fi

cd output
if [ $? -ne 0 ]; then
	echo "No output directory, creating"
	mkdir output
	cd output
fi

if find . -mindepth 1 -print -quit | grep -q .; then
	:
else
	echo "No output files"
	exit 1
fi

tar -cf $TEMP/output.tar *

cd $TEMP
rm -rf $MODEL_FOLDER

#rm *.txt 

exit 0
