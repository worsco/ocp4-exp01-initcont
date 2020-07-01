# ocp4-exp01-initcont

OpenShift 4 "initContainer" experiment to populate a PV

## Use-Case

We need to be able to populate a Persistent Volume (PV) of type RWO with a large binary file from an S3
bucket before our application starts.  The large binary file will only change every 30 days, and we
want to minimize transfer bandwidth & start-up time of our application pods on OpenShift.

## Design

A kubernete's statefulset, volumeClaimTemplate, and an initContainer will be used to fulfill our use-case.
Two containers will be built -- the initContainer and an application container.  The initContainer has the 
logic to connect to AWS S3 and will 'sync' the large binary files to the PV.  The application container,
in this experiment, is python flask web application.

### Architecture Diagram

CHANGE-ME

### Process Flow Diagram

![Process Flow Diagram](/diagrams/flowchart.png "Process Flow Diagram")

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
* Container Image Repositories
  * Quay.io
    * An account
    * Two image repositories
  * registry.redhat.io
    * An account
* OpenShift 4 cluster
  * Persistent Volume capability
    * RWO

## PREPARATION

### Create S3 Bucket

* Create an S3 bucket in AWS.  Ensure it is not accessible by the public.  We will be using a policy attached
to a IAM role to allow connectivity.

The name of the bucket will be used in the next section.

* Create a folder using the AWS S3 console interface and note its name (that name will be used in the security
 policy in the next section).

---

### Create AWS IAM Users and attach policy

* Create two AWS IAM Users.

In my demo, I have created `ocp-exp01-initcont-push` (that will have R/W access to the S3 bucket + one folder), and a
account named `ocp-exp01-initcont-ro` (which will have read-only access to a specific folder in the bucket).

When you create each account, note the KEY ID and the SECRET -- they will be used later.

#### s3-readwrite-exp01

To the `ocp-exp01-initcont-push` IAM user, alter the following policy and attach it.
Replace "YOUR-S3-BUCKET-NAME" with the bucket that you've created and "YOUR-FOLDER" with the folder 
that you previously created in the S3 bucket.  This will limit the "push" account to only
one folder in the S3 bucket.


```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowListBucketIfSpecificPrefixIsIncludedInRequest",
            "Action": [
                "s3:ListBucket"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::YOUR-S3-BUCKET-NAME"
            ],
            "Condition": {
                "StringLike": {
                    "s3:prefix": [
                        "YOUR-FOLDER/*"
                    ]
                }
            }
        },
        {
            "Sid": "AllowUserToReadWriteObjectDataInDevelopmentFolder",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::YOUR-S3-BUCKET-NAME/YOUR-FOLDER/*"
            ]
        }
    ]
}
```

#### s3-readonly-exp01

To the `ocp-exp01-initcont-ro`, alter the following policy and attach it to the "read-only" IAM account.
Like the previous section, replace "YOUR-S3-BUCKET-NAME" with the bucket that you have created and 
"YOUR-FOLDER" with the folder name.


```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowListBucketIfSpecificPrefixIsIncludedInRequest",
            "Action": [
                "s3:ListBucket"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::YOUR-S3-BUCKET-NAME"
            ],
            "Condition": {
                "StringLike": {
                    "s3:prefix": [
                        "YOUR-FOLDER/*"
                    ]
                }
            }
        },
        {
            "Sid": "AllowUserToReadWriteObjectDataInDevelopmentFolder",
            "Action": [
                "s3:GetObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::YOUR-S3-BUCKET-NAME/YOUR-FOLDER/*"
            ]
        }
    ]
}
```

---

### Push images into S3 bucket

In our demonstration, you need to download two images and name them
`hyttioaoa.png` and `space_cat.png`.  The `hyttioaoa.png` image can be found
in the `build/webcontainer/static/` directory.  The `space_cat.png` file
should be a new file and fairly large -- I would suggest you locate a very 
large image file from NASA and use that as your `space_cat.png` file to upload
into S3.

Set your AWS Credential environment variables and push two images into the S3 folder.

```bash
export AWS_ACCESS_KEY_ID=YOUR-RW-ACCOUNT-ID
export AWS_SECRET_ACCESS_KEY=YOUR-RW-ACCOUNT-SECRET
export AWS_DEFAULT_REGION=YOUR-AWS-S3-REGION
export S3BUCKETNET=YOUR-S3-BUCKET-NAME
export S3FOLDER=YOUR-S3-FOLDER
```

Change directory into your local folder that has your `hyttioaoa.png` and
`space_cat.png` files (reminder -- don't use the `space_cat.png` from this
repo, find a new, large png file).  The `space_cat.png` uploaded to S3 will
be used to demonstrate 1. large file sync using an initContainer in k8s and
2. displaying a file from a web page using a python flask web server.

```bash
aws s3 sync . s3://YOUR-S3-BUCKET/YOUR-FOLDER
```

---

### Create Quay.io repositories

Two images will be used in this demonstration and we need to have a public repositories to pull our
custom images.  

* Create a free account in quay.io
  * Make note of that account name and your access credentials
* Create two public repositories
  * `ocp4-exp01-initcont`
  * `ocp4-exp01-web`

---

### Build and Push container images

* Log into `quay.io` from command line
  * To push images into
* Log into `registry.redhat.io`
  * To pull base containers from

#### quay.io

```bash
podman login -u "your-quay.io-username" -p
```

#### registry.redhat.io

```bash
podman login -u "your-redhat-io-username" -p
```

#### Set environment variables

Change the following environment variables to match your registry account name.

```bash 
export MYREGISTRY=quay.io
export MYREGISTRYACCT=your-account
export MYINITCONT_REPO=ocp4-exp01-initcont
export MYWEB_REPO=ocp4-exp01-web
````

#### Build and Push initContainer container image

```bash
build/init_build_and_push.sh
```


#### Build and Push python flask container image

```bash
build/web_build_and_push.sh
```

### Deploy application

* Set environment variables for your OCP4 project name.

```bash
export INITCONTPROJECT=ocp4-exp01-initcont
```

* Create a new project

```bash
oc new-project $INITCONTPROJECT
```

* Deploy the application

```bash
deployment/create_secret.sh
oc apply -n $INITCONTPROJECT -f deployment/configmap.yaml
oc apply -n $INITCONTPROJECT -f deployment/service.yaml
oc apply -n $INITCONTPROJECT -f deployment/route.yaml
oc apply -n $INITCONTPROJECT -f deployment/statefulset.yaml
```

* Display the route

```bash
oc get route ocp4-exp01-web
```
OUTPUT (an example)

```bash
NAME             HOST/PORT                                                                           PATH   SERVICES         PORT   TERMINATION   WILDCARD
ocp4-exp01-web   ocp4-exp01-web-ocp4-exp01-initcont.apps.cluster-0000.lab.domain.tld          ocp4-exp01-web   8080                 None
```

* To display only the route path

```bash
echo "http://`oc get route ocp4-exp01-web -n $INITCONTPROJECT -o jsonpath='{.spec.host}'`"
```

* Browse the route with a browser (example is using Firefox)

```bash
export WEB_ADDR=http://$(oc get route ocp4-exp01-web -n $INITCONTPROJECT -o jsonpath='{.spec.host}')

firefox --private-window $WEB_ADDR &
```

The web page will have one image that works, the other is broken (because the file does not exist).

---

### Begin experiment/demonstration of switching web templates and static image sources

Possible combinations of settings for python flask for this experiment:

```bash
MYDATA_SOURCE_DIR: static
MYDATA_SOURCE_DIR: /usr/share/html

MYTEMPLATE_SOURCE_DIR: templates
MYTEMPLATE_SOURCE_DIR: templates2
```

* `MYDATA_SOURCE_DIR`:
    * Setting it to `static` tells python flask to pull from the
    directory `static` under the application's root directory
    * Setting it to `/usr/share/html` give python flask a absolute
    directory

* `MYTEMPLATE_SOURCE_DIR`:
    * There are two directories in the python flask application root
    directory, `templates` and `templates2`.  Each directory contain
    a single file `index.html`.  They will be used to demonstrate
    displaying different image files.

---

Patch the `ocp4-exp01-web` `configmap` to reconfigure flask to display
a different index.html file.  The `templates2` directory contains an `index.html`
file which is configured to display a different image.

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

* Make sure the last rollout is complete by checking that all pods are running

```bash
oc get pods
```

OUTPUT

```bash
NAME            READY   STATUS    RESTARTS   AGE
pythonflask-0   1/1     Running   0          82s
pythonflask-1   1/1     Running   0          58s
```

* Browse the route (or refresh the browser)

```bash
firefox --private-window $WEB_ADDR &
```

Web page will display one working and one broken picture and display the word "templates2"

"Space Cat" image is in the `/usr/share/html` directory -- switch the
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
# END OF DEMONSTRATION