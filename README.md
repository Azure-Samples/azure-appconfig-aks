# Azure Developer CLI template: Configure AKS workload with Azure App Configuration

## Prerequisites

- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- [Azure Developer CLI](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)
- [Visual Studio Code](https://code.visualstudio.com/download)
- [AKS Developer Extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.aks-devx-tools)

## What is included in this repository

The repository hosts of the following components:

- Azure Developer CLI configuration

To understand more about the Azure Developer CLI architecture and to create a similar template, you can refer to [Make your project compatible with Azure Developer CLI](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/make-azd-compatible?pivots=azd-create).

### Azure Developer CLI configuration

The template uses Bicep and the [Azure Developer CLI](https://learn.microsoft.com/azure/developer/azure-developer-cli/overview) (`azd`). The [azure.yaml](./azure.yaml) schema defines and describes the apps and types of Azure resources that are included in these templates.

The following infrastructure resources defined as Bicep templates in the `infra` folder are created:

- Azure Kubernetes Service (AKS) cluster
- Azure Container Registry
- Azure App Configuration

The template uses the following [event hooks](https://learn.microsoft.com/azure/developer/azure-developer-cli/azd-extensibility) to customize the workflow:

- [predeploy](./infra/azd-hooks/predeploy.sh) to install additional cluster components (Azure App Configuration Kubernetes Provider).

## Initializing the template

If you are starting from this end state repo, use `azd init` to clone this template locally.

```sh
mkdir my-app
cd my-app
azd init -t https://github.com/sabbour/aks-app-template
```

## Deploying infrastructure

Deploy the infrastructure by running `azd provision`.

```sh
azd provision
```

You will be prompted for the following information:

- `Environment Name`: This will be used as a prefix for the resource group that will be created to hold all Azure resources. This name should be unique within your Azure subscription.
- `Azure Subscription`: The Azure Subscription where your resources will be deployed.
- `Azure Location`: The Azure location where your resources will be deployed.

You can monitor the progress in the terminal and on the Azure portal. After a few minutes, you should see the resources deployed in your subscription.


## Updating application source 

This template deploys a simple demo ASP.NET web application to the AKS cluster. If you want to deploy your own application, you can replace the following content with your own:

- You should put your source code in the `src\app\src` folder.
- You should put your source configuration in the `src\app\config` folder.
- You should put your Kubernetes manifests in the `src\app\manifests` folder.

## Deploying the application

Running `azd deploy` will build the applications defined in [azure.yaml](./azure.yaml) by running a Docker build then the Azure Developer CLI will tag and push the images to the Azure Container Registry. Each deployment creates a new image tag that is used during the token replacement.

```sh
azd deploy
```

Azure Developer CLI will also apply the Kubernetes manifests in the path configured in [azure.yaml](./azure.yaml). The `name` specified in [azure.yaml](./azure.yaml) will correspond to the Kubernetes namespace that will be created on the cluster where all resources will be deployed to.

While applying the manifests, the Azure Developer CLI will also perform a token replacement for the placeholders defined in the Kubernetes manifests to insert the container image location and App Configuration endpoint.

## Clean up

To clean up resources that were deployed to your subscription, run `azd down`.
