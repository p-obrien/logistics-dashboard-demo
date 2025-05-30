# Stage 1 — build the binary
FROM golang:1.24-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git ca-certificates

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o user-service ./cmd

# Stage 2 — create a lightweight image
FROM alpine:latest

WORKDIR /app

RUN apk --no-cache add ca-certificates
COPY --from=builder /app/user-service .

# Use non-root user
RUN adduser -D -g '' appuser
USER appuser

EXPOSE 8080

ENTRYPOINT ["./user-service"]
