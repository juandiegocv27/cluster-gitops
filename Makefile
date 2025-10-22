SHELL := /usr/bin/env bash
CLUSTER := shopstack

.PHONY: cluster-up cluster-down repeat-test verify

cluster-up:
	@echo "Creating kind cluster..."
	time kind create cluster --name $(CLUSTER) --config kind-config.yaml

cluster-down:
	@echo "Deleting kind cluster..."
	time kind delete cluster --name $(CLUSTER)

verify:
	kubectl get nodes
	kubectl get pods -n kube-system | grep coredns || true

repeat-test:
	@echo "=== Run 1 ===" | tee repeat.log
	$(MAKE) cluster-down || true | tee -a repeat.log
	$(MAKE) cluster-up    | tee -a repeat.log
	$(MAKE) verify        | tee -a repeat.log
	$(MAKE) cluster-down  | tee -a repeat.log
	@echo "=== Run 2 ===" | tee -a repeat.log
	$(MAKE) cluster-up    | tee -a repeat.log
	$(MAKE) verify        | tee -a repeat.log
	$(MAKE) cluster-down  | tee -a repeat.log
