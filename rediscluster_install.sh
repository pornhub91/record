#！/bin/bash
#docker-compose创建redis集群脚本

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

#redis数据库存放位置
REDIS_PATH=/redis
[ -d ${REDIS_PATH} ] || mkdir ${REDIS_PATH} 
cd ${REDIS_PATH}
[ -d data ] ||  mkdir data
[ -d conf ] ||  mkdir conf
[ -d log ] ||  mkdir log
cd conf  
[ -d 7000 ] || mkdir 7000
[ -d 7001 ] || mkdir 7001
[ -d 7002 ] || mkdir 7002
[ -d 7003 ] || mkdir 7003
[ -d 7004 ] || mkdir 7004
[ -d 7005 ] || mkdir 7005


cat > redis.conf.temp << EOF
#bind 0.0.0.0 127.0.0.1
port 7000
protected-mode no
tcp-backlog 511
timeout 0
tcp-keepalive 300
daemonize yes
supervised no
pidfile /data/redis.pid
loglevel notice
logfile "/var/log/redis.log"
databases 16
always-show-logo yes
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir ./
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 15000
replica-serve-stale-data yes
replica-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
repl-disable-tcp-nodelay no
replica-priority 100
lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
replica-lazy-flush no
appendonly yes
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble yes
lua-time-limit 5000
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
notify-keyspace-events ""
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
stream-node-max-bytes 4096
stream-node-max-entries 100
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit replica 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
dynamic-hz yes
aof-rewrite-incremental-fsync yes
rdb-save-incremental-fsync yes
daemonize no
EOF

for i in `seq 7000 7005`
do
  [ -f ${i}/redis.conf ] || cp  -f  redis.conf.temp  ${i}/redis.conf
  sed -i "s^7000^${i}^g"   ${i}/redis.conf
done


cd ${REDIS_PATH}
docker pull  redis:latest &> /dev/null

cat > docker-compose.yaml << EOF
version: "3"
services: 
    redis-cluster-7000:
        image: redis:latest
        restart: always
        container_name: node00
        ports:
            - "7000:7000"
        volumes:
            - ./conf/7000:/usr/local/etc/redis
            - ./log/7000:/var/log
            - ./data/7000:/data
        command: sh -c "redis-server /usr/local/etc/redis/redis.conf"

    redis-cluster-7001:
        image: redis:latest
        restart: always
        container_name: node01
        ports:
            - "7001:7001"
        volumes:
            - ./conf/7001:/usr/local/etc/redis
            - ./log/7001:/var/log
            - ./data/7001:/data
        command: sh -c "redis-server /usr/local/etc/redis/redis.conf"

    redis-cluster-7002:
        image: redis:latest
        restart: always
        container_name: node02
        ports:
            - "7002:7002"
        volumes:
            - ./conf/7002:/usr/local/etc/redis
            - ./log/7002:/var/log
            - ./data/7002:/data
        command: sh -c "redis-server /usr/local/etc/redis/redis.conf"

    redis-cluster-7003:
        image: redis:latest
        restart: always
        container_name: node03
        ports:
            - "7003:7003"
        volumes:
            - ./conf/7003:/usr/local/etc/redis
            - ./log/7003:/var/log
            - ./data/7003:/data
        command: sh -c "redis-server /usr/local/etc/redis/redis.conf"

    redis-cluster-7004:
        image: redis:latest
        restart: always
        container_name: node04
        ports:
            - "7004:7004"
        volumes:
            - ./conf/7004:/usr/local/etc/redis
            - ./log/7004:/var/log
            - ./data/7004:/data
        command: sh -c "redis-server /usr/local/etc/redis/redis.conf"

    redis-cluster-7005:
        image: redis:latest
        restart: always
        container_name: node05
        ports:
            - "7005:7005"
        volumes:
            - ./conf/7005:/usr/local/etc/redis
            - ./log/7005:/var/log
            - ./data/7005:/data
        command: sh -c "redis-server /usr/local/etc/redis/redis.conf"
EOF

cd ${REDIS_PATH}
docker-compose up -d
sleep 2

if [ $(docker-compose ps | grep node0 | wc -l ) -eq 6 ];then
    echo "redis-cluster is up "
else 
    echo "redis-cluster is down"
    exit 0
fi


echo "安装expect组件"
yum -y install  expect &> /dev/null 
 
NODE00=$(docker inspect node00  | grep '"IPAddress":' |tail -1 | awk -F \" '{print $4}')
NODE01=$(docker inspect node01  | grep '"IPAddress":' |tail -1 | awk -F \" '{print $4}')
NODE02=$(docker inspect node02  | grep '"IPAddress":' |tail -1 | awk -F \" '{print $4}')
NODE03=$(docker inspect node03  | grep '"IPAddress":' |tail -1 | awk -F \" '{print $4}')
NODE04=$(docker inspect node04  | grep '"IPAddress":' |tail -1 | awk -F \" '{print $4}')
NODE05=$(docker inspect node05  | grep '"IPAddress":' |tail -1 | awk -F \" '{print $4}')


expect -c "
  spawn docker exec -it node00  redis-cli --cluster create ${NODE00}:7000   ${NODE01}:7001   ${NODE02}:7002   ${NODE03}:7003   ${NODE04}:7004   ${NODE05}:7005    --cluster-replicas 1
expect {
	\"(type 'yes' to accept):\"  {send "yes\\r";}
}
expect eof "





