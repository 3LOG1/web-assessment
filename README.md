# web-assessment

#$Directory Structure
── app
│   ├── Dockerfile
│   └── index.jsp
├── chart
│   ├── Chart.yaml
│   ├── templates
│   │   ├── configmap.yaml
│   │   ├── deployment.yaml
│   │   ├── ingress.yaml
│   │   └── service.yaml
│   └── values.yaml
├── k8-setup.local
└── README.md

3 directories, 10 files




## Build & push image to docker HUB
cd app
docker build -t syamlogi/http_app:11025-v1 .
docker login (Provide creds)
docker push syamlogi/http_app:11025-v1




#Provision VM using kubeadm , Installation and configuration explained in k8-setup.local
#Install Helm for K8s Package management

wget https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz
tar -xvf  helm-v3.12.0-linux-amd64.tar.gz
mv linux-amd64/helm /usr/localbin/



## Install http web application 

#Place the chart folder and execute below command

helm upgrade --install web ./chart -n demo --create-namespace --set appMessage="hello-world"

#Test
root@controlplane:/tmp/Assesment# ls chart
Chart.yaml  templates  values.yaml


root@controlplane:/tmp/Assesment# ls -ld chart
drwxrwxr-x 3 root root 4096 Nov  2 09:03 chart



root@controlplane:/tmp/Assesment# helm upgrade --install web ./chart -n demo --create-namespace --set appMessage="hello-world"
Release "web" does not exist. Installing it now.
NAME: web
LAST DEPLOYED: Sun Nov  2 11:44:10 2025
NAMESPACE: demo
STATUS: deployed
REVISION: 1
TEST SUITE: None



#==========================message=============================================================
root@controlplane:/tmp/Assesment# curl -H "Host: web.example.com" http://192.168.1.74:31067/version
{"message":"hello-world"}
root@controlplane:/tmp/Assesment# 

#=============================================================================================

#Rollout 

helm upgrade web ./chart -n demo --set appMessage="hola"

#Test-2


root@controlplane:/tmp/Assesment# helm upgrade web ./chart -n demo --set appMessage="hola"
Release "web" has been upgraded. Happy Helming!
NAME: web
LAST DEPLOYED: Sun Nov  2 11:51:03 2025
NAMESPACE: demo
STATUS: deployed
REVISION: 4
TEST SUITE: None



root@controlplane:/tmp/Assesment# kubectl rollout status deploy/web -n demo
Waiting for deployment "web" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "web" rollout to finish: 1 old replicas are pending termination...
deployment "web" successfully rolled out




root@controlplane:/tmp/Assesment# kubectl get pods  -n demo
NAME                   READY   STATUS        RESTARTS   AGE
web-7f57c7cdf9-9xs59   1/1     Running       0          16s
web-7f57c7cdf9-drrft   1/1     Running       0          34s
web-7f57c7cdf9-wrcw6   1/1     Running       0          25s
web-b9f8dd5b6-798dt    1/1     Terminating   0          107s
web-b9f8dd5b6-7z5db    1/1     Terminating   0          94s
web-b9f8dd5b6-flxbt    1/1     Terminating   0          116s




#====================================meassage===============================================


curl -H "Host: web.example.com" http://192.168.1.74:31067/version
{"message":"hola"}
root@controlplane:/tmp/Assesment# 



#==========================================================================================

#Other Ways to test


# Port-forward to test
kubectl port-forward svc/web 8080:80 -n demo &

$ curl http://127.0.0.1:8080/version
{"message":"hello-world"}


## Update message via Helm (trigger rolling update)
helm upgrade web ./chart -n demo --set appMessage="hola"


$ kubectl rollout status deploy/web -n demo
deployment "web" successfully rolled out


$ curl http://127.0.0.1:8080/version
{"message":"hola"}





## Confirm rolling update
# show pods (new pod names)


$ kubectl get pods -n demo --selector=app=web -o custom-columns=NAME:.metadata.name,START:.status.startTime
NAME                   START
web-7f57c7cdf9-9xs59   2025-11-02T06:21:23Z
web-7f57c7cdf9-drrft   2025-11-02T06:21:05Z
web-7f57c7cdf9-wrcw6   2025-11-02T06:21:14Z



$ kubectl get deployment web -n demo -o=jsonpath='{.spec.template.metadata.annotations}'
{"checksum/config":"809468dec4c76c69002ce68f45d80cd513fec99b3f847b4493f25990d1f725c4"}

root@controlplane:/tmp/Assesment# 



kubectl get rs -n demo

NAME             DESIRED   CURRENT   READY   AGE
web-5dd4b56dbf   0         0         0       12m
web-7f57c7cdf9   3         3         3       8m6s
web-b9f8dd5b6    0         0         0       6m56s
