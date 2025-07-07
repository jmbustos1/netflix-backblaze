# Imagen base con Go
FROM golang:1.21-alpine AS builder

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar el código fuente
COPY main.go .

# Compilar el binario de la aplicación
RUN go build -o server main.go

# Imagen final ligera
FROM alpine:latest

# Establecer el directorio de trabajo
WORKDIR /root/

# Copiar el binario desde la imagen anterior
COPY --from=builder /app/server .

# Exponer el puerto TCP 8080
EXPOSE 8080

# Ejecutar el servidor TCP
CMD ["./server"]
