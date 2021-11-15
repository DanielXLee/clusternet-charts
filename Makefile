HUB_CHART_NAME ?= clusternet-hub
AGENT_CHART_NAME ?= clusternet-agent
SYNCER_CHART_NAME ?= clusternet-syncer
CHART_VERSION ?= 0.2.0

##@ General

help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Build

.PHONY: build-chart
build-chart: ## Build helm chart package
	helm package -u charts/clusternet-hub
	helm package -u charts/clusternet-agent
	helm package -u charts/clusternet-syncer

.PHONY: lint-chart
lint-chart: ## Verify chart lint error
	helm lint $(HUB_CHART_NAME)-$(CHART_VERSION).tgz
	helm lint $(AGENT_CHART_NAME)-$(CHART_VERSION).tgz
	helm lint $(SYNCER_CHART_NAME)-$(CHART_VERSION).tgz

##@ Development

.PHONY: install-chart
install-chart: build-chart lint-chart ## Install chart for dev test
	helm install $(HUB_CHART_NAME) $(HUB_CHART_NAME)-$(CHART_VERSION).tgz -n clusternet-system --create-namespace --debug
	helm install $(AGENT_CHART_NAME) $(AGENT_CHART_NAME)-$(CHART_VERSION).tgz -n clusternet-system --create-namespace --debug
	helm install $(SYNCER_CHART_NAME) $(SYNCER_CHART_NAME)-$(CHART_VERSION).tgz -n clusternet-system --create-namespace --debug

.PHONY: check-installed
check-installed: ## Check installed chart
	helm list -A
	kubectl get deploy,po -n clusternet-system

.PHONY: uninstall-chart
uninstall-chart: ## Uninstall chart for dev test
	helm uninstall $(AGENT_CHART_NAME) $(HUB_CHART_NAME) $(SYNCER_CHART_NAME) -n clusternet-system --debug

##@ Release

