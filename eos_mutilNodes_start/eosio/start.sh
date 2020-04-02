 
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
${ROOTPATH}${NODSGT} -e -p eosio -d /eos/contracts/eosio/data \
                               --config-dir ./ \
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
echo "---------------创建系统账户开始--------------------"
EOSIO_PRODUCER_KEY="$( jq -r '.EOSIO_PRODUCER_PUB_KEY' "00_CONFIG.conf" )"
SYSTEM_ACCOUNT=($( jq -r '.SYSTEM_ACCOUNT' "00_CONFIG.conf" ))
echo "EOSIO_PRODUCER_KEY[${EOSIO_PRODUCER_KEY}]"
echo "SYSTEM_ACCOUNT[${SYSTEM_ACCOUNT}]"
# creatin eosio.msig, eosio.token, etc
for sa in "${SYSTEM_ACCOUNT[@]}"
do
    ${ROOTPATH}${CLSGT} create account eosio $sa $EOSIO_PRODUCER_KEY $EOSIO_PRODUCER_KEY -p eosio
done
echo "---------------创建系统账户结束--------------------"

#将6个用户的私钥导入钱包
${ROOTPATH}${CLSGT} wallet import  --private-key 5KLGj1HGRWbk5xNmoKfrcrQHXvcVJBPdAckoiJgFftXSJjLPp7b
${ROOTPATH}${CLSGT} wallet import  --private-key 5K6qk1KaCYYWX86UhAfUsbMwhGPUqrqHrZEQDjs9ekP5j6LgHUu
${ROOTPATH}${CLSGT} wallet import  --private-key 5JCStvbRgUZ6hjyfUiUaxt5iU3HP6zC1kwx3W7SweaEGvs4EPfQ
${ROOTPATH}${CLSGT} wallet import  --private-key 5JtUScZK2XEp3g9gh7F8bwtPTRAkASmNrrftmx4AxDKD5K4zDnr
${ROOTPATH}${CLSGT} wallet import  --private-key 5JUNYmkJ5wVmtVY8x9A1KKzYe9UWLZ4Fq1hzGZxfwfzJB8jkw6u
${ROOTPATH}${CLSGT} wallet import  --private-key 5K6LU8aVpBq9vJsnpCvaHCcyYwzPPKXfDdyefYyAMMs3Qy42fUr

#部署合约
CONTRACTS_FOLDER=/root/yta326/YTBP/build/contracts
${ROOTPATH}${CLSGT} set contract eosio.token $CONTRACTS_FOLDER/eosio.token -p eosio.token

${ROOTPATH}${CLSGT} set contract eosio.msig $CONTRACTS_FOLDER/eosio.msig -p eosio.msig

#创建 YTA代币                                               1000000000
${ROOTPATH}${CLSGT} push action eosio.token create '["eosio", "1000000000.0000 YTA", 0, 0, 0]' -p eosio.token
#发行 YTA代币
${ROOTPATH}${CLSGT} push action eosio.token issue '["eosio",  "1000000000.0000 YTA", "init"]' -p eosio

#${ROOTPATH}${CLSGT} push action eosio.token create '["eosio", "1000000000.0000 JUNGLE", 0, 0, 0]' -p eosio.token
#${ROOTPATH}${CLSGT} push action eosio.token issue '["eosio", "1000000000.0000 JUNGLE", "init"]' -p eosio

#部署资源类合约
${ROOTPATH}${CLSGT} set contract eosio $CONTRACTS_FOLDER/eosio.system -p eosio

${ROOTPATH}${CLSGT} push action eosio setpriv '["eosio.msig",1]' -p eosio


echo "---------------创建生产账户开始--------------------"
#create and transfer to producer
${ROOTPATH}${CLSGT} system newaccount --stake-net "100000000.0000 YTA" --stake-cpu "100000000.0000 YTA" --buy-ram "20000.0000 YTA"  eosio lwz EOS8imf2TDq6FKtLZ8mvXPWcd6EF2rQwo8zKdLNzsbU9EiMSt9Lwz EOS8imf2TDq6FKtLZ8mvXPWcd6EF2rQwo8zKdLNzsbU9EiMSt9Lwz -p eosio
${ROOTPATH}${CLSGT} transfer eosio lwz "20000.0000 YTA" "init"

${ROOTPATH}${CLSGT} system newaccount --stake-net "100000000.0000 YTA" --stake-cpu "100000000.0000 YTA" --buy-ram "20000.0000 YTA" eosio hml EOS7Ef4kuyTbXbtSPP5Bgethvo6pbitpuEz2RMWhXb8LXxEgcR7MC  EOS7Ef4kuyTbXbtSPP5Bgethvo6pbitpuEz2RMWhXb8LXxEgcR7MC  -p eosio 
${ROOTPATH}${CLSGT} transfer eosio hml "20000.0000 YTA" "init"

${ROOTPATH}${CLSGT} system newaccount --stake-net "100000000.0000 YTA" --stake-cpu "100000000.0000 YTA" --buy-ram "20000.0000 YTA" eosio lx EOS5n442Qz4yVc4LbdPCDnxNSseAiUCrNjRxAfPhUvM8tWS5svid6  EOS5n442Qz4yVc4LbdPCDnxNSseAiUCrNjRxAfPhUvM8tWS5svid6  -p eosio  
${ROOTPATH}${CLSGT} transfer eosio lx "20000.0000 YTA" "init"
echo "---------------创建生产账户结束--------------------"
#create and transfer to user
${ROOTPATH}${CLSGT} system newaccount --stake-net "50000000.0000 YTA" --stake-cpu "50000000.0000 YTA" --buy-ram "20000.0000 YTA" eosio usera EOS69X3383RzBZj41k73CSjUNXM5MYGpnDxyPnWUKPEtYQmTBWz4D  EOS69X3383RzBZj41k73CSjUNXM5MYGpnDxyPnWUKPEtYQmTBWz4D  -p eosio  
${ROOTPATH}${CLSGT} transfer eosio usera "20000.0000 YTA" "init"

${ROOTPATH}${CLSGT} system newaccount --stake-net "50000000.0000 YTA" --stake-cpu "50000000.0000 YTA" --buy-ram "20000.0000 YTA" eosio userb EOS7yBtksm8Kkg85r4in4uCbfN77uRwe82apM8jjbhFVDgEgz3w8S EOS7yBtksm8Kkg85r4in4uCbfN77uRwe82apM8jjbhFVDgEgz3w8S  -p eosio  
${ROOTPATH}${CLSGT} transfer eosio userb "20000.0000 YTA" "init"

${ROOTPATH}${CLSGT} system newaccount --stake-net "50000000.0000 YTA" --stake-cpu "50000000.0000 YTA" --buy-ram "20000.0000 YTA" eosio userc EOS7WnhaKwHpbSidYuh2DF1qAExTRUtPEdZCaZqt75cKcixuQUtdA  EOS7WnhaKwHpbSidYuh2DF1qAExTRUtPEdZCaZqt75cKcixuQUtdA   -p eosio
${ROOTPATH}${CLSGT} transfer eosio userc "20000.0000 YTA" "init"

#############启动3个生产节点
echo "请启动3个生产节点"


