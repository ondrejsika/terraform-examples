infracost:
	infracost breakdown --path . --show-skipped

kubeconfig-save:
	terraform output -raw kubeconfig > kubeconfig.yml

kubeconfig-add: kubeconfig-save
	slu k8s config add -p kubeconfig.yml
