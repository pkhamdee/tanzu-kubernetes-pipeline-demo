# Tanzu Build Service and Kapp Controller Workshop

<!--ts-->
   * [Tanzu Build Service and Kapp Controller Workshop](#tanzu-build-service-and-kapp-controller-workshop)
      * [Overview](#overview)
         * [About Tanzu Build Service](#about-tanzu-build-service)
         * [About Kapp-controller](#about-kapp-controller)
      * [Architecture Diagram](#architecture-diagram)
      * [Requirements](#requirements)
      * [Tested Software and Versions](#tested-software-and-versions)
      * [Workshop](#workshop)
         * [Clone Workshop Repository](#clone-workshop-repository)
         * [Fork Spring Petclinic](#fork-spring-petclinic)
         * [Use TBS to Build the Spring Petclinic Container Image](#use-tbs-to-build-the-spring-petclinic-container-image)
            * [Install the TBS](#install-the-tbs)
            * [Configure TBS to Build the Spring Petclinic Container Image from Source](#configure-tbs-to-build-the-spring-petclinic-container-image-from-source)
            * [Review TBS Custom Resource Definitions](#review-tbs-custom-resource-definitions)
         * [Use Kapp Controller to Deploy Spring Petclinic Application](#use-kapp-controller-to-deploy-spring-petclinic-application)
            * [Install the Kapp Controller](#install-the-kapp-controller)
            * [Configure Kapp Controller to Manage Spring Petclinic](#configure-kapp-controller-to-manage-spring-petclinic)
            * [Review Kapp-controller Custom Resource Definitions](#review-kapp-controller-custom-resource-definitions)
         * [All Together Now!](#all-together-now)
            * [Update Spring Petclinic Code](#update-spring-petclinic-code)
            * [Watch TBS and Kapp-controller Redeploy the Application](#watch-tbs-and-kapp-controller-redeploy-the-application)
      * [Conclusion](#conclusion)
      * [Clean Up](#clean-up)
<!--te-->

## Overview

The goal of this workshop is to combine the [Tanzu Build Service](https://tanzu.vmware.com/build-service) aka TBS (based on the upstream open source system [kpack](https://github.com/pivotal/kpack)) with the [kapp-controller](https://github.com/k14s/kapp-controller) to build images and automatically use those images in Kubernetes deployments. TBS builds the images from source and kapp-controller redeploys the apps based on those images.

The goal of this short workshop is not to show what would happen in production, but rather how TBS and kapp-controller can work well together to manage Kubernetes applications, and to do so using Custom Resource Definitions (CRDs) that become part of the Kubernetes API. Thus, when building and deploying applications with TBS and kapp-controller it's actually all done through Kubernetes.

### About Tanzu Build Service

Tanzu Build Service (TBS) allows you to build, maintain, and update portable OCI images.

>Consistently create production-ready container images that run on Kubernetes and across clouds. Automate source-to-container workflows across all your development frameworks.

### About Kapp-controller

Kapp-controller is part of the [k14s](https://k14s.io/) set of tools which take a modular approach to managing modern applications in container environments.

>kapp controller provides a way to specify which applications should run on your K8s cluster via one or more App CRs. It will install, and continiously apply updates.

## Architecture Diagram

![Achitecture Diagram](/img/arch.jpg)

*NOTE: Github and Docker Hub are used in this workshop because they are easily accessible. Most container image registries and git repositories would also work just fine.*

## Requirements

1. A kubernetes cluster that supports Kubernetes load balancers
1. TBS installed into that cluster, and is working
2. A docker hub account
3. A github account
4. Assumes the use of a Linux terminal

A Kubernetes cluster with load balancer support is not strictly necessary, but, for this workshop, the Spring Petclinic Kubernetes manifest is configured to use one.

*NOTE: You may want to create temporary accounts on docker hub and github, as your credentials will be used by TBS for both.*

## Tested Software and Versions

Required:

* [TBS - 0.2.0](https://network.pivotal.io/products/build-service/) (not yet GA, but very soon)
* [Tanzu Kubernetes Grid Integrated edition - 1.7.1](https://network.pivotal.io/products/pivotal-container-service/)
* [kapp-controller - 0.9.0](https://github.com/k14s/kapp-controller)
* [Spring Petclinic](https://github.com/spring-projects/spring-petclinic)

*NOTE: Both TBS and KC are moving fast. Likely this workshop is already out of date!*

Not required but convenient:

* [kubens](https://github.com/ahmetb/kubectx)
* [Github CLI](https://github.com/cli/cli)

## Workshop

### Clone Workshop Repository

```
git clone https://github.com/ccollicutt/tanzu-build-service-and-kapp-controller-workshop
```

cd into the repository.

```
cd tanzu-build-service-and-kapp-controller-workshop
```

### Fork Spring Petclinic

This assumes you have the github cli, `gh`, installed, but can easily be done from the github web interface as well, of course.

```
$ gh --version
gh version 0.11.1 (2020-07-28)
https://github.com/cli/cli/releases/tag/v0.11.1
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

### Use TBS to Build the Spring Petclinic Container Image


#### Install the TBS

For now, see [this blog post](https://tanzu.vmware.com/build-service). TBS is not yet GA, but when it is we will update these instructions to include installation. That said, if you follow the linked blog post you will be able to install TBS using Duffle.

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

Create the image.

*NOTE: We're using `main` not `master`.*

```
kp image create spring-petclinic YOUR_DOCKER_HUB_USER/spring-petclinic --git git@github.com:YOUR_GITHUB_USER/spring-petclinic.git --git-revision main
```

e.g. command:

```
kp image create spring-petclinic ccollicutttanzu/spring-petclinic --git git@github.com:ccollicutt/spring-petclinic.git --git-revision main
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

Take a second to review the Custom Resource Defintions that TBS creates.

```
kubectl get crd | grep pivotal | cut -f 1 -d " "
```

e.g. output:

```
$ kubectl get crd | grep pivotal | cut -f 1 -d " "
builders.build.pivotal.io
builds.build.pivotal.io
clusterbuilders.build.pivotal.io
custombuilders.experimental.kpack.pivotal.io
customclusterbuilders.experimental.kpack.pivotal.io
images.build.pivotal.io
sourceresolvers.build.pivotal.io
stacks.experimental.kpack.pivotal.io
stores.experimental.kpack.pivotal.io
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
kubectl create -f spring-petlinic-kapp-controller/spring-petclinic-kubernetes-manifests/spring-petclinic-sa-ns.yml
```

e.g. output:

```
$ kubectl create -f spring-petlinic-kapp-controller/spring-petclinic-kubernetes-manifests/spring-petclinic-sa-ns.yml
serviceaccount/spring-petclinic-ns-sa created
role.rbac.authorization.k8s.io/spring-petclinic-ns-role created
rolebinding.rbac.authorization.k8s.io/spring-petclinic-ns-role-binding created
```

Finally create the kapp app.

```
kubectl create -f spring-petlinic-kapp-controller/spring-petclinic-kubernetes-manifests/spring-petclinic-kapp-controller-app.yml
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

#### Update Spring Petclinic Code

```
cd /tmp
git clone https://github.com/YOUR_GITHUB_USER/spring-petclinic.git
```

e.g output:

```
git clone https://github.com/ccollicutt/spring-petclinic
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

*NOTE: Remember main!*

```
git add .
git commit -m "change welcome message"
git push -u origin main
```

TBS should now pickup that new code and build a new image.

*NOTE: It may take a minute or two to pickup the change.*

#### Watch TBS and Kapp-controller Redeploy the Application

List the TBS builds.

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

In this demo we have set up TBS and Kapp-controller such that when a commit is made to Spring Petclinic on the main branch it a new image will be built and deployed automatically, using Kubernetes Custom Resource Definitions. 

In real world production situations it's unlikely that the "latest" tag would be used to determine what is in production and the Spring Petclinic Kubernetes manifest would be updated with a specific, likely immutable, image tag. But, this workshop was not meant to mimic real-world situations, and instead give a basic introduction to TBS and Kapp-controller working together to deploy an application into Kubernetes.

## Clean Up

Remove kapp-controller config for Spring Petclinic.

```
kubectl delete -f spring-petlinic-kapp-controller/spring-petclinic-kubernetes-manifests/spring-petclinic-kapp-controller-app.yml
```

Remove the serviceaccount.

```
kubectl delete -f spring-petlinic-kapp-controller/spring-petclinic-kubernetes-manifests/spring-petclinic-sa-ns.yml
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




