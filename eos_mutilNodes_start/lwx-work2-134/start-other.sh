 
 #!/bin/bash

CLSGT=clSGT
NODSGT=nodSGT
KSGTD=kSGTd
ROOTPRIVATEKEY=5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3
ROOTPATH=./
LOGDIR=sgtlog
WALLTPATH=~/eosio-wallet
DATAPATH=/eos
EOSIO_TOKEN_CONTRACTS_PATH=/root/yta326/YTBP/build/contracts/eosio.token

#kill掉进程KSGTD NODSGT
ps -ef|grep ${ROOTPATH}${KSGTD}|awk 'BEGIN {FS=" "} {if ($8 ~ "'${ROOTPATH}${KSGTD}'") {print $2}}'|xargs kill -9
ps -ef|grep ${ROOTPATH}${NODSGT}|awk 'BEGIN {FS=" "} {if ($8 ~ "'${ROOTPATH}${NODSGT}'") {print $2}}'|xargs kill -9


#删除存放日志的文件夹
echo 'remove '${ROOTPATH}${LOGDIR}
if [ -d ${ROOTPATH}${LOGDIR} ];then
   rm -rf ${ROOTPATH}${LOGDIR}   
fi
mkdir -p  ${ROOTPATH}${LOGDIR}

#启动钱包
#echo 'remove '${WALLTPATH}
#if [ -d ${WALLTPATH} ];then
#   rm -rf ${WALLTPATH}
#fi

#echo ${ROOTPATH}${KSGTD}' starting, waiting'
#${ROOTPATH}${KSGTD} >> ${ROOTPATH}${LOGDIR}/${KSGTD}.log 2>&1 &
#sleep 3s

#启动nodsgt
echo 'remove '${DATAPATH}
if [ -d ${DATAPATH} ];then
   rm -rf ${DATAPATH}
fi

echo ${ROOTPATH}${NODSGT}' starting, waiting'
${ROOTPATH}${NODSGT} -d /eos/contracts/eosio/data \
                               --config-dir ./config.ini \
                               --access-control-allow-origin=* \
                               --contracts-console \
                               --http-validate-host=false —filter-on=‘*’ >> ${ROOTPATH}${LOGDIR}/${NODSGT}.log 2>&1 &

sleep 10s



