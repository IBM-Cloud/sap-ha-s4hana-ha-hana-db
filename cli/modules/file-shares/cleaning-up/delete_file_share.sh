#!/bin/bash
###########

echo 'Login to ibmcloud'
ibmcloud config --check-version=false -q --http-timeout 240 --color enable
ibmcloud login -r $region -g $resource_group_id --apikey $api_key
export oauth_token=$(ibmcloud iam oauth-tokens | awk '{print $4}')

share_id=$(cat modules/file-shares/cleaning-up/share_id_$share_name.tmpl)

curl -X DELETE "$vpc_api_endpoint/v1/shares/$share_id?version=2023-05-30&generation=2&maturity=beta" -H "Authorization: Bearer ${oauth_token}"