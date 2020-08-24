#!/bin/bash
zt_api() {
    # Clear out any previously set variables
    unset zt_api_url zt_api_key zt_list zt_net_id zt_dev_id zt_api_results zt_api_payload zt_api_request zt_status zt_self zt_token zt_user_id

    ZT_OPTS=$(getopt -o :k:l:m::n::p:r:sSt -- "$@")
    eval set -- "$ZT_OPTS"
    while true ; do
        case "$1" in
            -k ) zt_api_key="${2//[^a-zA-Z0-9]/}"; shift 2;;
            -l ) zt_list="$2"; shift 2;;
            -n ) zt_net_id="${2:-$ZT_NET_ID}"; zt_net_id="${zt_net_id//[^a-zA-Z0-9]/}"; shift 2;;
            -m ) zt_dev_id="${2:-$ZT_DEV_ID}"; zt_dev_id="${zt_dev_id//[^a-zA-Z0-9]/}"; shift 2;;
            -p ) zt_api_payload="$(jq --null-input --compact-output --arg str "$2" '$str')"; shift 2;;
            -r ) zt_api_request="${2//[^a-zA-Z0-9_\[\]\.]/}"; shift 2;;
            -s ) zt_status=1; shift 2;;
            -S ) zt_self=1; shift 2;;
            -t ) zt_token=1; shift 2;;
            -u ) zt_user_id="${2//[^a-zA-Z0-9]/}"; shift 2;;
            -- ) shift; break ;;
            * ) break ;;
        esac
    done

    # Configure URL
    zt_api_url=$ZT_API_URL
    if [ ! -z "$zt_status" ]; then
        zt_api_url+="/status"
    elif [ ! -z "$zt_self" ] ; then
        zt_api_url+="/self"
    elif [ ! -z "$zt_token" ] ; then
        zt_api_url+="/randomToken"
    elif [ ! -z "$zt_list" ]; then
        case $zt_list in
            member ) 
                {
                    if [ -z "$zt_net_id" ]; then zt_net_id="${ZT_NET_ID//[^a-zA-Z0-9]/}"; fi
                    if [ -z "$zt_net_id" ]; then echo "No ZT Network ID." 1>&2; return 0; fi
                    zt_api_url+="/network/$zt_net_id/member"
                } ;;
            * ) zt_api_url+="/$zt_list";;
        esac
    elif [ ! -z "$zt_user_id" ]; then
        zt_api_url+="/user/$zt_user_id"
    elif [ ! -z "$zt_net_id" ]; then
        zt_api_url+="/network/$zt_net_id"
        if [ ! -z "$zt_dev_id" ]; then zt_api_url+="/member/$zt_dev_id"; fi
    fi

    if [ -z "$zt_api_key" ]; then echo "No ZT API Key" 1>&2; return 0; fi
    zt_api_headers="-H 'Content-Type: application/json' -H 'Authorization: Bearer $zt_api_key'"

    if [ -z "$zt_api_url" ]; then echo "No ZT URI" 1>&2; return 0; fi

    if [ ! -z "$zt_api_payload" ]; then 
        zt_api_cmd="curl -X POST --url '$zt_api_url' $zt_api_headers -d $zt_api_payload"
        zt_api_results=$(eval $zt_api_cmd "$zt_api_payload" 2>/dev/null | jq --compact-output -r '.id')
        if [ -z "$zt_api_results" ]; then return 0; else return 1; fi
    else 
        zt_api_cmd="curl -s --url '$zt_api_url' $zt_api_headers"
        if [ -z "$zt_api_request" ]; then zt_api_request="."; fi
        zt_api_results=$(eval $zt_api_cmd 2>/dev/null | jq --compact-output -r "$zt_api_request")
        if [ -z "$zt_api_results" ]; then return 0; else echo "$zt_api_results"; fi
    fi
}

# Examples
zt_authorize() {
    zt_api -n -m -p '{"config":{"authorized":true}}'
}
zt_add_tags() {
    zt_new_tags=""
    zt_tags=($(zt_api -n -m -r .config.tags[] 2>/dev/null))
    for t in "${zt_tags[@]}"; do 
        if [[ ! "$zt_new_tags" == *"\"$t\","* ]]; then zt_new_tags+="\"$t\","; fi
    done
    for t in $@; do 
        if [[ ! "$zt_new_tags" == *"\"$t\","* ]]; then zt_new_tags+="\"$t\","; fi
    done
    zt_api -n -m -p '{"config":{"tags":['${zt_new_tags%?}']}}'
}

zt_api $@
