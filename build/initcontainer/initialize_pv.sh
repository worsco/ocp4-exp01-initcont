# We will only sync from the S3BUCKET when that env var is:
# Defined AND contains the value true
if [[ -z "$S3BUCKET" || ! "$S3BUCKET" == "true" ]] ; then
  cp -f -v files/space_cat.png /usr/share/html && \
  cp -f -v files/hyttioaoa.png /usr/share/html
  exit 0
fi


if [[ "$S3BUCKET" == "true" ]]; then

if [[ -z "$AWS_ACCESS_KEY_ID" ]]; then
  echo "AWS_ACCESS_KEY_ID env var needs to be set, aborting."
  exit 1
fi
if [[ -z "$AWS_SECRET_ACCESS_KEY" ]]; then
  echo "AWS_SECRET_ACCESS_KEY env var needs to be set, aborting."
  exit 1
fi
if [[ -z "$AWS_DEFAULT_REGION" ]]; then
  echo "AWS_DEFAULT_REGION env var needs to be set, aborting."
  exit 1
fi
  aws s3 sync --no-progress s3://scw-initcont-exp01/exp01-annoydata/ /usr/share/html/
  exit $?
fi

# If you got to here, there is an unknown error
echo "ERROR: 'aws s3 sync' unknown error."
exit 1
