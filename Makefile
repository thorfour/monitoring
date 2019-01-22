.PHONY: all clean terraform check-env passwords teardown prometheus teardown-prometheus
all: passwords prometheus

clean:
	rm -f ${PWD}/passwords

terraform:
	docker run \
	   	-i \
	   	-t \
		-v ${PWD}/$(PROJECT):${PWD}/$(PROJECT) \
		-w ${PWD}/$(PROJECT) \
	   	hashicorp/terraform:light init

	docker run \
	   	-i \
	   	-t \
		-v ~/.ssh:/root/.ssh \
		-v ${PWD}/$(PROJECT):${PWD}/$(PROJECT) \
		-w ${PWD}/$(PROJECT) \
	   	hashicorp/terraform:light apply

passwords: check-env
	docker run --rm -it xmartlabs/htpasswd monitor $(MONITOR_PW) > ${PWD}/passwords

check-env:
	@if test -z "$(MONITOR_PW)"; then echo "MONITOR_PW must be set"; exit 1; fi

teardown:
	docker run \
	   	-i \
	   	-t \
		-v ~/.ssh:/root/.ssh \
		-v ${PWD}/$(PROJECT):${PWD}/$(PROJECT) \
		-w ${PWD}/$(PROJECT) \
	   	hashicorp/terraform:light destroy

prometheus: PROJECT=prometheus
prometheus: terraform

teardown-prometheus: PROJECT=prometheus
teardown-prometheus: teardown
