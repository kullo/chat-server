.PHONY: default generate-xcodeproj generate-linuxmain linuxtest pull-docker-image docker-build deploy-staging deploy-live

default: linuxtest

generate-xcodeproj:
	swift package generate-xcodeproj
	#ruby bin/configure-xcodeproj.rb

generate-linuxmain:
	sourcery --sources Tests --templates assets/LinuxMain.stencil --output Tests

linuxtest: generate-linuxmain
	docker run --rm --volume "$(shell pwd):/app" --workdir "/app" kullo/swiftbuild swift test

linuxbuild:
	docker run --rm --volume "$(shell pwd):/app" --workdir "/app" kullo/swiftbuild swift build -c release

pull-docker-image:
	docker pull kullo/swiftbuild:latest

docker-build:
	docker build .

deploy-staging: pull-docker-image
	docker build -t registry.heroku.com/kullo-chat-staging/web:latest .
	docker push registry.heroku.com/kullo-chat-staging/web:latest

deploy-live: pull-docker-image
	docker build -t registry.heroku.com/kullo-chat/web:latest .
	docker push registry.heroku.com/kullo-chat/web:latest
