#!/bin/bash
MQDIR="/rocketmq"  #MQ存储位置

which docker &>/dev/null
if [ $? -eq 0 ];then
    echo "docker版本为："$(docker --version)
else 
    echo "docker 未安装"
    exit 0
fi

which docker-compose &>/dev/null
if [ $? -eq 0 ];then
    echo "docker-compose版本为："$(docker-compose --version)
else 
    echo "docker-compose 未安装"
    exit 0
fi

[ -d ${MQDIR} ] || mkdir ${MQDIR}
cd ${MQDIR}
[ -d conf ] || mkdir conf
[ -d logs ] || mkdir logs
[ -d store ] || mkdir store
cd conf
[ -d broker-a ] || mkdir broker-a 
[ -d broker-b ] || mkdir broker-b 
[ -d broker-c ] || mkdir broker-c
cat > broker-a/broker-a.properties << EOF
brokerClusterName = rocketmq-cluster
brokerName = broker-a
brokerId = 0
deleteWhen = 04
fileReservedTime = 48
brokerRole = ASYNC_MASTER
flushDiskType = ASYNC_FLUSH
namesrvAddr=rmqnamesrv-a:9876;rmqnamesrv-b:9876;rmqnamesrv-c:9876
autoCreateTopicEnable=true
listenPort = 10911
brokerRole=ASYNC_MASTER
flushDiskType=ASYNC_FLUSH
EOF
cat > broker-b/broker-a.properties << EOF
brokerClusterName = rocketmq-cluster
brokerName = broker-b
brokerId = 0
deleteWhen = 04
fileReservedTime = 48
brokerRole = ASYNC_MASTER
flushDiskType = ASYNC_FLUSH
namesrvAddr=rmqnamesrv-a:9876;rmqnamesrv-b:9876;rmqnamesrv-c:9876
autoCreateTopicEnable=true
listenPort = 10911
brokerRole=ASYNC_MASTER
flushDiskType=ASYNC_FLUSH
EOF
cat > broker-c/broker-a.properties << EOF
brokerClusterName = rocketmq-cluster
brokerName = broker-c
brokerId = 0
deleteWhen = 04
fileReservedTime = 48
brokerRole = ASYNC_MASTER
flushDiskType = ASYNC_FLUSH
namesrvAddr=rmqnamesrv-a:9876;rmqnamesrv-b:9876;rmqnamesrv-c:9876
autoCreateTopicEnable=true
listenPort = 10911
brokerRole=ASYNC_MASTER
flushDiskType=ASYNC_FLUSH
EOF
cd ..
cat > docker-compose.yaml << EOF
version: '3.5'
services:
  rmqnamesrv-a:
    image: rocketmqinc/rocketmq:latest
    container_name: rmqnamesrv-a
    restart: "always"
    ports:
      - 9876:9876
    volumes:
      - ./logs/nameserver-a:/opt/logs
      - ./store/nameserver-a:/opt/store
    command: sh mqnamesrv
    networks:
        rmq:
          aliases:
            - rmqnamesrv-a
 
  rmqnamesrv-b:
    image: rocketmqinc/rocketmq:latest
    container_name: rmqnamesrv-b
    restart: "always"
    ports:
      - 9877:9876
    volumes:
      - ./logs/nameserver-b:/opt/logs
      - ./store/nameserver-b:/opt/store
    command: sh mqnamesrv
    networks:
        rmq:
          aliases:
            - rmqnamesrv-b

  rmqnamesrv-c:
    image: rocketmqinc/rocketmq:latest
    container_name: rmqnamesrv-c
    restart: "always"
    ports:
      - 9878:9876
    volumes:
      - ./logs/nameserver-c:/opt/logs
      - ./store/nameserver-c:/opt/store
    command: sh mqnamesrv
    networks:
        rmq:
          aliases:
            - rmqnamesrv-c

  rmqbroker-a:
    image: rocketmqinc/rocketmq:latest
    container_name: rmqbroker-a
    restart: "always"
    ports:
      - 10911:10911
    volumes:
      - ./logs/broker-a:/opt/logs
      - ./store/broker-a:/opt/store
      - ./conf/broker-a/broker-a.properties:/opt/rocketmq-4.4.0/conf/2m-noslave/broker-a.properties
    environment:
        TZ: Asia/Shanghai
        NAMESRV_ADDR: "rmqnamesrv-a:9876"
        JAVA_OPTS: " -Duser.home=/opt"
        JAVA_OPT_EXT: "-server -Xms256m -Xmx256m -Xmn256m"
    command:  sh mqbroker -c /opt/rocketmq-4.4.0/conf/2m-noslave/broker-a.properties autoCreateTopicEnable=true &
    links:
      - rmqnamesrv-a:rmqnamesrv-a
      - rmqnamesrv-b:rmqnamesrv-b
      - rmqnamesrv-c:rmqnamesrv-c
    networks:
      rmq:
        aliases:
          - rmqbroker-a
 
  rmqbroker-b:
    image: rocketmqinc/rocketmq:latest
    container_name: rmqbroker-b
    restart: "always"
    ports:
      - 10910:10911
    volumes:
      - ./logs/broker-b:/opt/logs
      - ./store/broker-b:/opt/store
      - ./conf/broker-b/broker-a.properties:/opt/rocketmq-4.4.0/conf/2m-noslave/broker-a.properties
    environment:
        TZ: Asia/Shanghai
        NAMESRV_ADDR: "rmqnamesrv-b:9876"
        JAVA_OPTS: " -Duser.home=/opt"
        JAVA_OPT_EXT: "-server -Xms256m -Xmx256m -Xmn256m"
    command:  sh mqbroker -c /opt/rocketmq-4.4.0/conf/2m-noslave/broker-a.properties autoCreateTopicEnable=true &
    links:
      - rmqnamesrv-a:rmqnamesrv-a
      - rmqnamesrv-b:rmqnamesrv-b
      - rmqnamesrv-c:rmqnamesrv-c
    networks:
      rmq:
        aliases:
          - rmqbroker-b

  rmqbroker-c:
    image: rocketmqinc/rocketmq:latest
    container_name: rmqbroker-c
    restart: "always"
    ports:
      - 10909:10911
    volumes:
      - ./logs/broker-c:/opt/logs
      - ./store/broker-c:/opt/store
      - ./conf/broker-c/broker-a.properties:/opt/rocketmq-4.4.0/conf/2m-noslave/broker-a.properties
    environment:
        TZ: Asia/Shanghai
        NAMESRV_ADDR: "rmqnamesrv-c:9876"
        JAVA_OPTS: " -Duser.home=/opt"
        JAVA_OPT_EXT: "-server -Xms256m -Xmx256m -Xmn256m"
    command:  sh mqbroker -c /opt/rocketmq-4.4.0/conf/2m-noslave/broker-a.properties autoCreateTopicEnable=true &
    links:
      - rmqnamesrv-a:rmqnamesrv-a
      - rmqnamesrv-b:rmqnamesrv-b
      - rmqnamesrv-c:rmqnamesrv-c
    networks:
      rmq:
        aliases:
          - rmqbroker-c

  rmqconsole:
    image: styletang/rocketmq-console-ng
    container_name: rmqconsole
    restart: "always"
    ports:
      - 9001:8080
    environment:
        JAVA_OPTS: -Drocketmq.namesrv.addr=rmqnamesrv-a:9876;rmqnamesrv-b:9876;rmqnamesrv-b:9876 -Dcom.rocketmq.sendMessageWithVIPChannel=false
    networks:
      rmq:
        aliases:
          - rmqconsole
networks:
  rmq:
    name: rmq
    driver: bridge
EOF
docker-compose up -d