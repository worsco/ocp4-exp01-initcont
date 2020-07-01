#!/bin/bash

if [[ -z "$INITCONTPROJECT" ]] ; then
  echo "You must set the INITCONTPROJECT environment variable"
  exit 1
fi

ROLLME=`date +%N`; echo $ROLLME ; \
oc patch sts pythonflask \
-n $INITCONTPROJECT \
--patch "{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"rollme\":\"$ROLLME\"}}}}}"

