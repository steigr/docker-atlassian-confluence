IMAGE    ?= steigr/conflunce
VERSION  ?= $(shell git branch | grep \* | cut -d ' ' -f2)
PORT     ?= 8090

all: image
	@true

image:
	docker build --tag=$(IMAGE):$(VERSION) .

run: image
	docker run --rm --publish=$(PORT):$(PORT) --name=confluene --env=CONFLUENCE_STUCK_DETECTION_THRESHOLD=300 --env=CATALINA_CONNECTOR_$(PORT)_upgrade=http2 $(IMAGE):$(VERSION)
