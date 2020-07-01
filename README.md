# ocp4-exp01-initcont

OpenShift 4 "initContainer" experiment

## Use-Case

CHANGE-ME

## Design

CHANGME

## PRE-REQUISITES

* AWS 
  * An Account
  * S3 Bucket
    * Not public
  * IAM User
    * Read Write to S3 Bucket
      * Inline Policy
  * IAM User
    * Read Only to S3 Bucket
      * Inline Policy
* Container Image Repository
  * Quay.io
    * Account
    * Two image repositories
* OpenShift 4 cluster
  * Persistent Volume capability
    * RWO

## PREPARATION

### Create S3 Bucket

CHANGE-ME

### Create AWS IAM Users and attach policy

CHANGE-ME

### Push images into S3 bucket

CHANGE-ME

### Create Quay.io repositories

CHANGE-ME

### Build and Push container images

CHANGE-ME

Set environment variables

```bash 
export MYREGISTRY=your-repo
export MYREGISTRYACCT=your-account
export MYINITCONT_REPO=ocp4-exp01-initcont
export MYWEB_REPO=ocp4-exp01-web

#### Build and Push initContainer container image

CHANGE-ME

#### Build and Push python flask container image

CHANGE-ME

### Deploy application

Set environment variables

```bash
export INITCONTPROJECT=ocp4-exp01-initcont

export AWS_ACCESS_KEY_ID=your-key-id
export AWS_SECRET_ACCESS_KEY=your-access-key
export AWS_DEFAULT_REGION=your-aws-region

export S3BUCKETNAME=your-bucket-name
export S3FOLDER=your-s3-folder-name
```

Create a new project

```bash
oc new-project $INITCONTPROJECT
```

Create deployment

```bash
deployment/create_secret.sh
oc apply -n $INITCONTPROJECT -f deployment/configmap.yaml
oc apply -n $INITCONTPROJECT -f deployment/service.yaml
oc apply -n $INITCONTPROJECT -f deployment/route.yaml
oc apply -n $INITCONTPROJECT -f deployment/statefulset.yaml
```

Get the route

```bash
oc get route ocp4-exp01-web
```

OUTPUT (an example)

```bash
NAME             HOST/PORT                                                                           PATH   SERVICES         PORT   TERMINATION   WILDCARD
ocp4-exp01-web   ocp4-exp01-web-ocp4-exp01-initcont.apps.cluster-0000.lab.domain.tld          ocp4-exp01-web   8080                 None
```

Browse the route with a browser (example is using Firefox)

```bash
export WEB_ADDR=http://$(oc get route ocp4-exp01-web -n $INITCONTPROJECT -o jsonpath='{.spec.host}')

firefox --private-window $WEB_ADDR &
```

The web page will have one image that works, the other is broken (because the file does not exist).

### Begin experiment/demonstration of switching web templates and static image sources

Possible combinations of settings for python flask for this experiment:

```bash
#######################################################################

# MYDATA_SOURCE_DIR: static
# MYDATA_SOURCE_DIR: /usr/share/html

# MYTEMPLATE_SOURCE_DIR: templates
# MYTEMPLATE_SOURCE_DIR: templates2

#######################################################################
```

Patch the `ocp4-exp01-web` `configmap` to reconfigure flask to display
a different index.html file.  The `templates2` directory contains an `index.html`
file that is configured to display a different image.

```bash
oc patch configmap ocp4-exp01-web \
-n $INITCONTPROJECT \
--patch '{"data":{"MYTEMPLATE_SOURCE_DIR":"templates2"}}'
```

Force `statefullset` to redeploy by relying on the "nano-second" output of the date command and patching the `rollme` annotation on the `statefulset`.

```bash
ROLLME=`date +%N` ; echo $ROLLME ; \ \
oc patch sts pythonflask \
-n $INITCONTPROJECT \
--patch "{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"rollme\":\"$ROLLME\"}}}}}"
```

Make sure the last rollout is complete by checking that all pods are running

```bash
oc get pods
```

OUTPUT

```bash
NAME            READY   STATUS    RESTARTS   AGE
pythonflask-0   1/1     Running   0          82s
pythonflask-1   1/1     Running   0          58s
```

Browse the route

```bash
firefox --private-window $WEB_ADDR &
```

* Web page will display one working and one broken picture and display the word "templates2"

* "Space Cat" image is in the `/usr/share/html` directory -- switch the
directory source for static files and reload.

---

Change the `configmap` configuration for the web container forcing flask to
pull static images from `/usr/share/html`

```bash
oc patch configmap ocp4-exp01-web \
-n $INITCONTPROJECT \
--patch '{"data":{"MYDATA_SOURCE_DIR":"/usr/share/html"}}'
```

Force `statefullset` to redeploy... use the script provided

```bash
scripts/roll_sts.sh
```

Make sure the last rollout is complete (before reloading/deploying the browser) by checking that all pods are running

```bash
oc get pods
```

OUTPUT

```bash
NAME            READY   STATUS    RESTARTS   AGE
pythonflask-0   1/1     Running   0          82s
pythonflask-1   1/1     Running   0          58s
```

Browse the route

```bash
firefox --private-window $WEB_ADDR &
```

Page will show two pictures

---

Enable the S3BUCKET

Alter the `configmap` for ocp4-exp01-web

```bash
oc patch configmap ocp4-exp01-initcont \
-n $INITCONTPROJECT \
--patch '{"data":{"S3BUCKET":"true"}}'
```

Force `statefullset` to redeploy

```bash
scripts/roll_sts.sh
```

Reload the image -- I found that I needed to view the web page in a new browser or an incognito session as
the browser cached the initial space_cat.png image without displaying the new, much larger image.

* The browser 'should' display the much larger image
  
```bash
firefox --private-window $WEB_ADDR &
```

---

Switch back to the smaller space_cat.png image

Change the `configmap` for ocp4-exp01-web:

```bash
oc patch configmap ocp4-exp01-initcont \
-n $INITCONTPROJECT \
--patch '{"data":{"S3BUCKET":"false"}}'
```

Force `statefullset` to redeploy

```bash
scripts/roll_sts.sh
```

Because you changed the `S3BUCKET` variable to false, the initContainer will copy its images
from its own container into the Persistent Volume.

```bash
firefox --private-window $WEB_ADDR &
```
