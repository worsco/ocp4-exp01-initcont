# We will only sync from the S3BUCKET when that env var is:
# Defined AND contains the value true
if [[ -z "$S3BUCKET" || ! "$S3BUCKET" == "true" ]] ; then
  cp -f -v files/space_cat.png /usr/share/html && \
  cp -f -v files/hyttioaoa.png /usr/share/html
  exit 0
fi

if [[ "$S3BUCKET" == "true" ]]; then
  aws s3 sync --no-progress s3://scw-initcont-exp01/exp01-annoydata/ /usr/share/html/
  exit 0
fi

# if we got here, maybe we should "exit 1"
