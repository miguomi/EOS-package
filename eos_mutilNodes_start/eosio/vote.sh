
#将所有需要出块的节点（配置文件中 producer-name = lwx)
${ROOTPATH}${CLSGT} system regproducer lwz EOS8imf2TDq6FKtLZ8mvXPWcd6EF2rQwo8zKdLNzsbU9EiMSt9Lwz  http://127.0.0.1:8888
${ROOTPATH}${CLSGT} system regproducer hml EOS7Ef4kuyTbXbtSPP5Bgethvo6pbitpuEz2RMWhXb8LXxEgcR7MC  http://127.0.0.1:8888
${ROOTPATH}${CLSGT} system regproducer lx EOS5n442Qz4yVc4LbdPCDnxNSseAiUCrNjRxAfPhUvM8tWS5svid6  http://127.0.0.1:8888

#分别使用usera,userb,userc给节点用户lwz,hml,lx进行投票，再次查看投票率
${ROOTPATH}${CLSGT} system voteproducer prods usera lwz  
${ROOTPATH}${CLSGT} system voteproducer prods userb hml 
${ROOTPATH}${CLSGT} system voteproducer prods userc lx 