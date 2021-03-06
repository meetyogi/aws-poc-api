# This is a multi-stage build. First we are going to compile and then
# create a small image for runtime.
ARG ACCOUNT_ID
FROM ${ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/docker-golang-base:latest as builder

ENV GO111MODULE on

RUN mkdir -p /go/src/github.com/compute-example-api
WORKDIR /go/src/github.com/compute-example-api
RUN useradd -u 10001 app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

FROM scratch

COPY --from=builder /go/src/github.com/compute-example-api/main /main
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/ssl/certs /etc/ssl/certs
USER app

EXPOSE 8080
CMD ["/main"]
