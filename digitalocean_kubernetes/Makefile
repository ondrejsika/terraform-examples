kubeconfig-add:
	terraform output -raw kubeconfig > kubeconfig.yml
	slu k8s config add -p kubeconfig.yml
