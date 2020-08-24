# zerotier-api-bash
Simple BASH script that forwards requests to the Zerotier API via curl and jq.

## Prerequisites
curl and jq

## Options
    -k ) Zerotier API Key (required, default:$ZT_API KEY)
    -l ) List [network|member|user]
    -n ) Network ID [id] (optional, default:$ZT_NET_ID)
    -m ) Member ID [id] (optional, default:$ZT_DEV_ID)
    -p ) Payload [json] (initiates PUSH request)
    -r ) Request [json path] (initiates GET request)
    -s ) Status
    -S ) Self
    -t ) Token
    -u ) User ID [id]

## Examples
### Authorize Member
#### Specify Network ID and Member ID
    zt_api.sh -k aBcD1eFgH2iJkL3mNoP4qRsT5uVwX6yZ -n=12a34b56c78d90e1 -m=a12b34c56d -p '{"config":{"authorized":true}}'
#### Use ENV variables
    ZT_API_KEY=aBcD1eFgH2iJkL3mNoP4qRsT5uVwX6yZ; ZT_NET_ID=12a34b56c78d90e1; ZT_DEV_ID=a12b34c56d
    zt_api.sh -n -m -p '{"config":{"authorized":true}}'
### Get Member Tags
    zt_api -n -m -r .config.tags[]
### Set Member Tags
    zt_api -n -m -p '{"config":{"tags":["one","two","three"]}}'
