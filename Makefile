SHELL := /bin/bash

# By default, Make treats all targets as files; unless you specify that targets 
# are commands, the instructions will be skipped if a file with the target’s name exists.
# More info: https://www.gnu.org/software/make/manual/make.html#Phony-Targets
.PHONY: apply-releases apply-releases-with-cpp-api destroy-releases

# Deploys all releases described in helmfile.yaml.gotmpl with the original to-dos-api.
deploy-with-nestjs-api:
	@export DEPLOY_DATABASE=false && \
	helmfile cache cleanup && helmfile --environment local --namespace local -f deploy/helmfile.yaml.gotmpl apply

# Deploys all releases described in helmfile.yaml.gotmpl with the C++ version of to-dos-api.
# NOTE: If DEPLOY_DATABASE is set to false, to-dos-api-cpp will not be able 
# to start because the initContainer will not be able to apply the migrations.
deploy-with-cpp-api:
	@export DEPLOY_DATABASE=true && \
	export TO_DOS_API_REPO=to-dos-api-cpp && \
	helmfile cache cleanup && helmfile --environment local --namespace local -f deploy/helmfile.yaml.gotmpl apply

# Destroys all releases described in helmfile.yaml.gotmpl.
# NOTE: If DEPLOY_DATABASE is set to false, the database release will 
# not be included in helmfile.yaml.gotmpl and will not be cleaned up.
destroy:
	@export DEPLOY_DATABASE=true && \
	helmfile cache cleanup && helmfile --environment local --namespace local -f deploy/helmfile.yaml.gotmpl destroy