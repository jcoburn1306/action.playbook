FROM golang:alpine as builder

# Set necessary environmet variables needed for our image
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

# Move to working directory /build
WORKDIR /build

# Copy and download dependency using go mod
COPY . .

RUN go mod download

# Build the application
RUN go build -o main 

FROM chocolatey/choco:latest-linux as choco

FROM arillso/ansible:2.12.0 as production


COPY --from=choco usr/local/bin/choco.exe /usr/local/bin

COPY --from=choco usr/local/bin/choco.exe /opt/chocolatey/

# Copy binary from build to main folder
COPY --from=builder /build/main /usr/local/bin

# Run as root
USER root

RUN apk --update --no-cache add \
	mono \
    --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing \
    && mkdir -p /opt/chocolatey/lib

# Command to run when starting the container
CMD ["main"]
