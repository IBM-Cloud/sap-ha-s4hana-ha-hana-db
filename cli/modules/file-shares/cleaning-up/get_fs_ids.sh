#!/bin/bash
###########

echo 'Login to ibmcloud'
ibmcloud config --check-version=false -q --http-timeout 240 --color enable
ibmcloud login -r $region -g $resource_group_id --apikey $api_key
export oauth_token=$(ibmcloud iam oauth-tokens | awk '{print $4}')

export share_id=$(ibmcloud is share "$share_name" | awk '/ID/ {print $2}' | head -n 1)

echo $share_id  > modules/file-shares/cleaning-up/share_id_$share_name.tmpl


curl -X GET "$vpc_api_endpoint/v1/shares/$share_id/mount_targets?version=2023-05-30&generation=2&maturity=beta" \
   -H "Authorization: Bearer ${oauth_token}" \
   -H 'Content-Type: application/json' \
   -d '{
    "name": "'"$share_name"'",
    "vpc": {
      "id": "'"$vpc_id"'"
    }
  }' -o modules/file-shares/cleaning-up/output_fs_mt_$share_name.json

export mount_id=$(grep -m 1 -o '"id":"[^"]*"' modules/file-shares/cleaning-up/output_fs_mt_$share_name.json | sed -n '1s/"id":"\(.*\)"/\1/p;q')
echo  $mount_id > modules/file-shares/cleaning-up/mount_id_$share_name.tmpl
