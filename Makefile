build-webapi:
	cd webapi && docker build -t anbossar.azurecr.io/prom-webapi:latest .
	kubectl rollout restart deployment webapi


build-hello-func:
	cd hello-func  && docker build -t anbossar.azurecr.io/prom-func-app:latest .
	kubectl rollout restart deployment hello-func