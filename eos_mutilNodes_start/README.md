
使用了四台同网段的主机，第一台做为eosio创世用户使用，另外三台做为出块者节点使用，最终实现了EOS多主机多节点的配置。
最后EOSIO创世用户不再出块，由选举出来的各个节点轮流出块，


一、EOSIO节点修改内容
enable-stale-production = true

带有0.0.0.0的IP换成主机IP地址；
producer-name 换成自己节点的名称；
producer key 写上自己节点的私匙对；
agent-name最好参照修改下，暂时不知道其作用；
p2p-peer-address 可以添加很多个，表示本节点与其它多个节点进行通信，进行区块同步；


二、非EOSIO节点修改内容
enable-stale-production = false
带有0.0.0.0的IP换成主机IP地址；
producer-name 换成自己节点的名称；
producer key 写上自己节点的私匙对；
agent-name最好参照修改下，暂时不知道其作用；
p2p-peer-address 可以添加很多个，表示本节点与其它多个节点进行通信，进行区块同步；


//producers
//lwz
    "LWZ_PRIV_KEY": 5KLGj1HGRWbk5xNmoKfrcrQHXvcVJBPdAckoiJgFftXSJjLPp7b
    "LWZ_PUB_KEY": EOS8imf2TDq6FKtLZ8mvXPWcd6EF2rQwo8zKdLNzsbU9EiMSt9Lwz

    
//hml
    "HML_PRIV_KEY": 5K6qk1KaCYYWX86UhAfUsbMwhGPUqrqHrZEQDjs9ekP5j6LgHUu
    "HML_PUB_KEY": EOS7Ef4kuyTbXbtSPP5Bgethvo6pbitpuEz2RMWhXb8LXxEgcR7MC

//lx
    "LX_PRIV_KEY": 5JCStvbRgUZ6hjyfUiUaxt5iU3HP6zC1kwx3W7SweaEGvs4EPfQ
    "LX_PUB_KEY": EOS5n442Qz4yVc4LbdPCDnxNSseAiUCrNjRxAfPhUvM8tWS5svid6

//users
//usera
    "USERA_PRIV_KEY": 5JtUScZK2XEp3g9gh7F8bwtPTRAkASmNrrftmx4AxDKD5K4zDnr
    "USERA_PUB_KEY": EOS69X3383RzBZj41k73CSjUNXM5MYGpnDxyPnWUKPEtYQmTBWz4D

//userb
    "USERB_PRIV_KEY": 5JUNYmkJ5wVmtVY8x9A1KKzYe9UWLZ4Fq1hzGZxfwfzJB8jkw6u
    "USERB_PUB_KEY": EOS7yBtksm8Kkg85r4in4uCbfN77uRwe82apM8jjbhFVDgEgz3w8S

//userc
    "USERC_PRIV_KEY": 5K6LU8aVpBq9vJsnpCvaHCcyYwzPPKXfDdyefYyAMMs3Qy42fUr
    "USERC_PUB_KEY": EOS7WnhaKwHpbSidYuh2DF1qAExTRUtPEdZCaZqt75cKcixuQUtdA