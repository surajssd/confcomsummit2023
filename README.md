# Model Inferencing in Peer pods

## Model Owner Side

### Download (train / generate) the Models

For the sake of this demo the model files are checked into this repository in the [models](configs/models) directory.

### Encrypt the Models

Run the following script which will tar a folder, generate a symmetric key and encrypt the tar file with that key.

```bash
export SYMMETRIC_KEY_FILE="key.bin"
export SOURCE_FOLDER="configs/models"
export TARGET_ENCRYPTED_FILE="configs/models.tar.gz.enc"

./configs/scripts/encrypt-folder.sh
```

### Upload the Encrypted Models

Replace the following environment variables with your own values:

```bash
export AZURE_RESOURCE_GROUP=""
export AZURE_REGION="eastus"
export STORAGE_ACCOUNT_NAME=""
export STORAGE_CONTAINER_NAME="encrypted"
```

Create the Azure Resource Group:

> **Note**: Skip this step if you already have a resource group.

```bash
az group create \
    --name "${AZURE_RESOURCE_GROUP}" \
    --location "${AZURE_REGION}"
```

Create the Azure Storage Account which allows public anonymous access:

> **Note**: Public access is only enabled for the sake of the demo.

```bash
az storage account create \
    --name "${STORAGE_ACCOUNT_NAME}" \
    --resource-group "${AZURE_RESOURCE_GROUP}" \
    --location "${AZURE_REGION}" \
    --sku Standard_LRS \
    --allow-blob-public-access true
```

Create the Azure Storage Container:

```bash
az storage container create \
    --name "${STORAGE_CONTAINER_NAME}" \
    --account-name "${STORAGE_ACCOUNT_NAME}" \
    --public-access blob \
    --auth-mode login
```

Upload the encrypted file to Azure Storage:

```bash
az storage blob upload \
    --account-name "${STORAGE_ACCOUNT_NAME}" \
    --container-name "${STORAGE_CONTAINER_NAME}" \
    --name "${TARGET_ENCRYPTED_FILE}" \
    --file "${TARGET_ENCRYPTED_FILE}"
```

Provide this download URL when deploying the workload:

```bash
export ENCRYPTED_FILE_URL="https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/${STORAGE_CONTAINER_NAME}/${TARGET_ENCRYPTED_FILE}"
```

## Build init-container

Build the init container, or use the default container image:

```bash
cd configs/initcontainer/
./build-push.sh
```

## Install

### Peerpods on AKS

Follow [this documentation](https://github.com/confidential-containers/cloud-api-adaptor/tree/main/azure) to install the peerpods on AKS.

### KBS

Follow [this documentation](https://github.com/confidential-containers/kbs/tree/main/config/kubernetes) to install KBS on Kubernetes.

> **Note**: Ensure that you copy the encryption key file over so that KBS can serve the key.


### Application

**Update Application Deployment File**

Before deploying the application we need to update the [`deployment.yaml`](configs/kubernetes/deployment.yaml) file.

As the KBS is deployed successfully in the previous step run the following command to figure out the IP address of the KBS service:

```bash
kubectl get pods -o wide -n coco-tenant
```

Provide that as a value for the environment variable: `KBS_URL` in the following format: `http://10.244.0.67:8080`.

**KBS Resource ID**

The value of the env var `KBS_RESOURCE_ID` should match the value provided while deploying KBS. An example value will look like: `/models/keys/key.bin`.

**Encrypted File URL**

Update the env var `ENCRYPTED_FILE_URL` with the value we got after uploading the encrypted model from before.

**Ingress URL**

Run the following command to get the cluster specific DNS zone.

```bash
az aks show --resource-group "${AZURE_RESOURCE_GROUP}" \
    --name "${CLUSTER_NAME}" \
    --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName -o table
```

From the output of the above command update the host field of the `Ingress`.

**Install Application**

Install the application by running the following command:

```bash
kubectl apply -f configs/kubernetes/deployment.yaml
```

### Testing Application

Download the client application to be able to talk to the triton server:

```bash
git clone git@github.com:triton-inference-server/client.git
cd client/src/python/examples
```

Google an image of a cat and download it locally and store it in `/tmp/cat`. Now to run the inferencing run the following command:

```bash
python image_client.py \
    -m densenet_onnx \
    -c 3 -s INCEPTION /tmp/cat \
    -u triton.a6ecc31aa89e4bf889d5.eastus.aksapp.io
```

## Watch recording

[![Alt text](https://img.youtube.com/vi/UOQZKiMCu00/0.jpg)](https://www.youtube.com/watch?v=UOQZKiMCu00)
