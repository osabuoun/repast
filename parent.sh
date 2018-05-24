#!/bin/bash
echo $(pwd)
bash test.sh
retn_code=$?

if [ $retn_code != "0" ]; then
	echo "Success" $retn_code
else
	echo "failed" $retn_code
fi
exit 0
