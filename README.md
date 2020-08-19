# Tanzu Kubernetes Pipeline Demo

<!--ts-->
   * [Tanzu Kubernetes Pipeline Demo](#tanzu-kubernetes-pipeline-demo)
      * [Overview](#overview)
         * [About Concourse](#about-concourse)
         * [About Tanzu Build Service](#about-tanzu-build-service)
         * [About Kapp-controller](#about-kapp-controller)
         * [Pipeline Diagram](#pipeline-diagram)
         * [Requirements](#requirements)
         * [Tested Software and Versions](#tested-software-and-versions)
            * [Install the gh CLI](#install-the-gh-cli)
         * [Conventions Used](#conventions-used)
      * [Workshop](#workshop)
            * [Create a Github Personal Access Token](#create-a-github-personal-access-token)
         * [Fork and Clone the Spring Petclinic Application](#fork-and-clone-the-spring-petclinic-application)
         * [Fork and Clone the Workshop Repository](#fork-and-clone-the-workshop-repository)
         * [Use Concourse as the Continuous Integration System](#use-concourse-as-the-continuous-integration-system)
            * [Install Concourse](#install-concourse)
            * [Install Fly CLI](#install-fly-cli)
            * [Create Concourse Credentials File](#create-concourse-credentials-file)
            * [Configure and Test the Concourse Pipeline](#configure-and-test-the-concourse-pipeline)
         * [Use TBS to Build the Spring Petclinic Container Image](#use-tbs-to-build-the-spring-petclinic-container-image)
            * [Install the Tanzu Build Service](#install-the-tanzu-build-service)
            * [Configure TBS to Build the Spring Petclinic Container Image from Source](#configure-tbs-to-build-the-spring-petclinic-container-image-from-source)
            * [Review TBS Custom Resource Definitions](#review-tbs-custom-resource-definitions)
         * [Use Kapp Controller to Deploy Spring Petclinic Application](#use-kapp-controller-to-deploy-spring-petclinic-application)
            * [Install the Kapp Controller](#install-the-kapp-controller)
            * [Configure Kapp Controller to Manage Spring Petclinic](#configure-kapp-controller-to-manage-spring-petclinic)
            * [Review Kapp-controller Custom Resource Definitions](#review-kapp-controller-custom-resource-definitions)
         * [All Together Now!](#all-together-now)
            * [Update Spring Petclinic Code and Let Concourse Run Tests](#update-spring-petclinic-code-and-let-concourse-run-tests)
            * [Watch TBS and Kapp-controller Redeploy the Application](#watch-tbs-and-kapp-controller-redeploy-the-application)
      * [Conclusion](#conclusion)
      * [Clean Up](#clean-up)
<!--te-->

## Overview

The goal of this workshop is to combine the [Tanzu Build Service](https://tanzu.vmware.com/build-service) aka TBS (based on the upstream open source system [kpack](https://github.com/pivotal/kpack)) and [buildpacks](https://buildpacks.io) with the [kapp-controller](https://github.com/k14s/kapp-controller), part of the [k14s](https://k14s.io) set of tools, to:

1. Concourse runs tests on code commited to a testing branch
1. If the code passes the tests Concourse pushes it to staging
1. TBS will pick up the changes in the staging branch and build an image 
1. Kapp-controller will redeploy the application based on that image

The goal of this short workshop is to show how Concourse, TBS and kapp-controller can work together to manage Kubernetes applications, and to do so using Custom Resource Definitions (CRDs) that become part of the Kubernetes API. Thus, when building and deploying applications with TBS and kapp-controller it's actually all done through Kubernetes.

### About Concourse

[Concourse](https://concourse-ci.org/) is an open source continuous integration system that runs tasks in containers. Concourse pipelines are completely defined in YAML, there is no way to changes pipelines without altering YAML, i.e the pipelines are code. Pipelines can be visualized in the Concourse Web interface.

>Concourse is an open-source continuous thing-doer. Built on the simple mechanics of resources, tasks, and jobs, Concourse presents a general approach to automation that makes it great for CI/CD.

### About Tanzu Build Service

The [Tanzu Build Service](https://tanzu.vmware.com/build-service) (TBS) is a commercial product based on the upstream open source systems kpack and buildpacks, and allows you to build, maintain, and update portable OCI images. Because the resulting images are based on [buildpacks](https://buildpacks.io) organizations can easily govern their container images.

>Consistently create production-ready container images that run on Kubernetes and across clouds. Automate source-to-container workflows across all your development frameworks.

### About Kapp-controller

[Kapp-controller](https://github.com/k14s/kapp-controller) is part of the [k14s](https://k14s.io/) set of tools which take a modular approach to managing modern applications in container environments.

>kapp controller provides a way to specify which applications should run on your K8s cluster via one or more App CRs. It will install, and continiously apply updates.

### Pipeline Diagram

![Achitecture Diagram](/img/arch.jpg)

*NOTE: Github and Docker Hub are used in this workshop because they are public and easily accessible. Most container image registries and git repositories would also work just fine.*

### Requirements

1. A kubernetes cluster that supports Kubernetes load balancers
1. The Kubernetes cluster must also have a default storage class
1. TBS installed into that cluster, and is working
2. A docker hub account
3. A github account
4. Assumes the use of a Linux terminal

A Kubernetes cluster with load balancer support is not strictly necessary, but, for this workshop, the Spring Petclinic Kubernetes manifest is configured to use one.

*NOTE: You may want to create temporary accounts on docker hub and github, as your credentials will be used by TBS for both.*

### Tested Software and Versions

Required:

* [TBS - 0.2.0](https://network.pivotal.io/products/build-service/) (not yet GA, but very soon)
* [Tanzu Kubernetes Grid Integrated edition - 1.7.1](https://network.pivotal.io/products/pivotal-container-service/) - Provides Kubernetes 1.16.7
* [kapp-controller - 0.9.0](https://github.com/k14s/kapp-controller)
* [Spring Petclinic](https://github.com/spring-projects/spring-petclinic)
* [Helm - 3.3.0](https://github.com/helm/helm/releases/tag/v3.3.0)
* git

*NOTE: Both TBS and KC are moving fast. Likely this workshop is already out of date!*

Not required but convenient:

* [kubens](https://github.com/ahmetb/kubectx)
* [Github CLI](https://github.com/cli/cli)
* [arkade](https://github.com/alexellis/arkade)

#### Install the gh CLI

On Ubuntu:

```
wget https://github.com/cli/cli/releases/download/v0.11.1/gh_0.11.1_linux_amd64.deb
sudo dpkg -i gh_0.11.1_linux_amd64.deb
```

Now `gh` should be available.

```
$ which gh
/usr/local/bin/gh
```

### Conventions Used

* `SNIP!` - Some output removed for brevity
* `kubectl` is often aliased to `k` for less typing, `alias k=kubectl`

## Workshop

#### Create a Github Personal Access Token

Go to:

```
github -> settings -> developer settings -> personal access tokens -> generate new token
```

Call it something like `pipeline workshop` and give it all "repo" permissions as show below. 

![personal access token settings](/img/personal-access-token-permissions.jpg)

Copy that token as it will be used in the Concourse credentials file as well as with the `gh` CLI.

### Fork and Clone the Spring Petclinic Application

This assumes you have the github cli, `gh`, installed, but can easily be done from the github web interface as well, of course.

```
$ gh --version
gh version 0.11.1 (2020-07-28)
https://github.com/cli/cli/releases/tag/v0.11.1
```

Create a Github personal access token and set then environment variable `GITHUB_TOKEN` so that `gh` can use it.

```
export GITHUB_TOKEN=YOUR_TOKEN
```

Fork the repo.

```
gh repo fork spring-projects/spring-petclinic --clone
```

e.g output:

```
$ gh repo fork spring-projects/spring-petclinic --clone
- Forking spring-projects/spring-petclinic...
✓ Created fork ccollicutt/spring-petclinic
Cloning into 'spring-petclinic'...
remote: Enumerating objects: 8498, done.
remote: Total 8498 (delta 0), reused 0 (delta 0), pack-reused 8498
Receiving objects: 100% (8498/8498), 7.25 MiB | 8.56 MiB/s, done.
Resolving deltas: 100% (3229/3229), done.
Updating upstream
From https://github.com/spring-projects/spring-petclinic
 * [new branch]      gh-pages   -> upstream/gh-pages
 * [new branch]      main       -> upstream/main
 * [new branch]      wavefront  -> upstream/wavefront
✓ Cloned fork
```

Change directories into spring-petclinic.

```
cd spring-petclinic
```

Create testing and staging branches in your forked Spring Petclinic repository.

*NOTE: Without the testing and staging branches setup, Concourse won't be able to pull them into the pipeline.*

```
git checkout -b testing
git push origin testing
git checkout -b staging
git push origin staging
```

e.g. output:

```
$ git push origin testing
Total 0 (delta 0), reused 0 (delta 0)
remote: 
remote: Create a pull request for 'testing' on GitHub by visiting:
remote:      https://github.com/ccollicutt/spring-petclinic/pull/new/testing
remote: 
To github.com:ccollicutt/spring-petclinic.git
 * [new branch]      testing -> testing
$ git checkout -b staging
Switched to a new branch 'staging'
$ git push origin staging
Total 0 (delta 0), reused 0 (delta 0)
remote: 
remote: Create a pull request for 'staging' on GitHub by visiting:
remote:      https://github.com/ccollicutt/spring-petclinic/pull/new/staging
remote: 
To github.com:ccollicutt/spring-petclinic.git
 * [new branch]      staging -> staging
```

### Fork and Clone the Workshop Repository

```
gh repo fork ccollicutt/tanzu-kubernetes-pipeline-demo --clone
```

cd into the repository.

```
cd tanzu-kubernetes-pipeline-demo
```

### Use Concourse as the Continuous Integration System

Concourse will be used as the glue that binds Spring Petclinic, Tanzu Build Service, and Kapp controller together. Concourse will take the commits, run the Spring Petclinic tests, and if the tests pass then promote the code to staging where TBS and Kapp controller will pick them up and (re)deploy the new version of Spring Petclinic into Kubernetes.

This section of the workshop is loosely based on [this Tanzu blog post](https://tanzu.vmware.com/developer/guides/ci-cd/concourse-gs/).

#### Install Concourse

Ensure that helm version 3 is available.

If you installed `arkade` you can get `helm` with:

```
ark get helm
```

This is the version we are using below.

```
helm version
```

e.g. output:

```
$ helm version
version.BuildInfo{Version:"v3.3.0-rc.2", GitCommit:"8a4aeec08d67a7b84472007529e8097ec3742105", GitTreeState:"dirty", GoVersion:"go1.14.6"}
```

Create a Concourse namespace and switch to that context.

```
kubectl create ns concourse
kubens concourse
```

Copy the example `concourse/install/values.yml.example` file.

```
cp concourse/install/values.yml.example concourse/install/values.yml
```

Configure the externalUrl for Concourse. This will be the URL used to access Concourse.

*NOTE: This is required for proper authentication.*

e.g command, where you would replace "concourse.example.com" with your host name.

```
sed -i 's|CONCOURSE_HOSTNAME|concourse.example.com|' concourse/install/values.yml
```

We'd expect to see something like the below in the `values.yml` file after running that command.

```
$ grep externalUrl concourse/install/values.yml 
    externalUrl: http://concourse.example.com:8080
```

*NOTE: Ensure that there is a default storage class!*

Create a namespace.

```
kubectl create ns concourse-install
```

Setup the Concourse helm chart repository.

```
helm repo add concourse https://concourse-charts.storage.googleapis.com/
```

e.g. output:

```
$ helm repo add concourse https://concourse-charts.storage.googleapis.com/
"concourse" has been added to your repositories
```

Install concourse.

*NOTE: This can take a few minutes to complete.*

```
helm install concourse concourse/concourse -f concourse/install/values.yml
```

e.g. output:

```
$ helm install concourse concourse/concourse -f concourse/install/values.yml
NAME: concourse
LAST DEPLOYED: Fri Aug 14 07:20:06 2020
NAMESPACE: concourse
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
* Concourse can be accessed:

  * Within your cluster, at the following DNS name at port 8080:

    concourse-web.concourse.svc.cluster.local

  * From outside the cluster, run these commands in the same shell:
SNIP!
```

Once it has deployed there should be four pods running.

```
kubectl get pods
```

e.g. output:

```
$ k get pods
NAME                             READY   STATUS    RESTARTS   AGE
concourse-postgresql-0           1/1     Running   0          108s
concourse-web-7dccf798cf-2chrn   1/1     Running   0          108s
concourse-worker-0               1/1     Running   0          108s
concourse-worker-1               1/1     Running   0          106s
```

And there should be a load balancer IP for the `concourse-web` service.

```
kubectl get svc
```

e.g output:

```
$ k get svc
NAME                            TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
concourse-postgresql            ClusterIP      10.100.200.137   <none>        5432/TCP         2m34s
concourse-postgresql-headless   ClusterIP      None             <none>        5432/TCP         2m34s
concourse-web                   LoadBalancer   10.100.200.203   10.3.1.155    8080:32009/TCP   2m34s
concourse-web-worker-gateway    ClusterIP      10.100.200.79    <none>        2222/TCP         2m34s
concourse-worker                ClusterIP      None             <none>        <none>           2m34s
```

Add the load balancer IP to DNS or `/etc/hosts`. Replace the IP and hostname with your own respectively.

*NOTE: If you are running this in a corporate lab, the DNS entries could be added to the lab DNS server with an appropriate hostname.*

```
echo "LOADBALANCER_IP CONCOURSE_HOSTNAME" | sudo tee -a /etc/hosts
```

e.g command:

```
echo "10.3.1.155 concourse.example.com" | sudo tee -a /etc/hosts
```

Now access http://CONCOURSE_HOSTNAME:8080 in your browser and login with the username `test` and the password `test`.

*NOTE: As this is just a workshop there is no https access configured.*

![concourse web interface](/img/concourse-web.jpg)

Concourse is now installed! That was easy!

#### Install Fly CLI

The `fly` CLI is used to interact with Concourse can be downloaded directly from the Concourse web interface.

*NOTE: If you changed the hostname of the Concourse instance, ensure you also change it in the wget command. Please also note the quotes around the URL.*

*NOTE: Other platform binaries are available, such as Windows and OSX. This example uses the Linux binary.*

```
wget "http://concourse.example.com:8080/api/v1/cli?arch=amd64&platform=linux" -O /usr/local/bin/fly
```

`fly` should now be available.

```
fly --version
```

e.g. output:

```
$ fly --version
6.4.1
```

#### Create Concourse Credentials File

Copy the example file.

```
cp concourse/pipelines/credentials.yml.example concourse/pipelines/credentials.yml
```

Edit that file and change the github repository user name and add in the personal access token from github.

#### Configure and Test the Concourse Pipeline

Now that Concourse is running, a pipeline can be initialized.

Login to Concourse.

```
fly --target demo login --concourse-url http://concourse.example.com:8080 -u test -p test
```

e.g. output:

```
$ fly --target demo login --concourse-url http://concourse.example.com:8080 -u test -p test
logging in to team 'main'


target saved
```

Create the pipeline.

*NOTE: fly will check if you want to make changes to the pipeline. Select yes.*

```
fly -t demo set-pipeline -c concourse/pipelines/pipeline.yml -p petclinic-tests -l concourse/pipelines/credentials.yml
```

Unpause the pipeline. All pipelines start out paused.

```
fly -t demo unpause-pipeline -p petclinic-tests
```

Run the pipeline.

*NOTE: The maven tests can take ~20 minutes to run.*

```
fly -t demo trigger-job -j petclinic-tests/maven-test
```

e.g. output:

```
$ fly -t demo trigger-job -j petclinic-tests/maven-test
started petclinic-tests/maven-test #1
```

To show the pipeline visually access this URL:

```
http://YOUR_CONCOURSE_HOSTNAME:8080/teams/main/pipelines/petclinic-tests
```

If you click on the pipeline you should be brought to a page similar to the below.

![concourse maven test pipeline](/img/concourse-maven-test.jpg)

Watch the pipeline logs.

```
fly -t demo watch -j petclinic-tests/maven-test
```

e.g. output:

```
$ fly -t demo watch -j petclinic-tests/maven-test
Cloning into '/tmp/build/get'...
9412569 welcome concourse
Cloning into '/tmp/build/get'...
9412569 welcome concourse
initializing
running test-scripts/concourse/test-scripts/unit-test.sh
Everything up-to-date
succeeded
```

### Use TBS to Build the Spring Petclinic Container Image

#### Install the Tanzu Build Service

Follow the [Tanzu Build Service install instructions](https://docs.pivotal.io/build-service/1-0/installing.html#pks-install) for installing on TKGI.

#### Configure TBS to Build the Spring Petclinic Container Image from Source

This assumes TBS has been installed and proper docker hub credentials have been configured. 

For example, here are my docker hub and github secrets.

*NOTE: In this example an SSH key as the authentication method for TBS.*

```
$ kp secret list
NAME                   TARGET
default-token-npfkv    
my-dockerhub-creds     https://index.docker.io/v1/
my-git-ssh-cred        git@github.com
```

```
kp secret create dockerhub-creds --dockerhub ccollicutttanzu
```

e.g. output:

```
$ kp secret create dockerhub-creds --dockerhub ccollicutttanzu
dockerhub password: 
"dockerhub-creds" created
```

Create github ssh key.

```
kp secret create GIT-SSH-CREDENTIALS --git-url GIT-SSH-URL --git-ssh-key /tmp/PRIVATE-SSH-KEY
```

e.g. command:

```
kp secret create github-ssh-key --git-url git@github.com --git-ssh-key /home/ubuntu/.ssh/tbs-key
```

Create the image.

*NOTE: We're using the `testing` branch.*

```
kp image create spring-petclinic --tag YOUR_DOCKER_HUB_USER/spring-petclinic --git git@github.com:YOUR_GITHUB_USER/spring-petclinic.git --git-revision testing
```

e.g. command:

```
kp image create spring-petclinic --tag ccollicutttanzu/spring-petclinic --git git@github.com:ccollicutt-tanzu/spring-petclinic.git --git-revision testing
```

Review the logs as the image is being built.

```
kp build logs spring-petclinic
```

e.g. logs output:

```
$ kp build logs spring-petclinic
===> PREPARE
Loading secret for "https://index.docker.io/v1/" from secret "my-dockerhub-creds" at location "/var/build-secrets/my-dockerhub-creds"
Loading secrets for "git@github.com" from secret "my-git-ssh-cred"
Successfully cloned "git@github.com:ccollicutt/spring-petclinic.git" @ "c42f95980a943634106e7584575c053265906978" in path "/workspace"
===> DETECT
6 of 32 buildpacks participating
paketo-buildpacks/bellsoft-liberica 2.7.4
paketo-buildpacks/maven             1.4.4
SNIP!
```

It will take a few minutes to build, perhaps depending on how fast Maven artifacts can be downloaded to the Kubernetes cluster.

Once that image has built, you can see it in Kubernetes as an `img` CRD.

```
kubectl get img
```

e.g. output:

```
$ kubectl get img
NAME               LATESTIMAGE                                                                                                                READY
spring-petclinic   index.docker.io/ccollicutttanzu/spring-petclinic@sha256:d7cf6ec99d46effa052d548f7b6b930fe0c8f3dc61a864a287548b8b879add94   True
```

With that, we've now built an image.

List the builds.

```
kp build list spring-petclinic
```

e.g. output:

```
$ kp build list spring-petclinic
BUILD    STATUS     IMAGE                                                                                                                       STARTED                FINISHED               REASON
1        SUCCESS    index.docker.io/ccollicutttanzu/spring-petclinic@sha256:017762f9a4c2c35802772a1635063ca5edd346ccbcd9f0d6f005e62fc22ebe36    2020-08-11 20:52:47    2020-08-11 21:03:49    CONFIG

```

We can also force a rebuild with the `trigger` option.

```
kp image trigger spring-petclinic
```

Once that second build completes we should see something like the below when listing builds.

```
$ kp build list spring-petclinic
BUILD    STATUS     IMAGE                                                                                                                       STARTED                FINISHED               REASON
1        SUCCESS    index.docker.io/ccollicutttanzu/spring-petclinic@sha256:017762f9a4c2c35802772a1635063ca5edd346ccbcd9f0d6f005e62fc22ebe36    2020-08-11 20:52:47    2020-08-11 21:03:49    CONFIG
2        SUCCESS    index.docker.io/ccollicutttanzu/spring-petclinic@sha256:52284241107dab9437574b6c392a36f5193d8b3f36bfe2176459779bff227225    2020-08-11 21:05:23    2020-08-11 21:07:28    TRIGGER
```

#### Review TBS Custom Resource Definitions

Take a second to review the Custom Resource Definitions that TBS creates.

```
kubectl get crd | grep kpack | cut -f 1 -d " "
```

e.g. output:

```
$ kubectl get crd | grep kpack | cut -f 1 -d " "
builders.kpack.io
builds.kpack.io
clusterbuilders.kpack.io
clusterstacks.kpack.io
clusterstores.kpack.io
images.kpack.io
sourceresolvers.kpack.io
```

### Use Kapp Controller to Deploy Spring Petclinic Application

Kapp-controller is a powerful tool. Read more about it and other related tools on the [k14s](https://k14s.io) website.

#### Install the Kapp Controller

Deploy kapp-controller.

```
kubectl create -f https://github.com/k14s/kapp-controller/releases/download/v0.9.0/release.yml
```

#### Configure Kapp Controller to Manage Spring Petclinic

First, create a `spring-petclinic` namespace.

```
kubectl create ns spring-petclinic
```

Use that namespace.

```
kubens spring-petclinic
```

Now create a serviceaccount.

```
kubectl create -f spring-petclinic-kapp-controller/spring-petclinic-kubernetes-manifests/spring-petclinic-sa-ns.yml
```

e.g. output:

```
$ kubectl create -f spring-petclinic-kapp-controller/spring-petclinic-kubernetes-manifests/spring-petclinic-sa-ns.yml
serviceaccount/spring-petclinic-ns-sa created
role.rbac.authorization.k8s.io/spring-petclinic-ns-role created
rolebinding.rbac.authorization.k8s.io/spring-petclinic-ns-role-binding created
```

Finally create the kapp app.

```
kubectl create -f spring-petclinic-kapp-controller/spring-petclinic-kubernetes-manifests/spring-petclinic-kapp-controller-app.yml
```

*NOTE: The `spring-petclinic-kapp-controller-app.yml` file is configured to use [this git repo file](https://github.com/ccollicutt/kapp-controller-apps/blob/master/spring-petclinic/config.yml) as the Kubernetes manifest for the Spring Petclinic application.*

Check the app CRD.

```
kubectl get app
```

e.g. output:

```
$ kubectl get app
NAME               DESCRIPTION   SINCE-DEPLOY   AGE
spring-petclinic   Reconciling   16s            19s
```

There should now be a service.

```
$ kubectl get svc
NAME               TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
spring-petclinic   LoadBalancer   10.100.200.19   10.3.1.147    8080:30059/TCP   117s
```

Curl that load balancer IP on port 8080.

```
curl -s EXTERNAL_IP:8080 | grep -i welcome
```

e.g. output:

```
$ curl -s 10.3.1.147:8080 | grep -i welcome
    <h2>Welcome</h2>
```

At this point we've ensured that both TBS and kapp-controller are working, and are setup to manage the Spring Petclinic application. 

#### Review Kapp-controller Custom Resource Definitions

List the associated CRDs.

```
kubectl get crd | grep k14s | cut -f 1 -d " "
```

e.g. output:

```
$ kubectl get crd | grep k14s | cut -f 1 -d " "
apps.kappctrl.k14s.io
```

Describe the CRD.

```
kubectl describe crd app
```

e.g. output:

```
$ kubectl describe crd app
Name:         apps.kappctrl.k14s.io
Namespace:    
Labels:       <none>
Annotations:  <none>
API Version:  apiextensions.k8s.io/v1
Kind:         CustomResourceDefinition
SNIP!
```

### All Together Now!

Now we'll update the Spring Petclinic code and push it to the github repo. 

TBS will see the commit and build a new image.

kapp-controller will note the new image and redeploy the Kubernetes application, automatically.

git push -> TBS builds image -> Kapp-controller redeploys application

#### Update Spring Petclinic Code and Let Concourse Run Tests

Change directories to where ever you cloned Spring Petclinic.

Ensure you are on the testing branch that was created earlier.

```
git checkout testing
```

e.g. output:

```
$ git checkout testing
Switched to branch 'testing'
$ git branch
  main
  staging
* testing
```

Alter the welcome message.

```
sed -i 's|Welcome|Welcome TBS and Kapp-controller|g' ./src/main/resources/messages/messages.properties
```

Check changes with `git diff`.

```
git diff
```

e.g. output:

```
$ git diff
diff --git a/src/main/resources/messages/messages.properties b/src/main/resources/messages/messages.properties
index 173417a..6928b26 100644
--- a/src/main/resources/messages/messages.properties
+++ b/src/main/resources/messages/messages.properties
@@ -1,4 +1,4 @@
-welcome=Welcome
+welcome=Welcome TBS and Kapp-controller
 required=is required
 notFound=has not been found
 duplicate=is already in use
```

Push that change.

```
git add .
git commit -m "change welcome message"
git push -u origin testing
```

Concourse should pickup that change and run the `maven-test` pipeline.

*NOTE: It may take a minute or two to pickup the change.*

![concourse picks up change](/img/concourse-build-2.jpg)

#### Watch TBS and Kapp-controller Redeploy the Application

List the TBS builds.

*NOTE: Ensure you are in the same namespace as you were when you created the TBS image.*

```
kp build list spring-petclinic
```

e.g output:

```
$ kp build list spring-petclinic
BUILD    STATUS      IMAGE                                                                                                                       STARTED                FINISHED               REASON
1        SUCCESS     index.docker.io/ccollicutttanzu/spring-petclinic@sha256:017762f9a4c2c35802772a1635063ca5edd346ccbcd9f0d6f005e62fc22ebe36    2020-08-11 20:52:47    2020-08-11 21:03:49    CONFIG
2        SUCCESS     index.docker.io/ccollicutttanzu/spring-petclinic@sha256:52284241107dab9437574b6c392a36f5193d8b3f36bfe2176459779bff227225    2020-08-11 21:05:23    2020-08-11 21:07:28    TRIGGER
3        BUILDING                                                                                                                                2020-08-11 21:22:05                           COMMIT

```

Once the new image is pushed to docker hub, kapp-controller will redeploy the application.

Kapp-controller will find the new image and deploy it. Below we can see that the spring-petclinic pod is being recreated.

```
$ k get pods
NAME                                       READY   STATUS              RESTARTS   AGE
spring-petclinic-7db49ff97f-rz5sh          1/1     Running             0          15m
spring-petclinic-94b6bc66-wwcl2            0/1     ContainerCreating   0          8s
spring-petclinic-build-1-zwrmb-build-pod   0/1     Completed           0          32m
spring-petclinic-build-2-msfs9-build-pod   0/1     Completed           0          19m
spring-petclinic-build-3-blf5p-build-pod   0/1     Completed           0          2m50s
```

Once the new image is deployed, we can check the altered welcome message again buy curling the load balancer IP on 8080.

e.g. output:

```
$ curl -s 10.3.1.147:8080  | grep -i welcome
    <h2>Welcome TBS and Kapp-controller</h2>
```

## Conclusion

In this demo we have set up Concourse, TBS, and Kapp-controller such that when a commit is made to Spring Petclinic on the testing branch it's tested, and if the tests pass merged onto staging, at which point a new image will be built and deployed automatically.

In real world production situations it's unlikely that the "latest" tag would be used to determine what is in production and the Spring Petclinic Kubernetes manifest would be updated with a specific, likely immutable, image tag. But, this workshop was not meant to mimic real-world situations, and instead give a basic introduction to TBS and Kapp-controller working together to deploy an application into Kubernetes.

## Clean Up

Delete the concourse install.

*NOTE: This will take a minute or two to complete. Once it does there should be no pods running in the concourse namespace.*

```
helm uninstall concourse
```

Remove the associated volume claims.

```
kubectl delete pvc concourse-work-dir-concourse-worker-0 -n concourse 
kubectl delete pvc concourse-work-dir-concourse-worker-1 -n concourse
kubectl delete pvc data-concourse-postgresql-0 -n concourse
```

Remove kapp-controller config for Spring Petclinic.

```
kubectl delete -f spring-petclinic-kapp-controller/spring-petclinic-kubernetes-manifests/spring-petclinic-kapp-controller-app.yml
```

Remove the serviceaccount.

```
kubectl delete -f spring-petclinic-kapp-controller/spring-petclinic-kubernetes-manifests/spring-petclinic-sa-ns.yml
```

Delete the TBS image.

```
kp delete image spring-petclinic
```

Delete the TBS secrets.

```
kp secret delete my-dockerhub-creds
kp secret delete my-git-ssh-cred
```

Remove kapp-controller.

```
kubectl delete -f https://github.com/k14s/kapp-controller/releases/download/v0.9.0/release.yml
```

Remove the Spring Petclinic repo.

```
rm -rf /tmp/spring-petclinic
```

Remove the spring-petclinic namespace.

```
kubectl delete ns spring-petclinic
```

Delete your Spring Petclinic fork from github.




