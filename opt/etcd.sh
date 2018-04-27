#!/bin/bash

APP=etcd
set -ex;
docker rm $APP || echo "not found $APP";
docker run  -d \
 --name $APP \
 -p 2379:2379 \
 -v /data/etcdv3:/data \
registry.cn-beijing.aliyuncs.com/wa/etcd:v3.3 /usr/local/bin/etcd \
 --name=eeeee \
 --data-dir=/data \
 --listen-client-urls=http://0.0.0.0:2379 \
 --advertise-client-urls=http://0.0.0.0:2379
