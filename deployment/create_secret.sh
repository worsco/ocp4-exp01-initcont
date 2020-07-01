if [[ -z "$RO_AWS_ACCESS_KEY_ID" ]] ; then
  echo "You must set the RO_AWS_ACCESS_KEY_ID environment variable"
  exit 1
fi

if [[ -z "$RO_AWS_SECRET_ACCESS_KEY" ]] ; then
  echo "You must set the RO_AWS_SECRET_ACCESS_KEY environment variable"
  exit 1
fi

if [[ -z "$RO_AWS_DEFAULT_REGION" ]] ; then
  echo "You must set the RO_AWS_DEFAULT_REGION environment variable"
  exit 1
fi

if [[ -z "$INITCONTPROJECT" ]] ; then
  echo "You must set the INITCONTPROJECT environment variable"
  exit 1
fi

oc create secret generic initcont-aws-ro -n $INITCONTPROJECT \
--from-literal=AWS_ACCESS_KEY_ID=$RO_AWS_ACCESS_KEY_ID \
--from-literal=AWS_SECRET_ACCESS_KEY=$RO_AWS_SECRET_ACCESS_KEY \
--from-literal=AWS_DEFAULT_REGION=$RO_AWS_DEFAULT_REGION
