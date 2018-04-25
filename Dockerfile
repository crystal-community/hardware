FROM crystallang/crystal:latest

ADD . /src
WORKDIR /src
RUN shards install

CMD ["crystal", "spec"]
