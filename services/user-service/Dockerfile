FROM golang:1.24 AS build

WORKDIR /app
COPY . .
RUN go build -o user-service .

FROM gcr.io/distroless/base-debian11
COPY --from=build /app/user-service /user-service
CMD ["/user-service"]
