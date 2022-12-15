#!/bin/bash
###########

echo 'Login to ibmcloud'
ibmcloud config --check-version=false -q --http-timeout 240 --color enable
ibmcloud login -r $self_triggers_region --apikey $self_triggers_api_key
export oauth_token=$(ibmcloud iam oauth-tokens |awk '{print $4}')
sleep 20
curl -X DELETE "$self_triggers_host/$self_triggers_share_id?version=2022-05-03&generation=2" -H "Authorization: $oauth_token"