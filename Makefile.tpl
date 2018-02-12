## Internal variables, do not modify:
SHELL 			:= /bin/bash
ECHO 				:= echo -e

KUBE_AWS_VERSION 	=	
WORKDIR		   = $(shell pwd)
KUBECONFIG 	?= $(WORKDIR)/kubeconfig

S3_BUCKET 	 = 
AWS_PROFILE ?= $(shell grep AWS_PROFILE kaws.conf | cut -f2 -d=)

export KUBECONFIG

.PHONY: default all up
default: up
all: up

.PHONY: check-kube-aws
check-kube-aws:
	@if [[ "$$(kube-aws version 2>/dev/null)" != "$(KUBE_AWS_VERSION)" ]]; then \
		$(ECHO) "\033[31mkube-aws not found or incorrect version. Install \033[33m$(KUBE_AWS_VERSION)\033[0m"; \
		exit 1; \
	fi

.PHONY: up
up: check-kube-aws
	AWS_PROFILE=$(AWS_PROFILE) kube-aws up --s3-uri=s3://$(S3_BUCKET)

.PHONY: new-credentials
new-credentials: check-kube-aws
	AWS_PROFILE=$(AWS_PROFILE) kube-aws render credentials --generate-ca

.PHONY: get-credentials
get-credentials: check-kube-aws
	@$(ECHO) "Get the credentials from a secure place, not implemented yet"

.PHONY: down
down: check-kube-aws
	AWS_PROFILE=$(AWS_PROFILE) kube-aws destroy

.PHONY: update
update: check-kube-aws
	AWS_PROFILE=$(AWS_PROFILE) kube-aws update --s3-uri=s3://$(S3_BUCKET)

.PHONY: validate
validate: check-kube-aws
	AWS_PROFILE=$(AWS_PROFILE) kube-aws validate --s3-uri=s3://$(S3_BUCKET)

.PHONY: export
export: check-kube-aws
	AWS_PROFILE=$(AWS_PROFILE) kube-aws up --s3-uri=s3://$(S3_BUCKET) --export --pretty-print

.PHONY: clean
clean:
	rm -rf credentials
	rm -rf exported
	rm -rf stack-templates
	rm -rf userdata
	rm -rf cluster.min.yaml cluster.yaml kaws.conf kubeconfig

.PHONY: test
test:
	@$(ECHO) '\033[93m================================================================================\033[0m'
	kubectl cluster-info
	@$(ECHO) '\033[93m================================================================================\033[0m'
	kubectl get nodes
	@$(ECHO) '\033[93m================================================================================\033[0m'
	kubectl get componentstatuses
	@$(ECHO) '\033[93m================================================================================\033[0m'
	kubectl get services
	@$(ECHO) '\033[93m================================================================================\033[0m'
	kubectl get deployments --namespace=kube-system

.PHONY: ui
ui:
	@$(ECHO) "Open the dashboard at: \033[32mhttp://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/\033[0m"
	@$(ECHO) "Select '\033[32mSkip\033[0m' to login"
	kubectl proxy
