.PHONY: django postgres dockerup api dockerdown

next:
	docker exec -it netflix-next-container /bin/sh
go:
	docker exec -it netflix-golang-container /bin/sh

postgres:
	docker exec -it conergie-postgres /bin/bash

api:
	docker exec -it conergie-api-1 /bin/bash

dockerup:
	sudo docker compose -f docker-compose-local.yml up

dockerdown:
	sudo docker compose -f docker-compose-local.yml down

migrate-up:
	docker exec -it netflix-golang-container migrate -path /app/db/migrations -database "postgres://postgres:password@netflix-postgres:5432/netflix?sslmode=disable" up

migrate-down:
	docker exec -it netflix-golang-container migrate -path /app/db/migrations -database "postgres://postgres:password@netflix-postgres:5432/netflix?sslmode=disable" down

build-no-cache:
	docker compose -f docker-compose-local.yml build --no-cache

dropdb-and-container:
	docker compose -f docker-compose-local.yml down -v

seed:
	docker compose exec netflix-backend-server go run ./cmd/seed