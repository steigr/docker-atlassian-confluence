IMAGE    ?= steigr/atlassian-confluence
VERSION  ?= $(shell git branch | grep \* | cut -d ' ' -f2)
PORT     ?= 8090
BASE     ?= steigr/tomcat:latest

all: image
	@true

image:
	@sed 's#^FROM .*#FROM $(BASE)#' Dockerfile > Dockerfile.build
	[[ "$(NO_PULL)" ]] || docker pull $$(grep ^FROM Dockerfile.build | awk '{print $$2}')
	docker build --tag=$(IMAGE):$(VERSION) --file=Dockerfile.build .
	@rm Dockerfile.build

run: image
	docker run --rm --publish=$(PORT):$(PORT) --name=$(shell basename $(IMAGE)) --env=CONFLUENCE_STUCK_DETECTION_THRESHOLD=300 --env=CATALINA_CONNECTOR_$(PORT)_upgrade=http2 $(IMAGE):$(VERSION)
