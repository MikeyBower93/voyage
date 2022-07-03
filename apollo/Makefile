APP_NAME ?= `grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g'`
APP_VSN ?= `grep 'version:' mix.exs | cut -d '"' -f2`
BUILD ?= `git rev-parse --short HEAD`

build:
  docker build --build-arg APP_VSN=$(APP_VSN) \
    --build-arg MIX_ENV=prod \
    --build-arg SECRET_KEY_BASE=$(SECRET_KEY_BASE) \
    -t your_ecr_url:$(APP_VSN)-$(BUILD) \
    -t your_ecr_url:latest .

push:
  eval `aws ecr get-login --no-include-email --region eu-west-2`
  docker push your_ecr_url:$(APP_VSN)-$(BUILD)
  docker push your_ecr_url:latest

deploy:
  ./bin/ecs-deploy -c voyage_cluster -n voyage_service -i your_ecr_url:$(APP_VSN)-$(BUILD) -r eu-west-2 -t 300