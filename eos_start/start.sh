 
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
 
#导入系统合约账号的公私钥，各个系统合约账号可以公用1个公私钥
#Private key: 5JA1vvr5mvZWVS1DPLQZ8mAAVmZ6ep3LgYDvVrDuMsgcnh9Epbz
#Public key: EOS7dPCmmkvAz4G91ZDGvxQCaR7CWCNvD9pwP7MUBkttXH7jBYc1R
${ROOTPATH}${CLSGT} wallet import --private-key 5JA1vvr5mvZWVS1DPLQZ8mAAVmZ6ep3LgYDvVrDuMsgcnh9Epbz

#创建系统合约账户
EOSIO_PRODUCER_KEY="$( jq -r '.EOSIO_PRODUCER_PUB_KEY' "00_CONFIG.conf" )"
SYSTEM_ACCOUNT=($( jq -r '.SYSTEM_ACCOUNT' "00_CONFIG.conf" ))

# creatin eosio.msig, eosio.token, etc
for sa in "${SYSTEM_ACCOUNT[@]}"
do
    ${ROOTPATH}${CLSGT} create account eosio $sa $EOSIO_PRODUCER_KEY $EOSIO_PRODUCER_KEY -p eosio
done


#部署合约
CONTRACTS_FOLDER=/root/yta326/YTBP/build/contracts
${ROOTPATH}${CLSGT} set contract eosio.token $CONTRACTS_FOLDER/eosio.token -p eosio.token

${ROOTPATH}${CLSGT} set contract eosio.msig $CONTRACTS_FOLDER/eosio.msig -p eosio.msig

#创建 JUNGLE代币
${ROOTPATH}${CLSGT} push action eosio.token create '["eosio", "10000000000.0000 YTA", 0, 0, 0]' -p eosio.token
#发行 YTA代币
${ROOTPATH}${CLSGT} push action eosio.token issue '["eosio",  "1000000000.0000 YTA", "init"]' -p eosio

${ROOTPATH}${CLSGT} push action eosio.token create '["eosio", "1000000000.0000 JUNGLE", 0, 0, 0]' -p eosio.token
${ROOTPATH}${CLSGT} push action eosio.token issue '["eosio", "1000000000.0000 JUNGLE", "init"]' -p eosio

#资源类合约
${ROOTPATH}${CLSGT} set contract eosio $CONTRACTS_FOLDER/eosio.system -p eosio

${ROOTPATH}${CLSGT} push action eosio setpriv '["eosio.msig",1]' -p eosio

##################创建账户NEW_ACCOUNT_NAME begin#############
#账号少于13个字符，只能包括如下字符.12345abcdefghijklmnopqrstuvwxyz
INIT_ACCOUNT=sgtaccout123
echo 'creating key,  key saved to '${ROOTPATH}${LOGDIR}/${INIT_ACCOUNT}'_key.log'
${ROOTPATH}${CLSGT} create key --file ${ROOTPATH}${LOGDIR}/${INIT_ACCOUNT}'_key.log'

echo 'wallet import private key'
awk 'BEGIN {FS=" "} {if ($1 ~ "Private") {print $3}}'  ${ROOTPATH}${LOGDIR}/${INIT_ACCOUNT}'_key.log'|${ROOTPATH}${CLSGT} wallet import --private-key

echo 'create accout '${INIT_ACCOUNT}
INIT_PUB_KEY=`awk 'BEGIN {FS=" "} {if ($1 ~ "Public") {print $3}}'  ${ROOTPATH}${LOGDIR}/${INIT_ACCOUNT}'_key.log'`
echo ${INIT_ACCOUNT}' public_key is '${INIT_PUB_KEY}
#${ROOTPATH}${CLSGT} create account eosio ${INIT_ACCOUNT} ${INIT_PUB_KEY} ${INIT_PUB_KEY}  -p eosio

#esio给INIT_ACCOUNT分配资源，并创建INIT_ACCOUNT账户
${ROOTPATH}${CLSGT} system newaccount --stake-net "200000000.0000 YTA" --stake-cpu "200000000.0000 YTA" --buy-ram "10000.0000 YTA" eosio ${INIT_ACCOUNT} ${INIT_PUB_KEY} ${INIT_PUB_KEY} -p eosio
sleep 1s
##################创建账户NEW_ACCOUNT_NAME end#############

#eosio给INIT_ACCOUNT转账
${ROOTPATH}${CLSGT} transfer eosio $INIT_ACCOUNT  "300000000.0000 YTA" "init"

#查账户的资产
${ROOTPATH}${CLSGT} get table eosio.token ${INIT_ACCOUNT} accounts
${ROOTPATH}${CLSGT} get table eosio.token eosio accounts

#查账户的资源cpu，net，ram
${ROOTPATH}${CLSGT} get account ${INIT_ACCOUNT}

