FROM golang:alpine as builder

RUN apk update && apk add git && apk add ca-certificates

WORKDIR /go/src/github.com/anhthii/go-echo


RUN go get github.com/golang/dep/cmd/dep

COPY Gopkg.lock Gopkg.toml /go/src/github.com/anhthii/go-echo/

# Install library dependencies
RUN dep ensure -vendor-only

COPY . /go/src/github.com/anhthii/go-echo

RUN go build -o webserver main.go


FROM alpine:latest

RUN apk update && \
    apk upgrade --update-cache --available

RUN apk add --no-cache bash

COPY ./docker/ca-certificates.crt /etc/ssl/certs/

WORKDIR /usr/app/go-echo

COPY --from=builder /go/src/github.com/anhthii/go-echo/webserver /go/src/github.com/anhthii/go-echo/.env ./

COPY ./docker/wait-for-it.sh /wait-for-it.sh

RUN chmod +x /wait-for-it.sh

EXPOSE 3000

CMD ["./webserver"]
