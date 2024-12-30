# Local Kubernetes Environment

This repo enables running the whole to-dos project stack locally in k8s in Docker.

More info about the project and its related repos can be found here: [to-dos-documentation](https://github.com/TourmalineCore/to-dos-documentation).

## Prerequisites

1. Install Docker
2. Install Visual Studio Code
3. Install Visual Studio Code [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) Extension
3. Install [Lens (commercial)](https://k8slens.dev/) or [OpenLens (open source)](https://github.com/MuhammedKalkan/OpenLens/releases)

## VSCode Dev Container

Open this repo's folder in VSCode, it might immediately propose you to re-open it in a Dev Container or you can click on `Remote Explorer`, find plus button and choose the `Open Current Folder in Container` option and wait when it is ready.

When your Dev Container is ready, the VS Code window will be re-opened. Open a new terminal in this Dev Container which will be executing the commands under this prepared Linux container where we have already pre-installed and pre-configured:
- Docker Outside of Docker aka Docker from Docker to be able to use host's docker daemon from inside the container 
- [kind](https://kind.sigs.k8s.io/) to create a k8s cluster locally in Docker
- [kubectl](https://kubernetes.io/docs/reference/kubectl/) to call k8s cluster from CLI (bypassing Lens)
- [helm, helmfile](https://github.com/helmfile/helmfile) to deploy all services [helm](https://helm.sh/) charts at once to the local k8s cluster created with `kind`
- [helm-diff](https://github.com/databus23/helm-diff) show nicely what has changed since the last `helmfile apply`

>Note: You **don't** need to install these packages in your OS, these are part of the Dev Container already. Thus, it is a clean way to run the stack for any host OS.

## Manage Local k8s Cluster

### Cluster Creation

To create a new cluster where you will work execute the following command **once**:

```bash
kind create cluster --name to-dos --config kind-local-config.yaml --kubeconfig ./.to-dos-cluster-kubeconfig
```

### Cluster Removal

To delete the previously created cluster by any reason execute the following command:

```bash
kind delete cluster --name to-dos
```

### Cluster Connection

Then you should be able to go and grap the created k8s cluster config here in the root of the repo `.to-dos-cluster-kubeconfig` and use it in `Lens` to connect to the cluster.

In `Lens` you can go to `File` -> `Add Cluster` and put there the copied `config` file content and create it.
Then you should be able to connect to it.

### Deployment to Cluster

To deploy the stack to the cluster at the first time or re-deploy it after a change in charts or their configuration execute the following command:

```bash
helmfile cache cleanup && helmfile --environment local --namespace local -f deploy/helmfile.yaml apply
```

When the command is complete and all k8s pods are running inside **`local`** namespace you should be able to navigate to http://localhost:40080/ in your browser and see `Hello World`.

>Note: at the first time this really takes a while.

>Note: `helmfile cache cleanup` is needed to force to re-fetch remote values.yaml files from git repos. Otherwise it will never invalidate them. Links: https://github.com/roboll/helmfile/issues/720#issuecomment-1516613493 and https://helmfile.readthedocs.io/en/latest/#cache.

>Note: if one of your services version was updated e.g. a newer version was published to `to-dos-ui:latest` you won't see the changes executing `helmfile apply` command. Instead you need to remove the respective service Pod that it can be re-created by its Deployment and fetch the latest docker image. 

### Debugging Helm Charts

To see how all charts manifest are going to look like before apply you can execute the following command:

```bash
helmfile cache cleanup && helmfile --environment local --namespace local -f deploy/helmfile.yaml template
```

## Services URLs

- ui: http://localhost:40080/to-dos
- api: http://localhost:40080/api/to-dos-api/api

## Troubleshooting
- OpenLens not showing any pods, deployments, etc.. Make sure the "Namespace" in view "Workloads" is set to "`local`" or "`All namespaces`"

- cannot open http://localhost:40080/
    ```
    This site can’t be reached localhost refused to connect.
    ```
    if you see this in your browser please try to open in Incognito Mode
- cannot install to-dos-ui chart
    ```
    COMBINED OUTPUT:
    Release "to-dos-ui" does not exist. Installing it now.
    coalesce.go:286: warning: cannot overwrite table with non table for nginx.ingress.annotations (map[])
    coalesce.go:286: warning: cannot overwrite table with non table for nginx.ingress.annotations (map[])
    Error: context deadline exceeded
    ```
    if you see this after you try to run `helmfile apply` command, simply retry `helmfile apply` command.
- cannot deploy using helmfile apply
    ```
    Error: Failed to get release to-dos-ui in namespace local: exit status 1: WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /workspaces/to-dos-local-env/.to-dos-cluster-kubeconfig
  WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /workspaces/to-dos-local-env/.to-dos-cluster-kubeconfig
    ```
    Try to delete the cluster docker container and its generated `.to-dos-cluster-kubeconfig` file and then re-open VSCode as an Administrator and redo everything from scratch.

- in case of any other weird issue:
    1. Remove the `to-dos-control-plane` docker container.
    2. Remove the cluster from Lens.
    3. Re-try over starting from `kind create` command.

## Useful Refs used to setup repo

- https://shisho.dev/blog/posts/docker-in-docker/
- https://devopscube.com/run-docker-in-docker/
- https://github.com/kubernetes-sigs/kind/issues/3196
- https://github.com/devcontainers/features
- https://fenyuk.medium.com/helm-for-kubernetes-helmfile-c22d1ab5e604
