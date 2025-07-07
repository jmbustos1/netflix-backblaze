# Dockerfile.dev
FROM golang:1.23-alpine

WORKDIR /app
# Instala curl antes de usarlo
RUN apk add --no-cache curl


# Instala migrate
RUN curl -L https://github.com/golang-migrate/migrate/releases/download/v4.16.2/migrate.linux-amd64.tar.gz \
  | tar xvz && \
  mv migrate /usr/local/bin/migrate

COPY go.mod go.sum ./
RUN go mod download

COPY . .

EXPOSE 8080

CMD ["go", "run", "./cmd/api"]
