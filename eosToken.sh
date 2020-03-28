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
echo 'remove '${WALLTPATH}
if [ -d ${WALLTPATH} ];then
   rm -rf ${WALLTPATH}
fi

echo ${ROOTPATH}${KSGTD}' starting, waiting'
${ROOTPATH}${KSGTD} >> ${ROOTPATH}${LOGDIR}/${KSGTD}.log 2>&1 &
sleep 3s

#启动nodsgt
echo 'remove '${DATAPATH}
if [ -d ${DATAPATH} ];then
   rm -rf ${DATAPATH}
fi

echo ${ROOTPATH}${NODSGT}' starting, waiting'
${ROOTPATH}${NODSGT} -e -p eosio --plugin eosio::producer_plugin \
                               --plugin eosio::chain_api_plugin \
                               --plugin eosio::history_api_plugin \
                               --plugin eosio::http_plugin \
                               -d /eos/contracts/eosio/data \
                               --config-dir /eos/contracts/eosio/config \
                               --access-control-allow-origin=* \
                               --contracts-console \
                               --http-validate-host=false —filter-on=‘*’ >> ${ROOTPATH}${LOGDIR}/${NODSGT}.log 2>&1 &

sleep 10s
 

echo 'get  info'
${ROOTPATH}${CLSGT} get info

echo 'wallet creating, password saved to '${ROOTPATH}${LOGDIR}/default_wallet.log
${ROOTPATH}${CLSGT} wallet create --file ${ROOTPATH}${LOGDIR}/default_wallet.log

echo 'wallet import the eosio of private key'
${ROOTPATH}${CLSGT} wallet import --private-key ${ROOTPRIVATEKEY}

echo 'creating key,  key saved to '${ROOTPATH}${LOGDIR}/eosioToken_key.log
${ROOTPATH}${CLSGT} create key --file ${ROOTPATH}${LOGDIR}/eosioToken_key.log

echo 'wallet import private key'
awk 'BEGIN {FS=" "} {if ($1 ~ "Private") {print $3}}'  ${ROOTPATH}${LOGDIR}/eosioToken_key.log|${ROOTPATH}${CLSGT} wallet import --private-key


#创建eosio.token账号
echo 'create accout eosio.token'
PUBLIC_KEY=`awk 'BEGIN {FS=" "} {if ($1 ~ "Public") {print $3}}'  ${ROOTPATH}${LOGDIR}/eosioToken_key.log`
${ROOTPATH}${CLSGT} create account eosio eosio.token ${PUBLIC_KEY} ${PUBLIC_KEY}
sleep 1s

#在eosio.token账户上部署eosio.token合约 
echo 'set contract in accout eosio.token'
${ROOTPATH}${CLSGT} set contract eosio.token ${EOSIO_TOKEN_CONTRACTS_PATH} -p eosio.token
sleep 1s

##################创建账户NEW_ACCOUNT_NAME begin#############
#账号少于13个字符，只能包括如下字符.12345abcdefghijklmnopqrstuvwxyz
NEW_ACCOUNT_NAME=sgtaccout123
echo 'creating key,  key saved to '${ROOTPATH}${LOGDIR}/${NEW_ACCOUNT_NAME}'_key.log'
${ROOTPATH}${CLSGT} create key --file ${ROOTPATH}${LOGDIR}/${NEW_ACCOUNT_NAME}'_key.log'

echo 'wallet import private key'
awk 'BEGIN {FS=" "} {if ($1 ~ "Private") {print $3}}'  ${ROOTPATH}${LOGDIR}/${NEW_ACCOUNT_NAME}'_key.log'|${ROOTPATH}${CLSGT} wallet import --private-key

echo 'create accout '${NEW_ACCOUNT_NAME}
PUBLIC_KEY=`awk 'BEGIN {FS=" "} {if ($1 ~ "Public") {print $3}}'  ${ROOTPATH}${LOGDIR}/${NEW_ACCOUNT_NAME}'_key.log'`
echo ${NEW_ACCOUNT_NAME}' public_key is '${PUBLIC_KEY}
${ROOTPATH}${CLSGT} create account eosio ${NEW_ACCOUNT_NAME} ${PUBLIC_KEY} ${PUBLIC_KEY}
sleep 1s
##################创建账户NEW_ACCOUNT_NAME end#############

echo '创建代币'
${ROOTPATH}${CLSGT} push action eosio.token create '{"issuer":"eosio","maximum_supply":"1000000000.0000 YTA"}' -p eosio.token
sleep 1s

#向NEW_ACCOUNT_NAME账户转100块
echo 'eosio.token tranfer 100 to '${NEW_ACCOUNT_NAME}
${ROOTPATH}${CLSGT} push action eosio.token issue '[ "'${NEW_ACCOUNT_NAME}'", "100.0000 YTA", "helloYTA" ]' -p eosio
sleep 1s

#echo 'query the info of '${NEW_ACCOUNT_NAME}' in eosio.token contract'
#查询NEW_ACCOUNT_NAME在eosio.token合约上的账户信息、余额
${ROOTPATH}${CLSGT} get table eosio.token ${NEW_ACCOUNT_NAME} accounts



 


