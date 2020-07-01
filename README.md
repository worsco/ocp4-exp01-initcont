# ocp4-exp01-initcont
OCP4 initcontainer experiment

## Use-Case

CHANGEME

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

## PREPARATION

### Create S3 Bucket

CHANGEME

### Create AWS IAM Users and attach policy

CHANGEME

### Push images into S3 bucket

CHANGEME

### Create Quay.io repositories

CHANGEME

### Build and Push container images

CHANGEME

### Deploy application

Set environment variables

```
export INITCONTPROJECT=ocp4-exp01-initcont

export AWS_ACCESS_KEY_ID=your-key-id
export AWS_SECRET_ACCESS_KEY=your-access-key
export AWS_DEFAULT_REGION=your-aws-region

export S3BUCKETNAME=your-bucket-name
export S3FOLDER=your-s3-folder-name
```

Create a new project

```
oc new-project $INITCONTPROJECT
```

Create deployment

```
deployment/create_secret.sh
oc apply -n $INITCONTPROJECT -f deployment/configmap.yaml
oc apply -n $INITCONTPROJECT -f deployment/service.yaml
oc apply -n $INITCONTPROJECT -f deployment/route.yaml
oc apply -n $INITCONTPROJECT -f deployment/statefulset.yaml
```

Get the route

```
oc get route ocp4-exp01-web
```

OUTPUT (an example)

```
NAME             HOST/PORT                                                                           PATH   SERVICES         PORT   TERMINATION   WILDCARD
ocp4-exp01-web   ocp4-exp01-web-ocp4-exp01-initcont.apps.cluster-0a62.0a62.sandbox1775.opentlc.com          ocp4-exp01-web   8080                 None
```

Browse the route with firefox

```
export WEB_ADDR=http://$(oc get route ocp4-exp01-web -n $INITCONTPROJECT -o jsonpath='{.spec.host}')

firefox --private-window $WEB_ADDR &
```

Inital web page will have one image that works, the other is broken (because the file does not exist).


### Begin experiment/demonstration of switching web templates and static image sources

Possible combinations of settings for python flask for this experiment:
```
#######################################################################

# MYDATA_SOURCE_DIR: static
# MYDATA_SOURCE_DIR: /usr/share/html

# MYTEMPLATE_SOURCE_DIR: templates
# MYTEMPLATE_SOURCE_DIR: templates2

#######################################################################
```

Patch the ocp4-exp01-web configmap so flask will be configured display another
index.html file.  The templates2 directory contains index.html configured
to display a different image.

```
oc patch configmap ocp4-exp01-web \
-n $INITCONTPROJECT \
--patch '{"data":{"MYTEMPLATE_SOURCE_DIR":"templates2"}}'
```

Force statefullset to redeploy
```
ROLLME=`date +%N` ; echo $ROLLME ; \ \
oc patch sts pythonflask \
-n $INITCONTPROJECT \
--patch "{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"rollme\":\"$ROLLME\"}}}}}"
```

Make sure the last rollout is complete by checking that all pods are running

```
oc get pods
```

OUTPUT
```
NAME            READY   STATUS    RESTARTS   AGE
pythonflask-0   1/1     Running   0          82s
pythonflask-1   1/1     Running   0          58s
```

Browse the route
```
firefox --private-window $WEB_ADDR &
```

* Web page will display one working and one broken picture and say "templates2"

* "Space Cat" image is in the /usr/share/html directory -- we need to switch the
directory source for static files and reload.

---

Change the configmap to pull from container's /usr/share/html directory
```
oc patch configmap ocp4-exp01-web \
-n $INITCONTPROJECT \
--patch '{"data":{"MYDATA_SOURCE_DIR":"/usr/share/html"}}'
```

Force statefullset to redeploy
```
ROLLME=`date +%N`; echo $ROLLME ; \
oc patch sts pythonflask \
-n $INITCONTPROJECT \
--patch "{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"rollme\":\"$ROLLME\"}}}}}"
```

Make sure the last rollout is complete by checking that all pods are running
```
oc get pods
```
OUTPUT
```
NAME            READY   STATUS    RESTARTS   AGE
pythonflask-0   1/1     Running   0          82s
pythonflask-1   1/1     Running   0          58s
```

Browse the route
```
firefox --private-window $WEB_ADDR &
```

Page will show two pictures

---

Enable the S3BUCKET

Change the configmap for ocp4-exp01-web:
```
oc patch configmap ocp4-exp01-initcont \
-n $INITCONTPROJECT \
--patch '{"data":{"S3BUCKET":"true"}}'
```

Force statefullset to redeploy:
```
ROLLME=`date +%N` ; echo $ROLLME ; \
oc patch sts pythonflask \
-n $INITCONTPROJECT \
--patch "{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"rollme\":\"$ROLLME\"}}}}}"
```

Reload the image -- I found that I needed to view the web page in a new browser or an incognito session as
the browser cached the initial space_cat.png image without displaying the new, much larger image.

* The browser 'should' display the much larger image
```
firefox --private-window $WEB_ADDR &
```

---

Switch back to the smaller space_cat.png image

Change the configmap for ocp4-exp01-web:
```
oc patch configmap ocp4-exp01-initcont \
-n $INITCONTPROJECT \
--patch '{"data":{"S3BUCKET":"false"}}'
```

Force statefullset to redeploy
```
ROLLME=`date +%N` ; echo $ROLLME ; \
oc patch sts pythonflask \
-n $INITCONTPROJECT \
--patch "{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"rollme\":\"$ROLLME\"}}}}}"
```

Demonstrate that the initcontainer has copied the image from the initcontainer's directory.

```
firefox --private-window $WEB_ADDR &
```
