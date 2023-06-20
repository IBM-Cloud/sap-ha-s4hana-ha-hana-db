#!/bin/bash
###########
echo 'Login to ibmcloud'
ibmcloud config --check-version=false -q --http-timeout 240 --color enable
ibmcloud login -r $region -g $resource_group_id --apikey $api_key
export oauth_token=$(ibmcloud iam oauth-tokens | awk '{print $4}')

curl -X POST "$vpc_api_endpoint/v1/shares?version=2023-05-30&generation=2&maturity=beta" \
  -H "Authorization: Bearer ${oauth_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "size": '$share_size',
    "name": "'"$share_name"'",
    "profile": {
      "name": "'"$share_profile"'"
    },
    "zone": {
      "name": "'"$zone"'"
    },
    "resource_group": {
      "id": "'"$resource_group_id"'"
    }
  }'  -o modules/file-shares/cache/output_fs_$share_name.json

share_id=$(grep -o "\"id\":\"[^\"]*\"" modules/file-shares/cache/output_fs_$share_name.json | sed 's/"id":"//' | awk -F\" 'NR==1 {print $1}')

echo $share_id  > modules/file-shares/cache/share_id_$share_name.tmpl

sleep 40

curl -X POST "$vpc_api_endpoint/v1/shares/$share_id/mount_targets?version=2023-05-30&generation=2&maturity=beta" \
   -H "Authorization: Bearer ${oauth_token}" \
   -H 'Content-Type: application/json' \
   -d '{
    "name": "'"$share_name"'",
    "vpc": {
      "id": "'"$vpc_id"'"
    }
  }' -o modules/file-shares/cache/output_fs_mt_$share_name.json

sleep 20

mount_path=$(grep -o '"mount_path":"[^"]*"' modules/file-shares/cache/output_fs_mt_$share_name.json | awk -F'"' '{print $4}')
echo  $mount_path > modules/file-shares/cache/mount_path.tmpl


mount_id=$(grep -m 1 -o '"id":"[^"]*"' modules/file-shares/cache/output_fs_mt_$share_name.json | sed -n '1s/"id":"\(.*\)"/\1/p;q')
echo  $mount_id > modules/file-shares/cache/mount_id_$share_name.tmpl