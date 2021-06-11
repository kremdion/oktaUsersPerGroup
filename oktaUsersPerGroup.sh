#!/bin/bash
# Script that produces a csv file for every okta group, that contains the users of that group.

API_TOKEN=""
OKTA_DOMAIN=""

getGroups () {
	result=$(curl -s -X GET \
	-H "Accept: application/json" \
	-H "Content-Type: application/json" \
	-H "Authorization: SSWS $API_TOKEN" \
	"https://$OKTA_DOMAIN/api/v1/groups")

	temp=$(echo "${result}" | jq '[.[] | {id: .id, name: .profile.name}]')
	#echo "$temp" > "groups.json"

	length=$(echo $temp | jq length)
	group_ids=()
	group_names=()
	for (( i=0; i<$length; i++ ))
	do
        	id=$(echo $temp | jq -r '.['$i'].id')
        	name=$(echo $temp | jq -r '.['$i']."name"')
        	group_ids+=($id)
		name=${name// /_}
        	group_names+=("$name")
		#echo ${group_ids[$i]}  ${group_names[$i]}
	done
	return 0
}

getUsersByGroupId () {
        RESULT=$(curl -s -X GET \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -H "Authorization: SSWS $API_TOKEN" \
        "https://$OKTA_DOMAIN/api/v1/groups/$1/users")

	TEMP=$(echo "${RESULT}" | jq '[.[] | {id: .id, firstName: .profile.firstName, lastName: .profile.lastName, email: .profile.email, status: .status}]')
	if [ "$TEMP" = "[]" ]
	then
		echo $2 does not have users.
	else
		echo "$TEMP" > './'$2'_users.json'
		jq -r 'map({id, firstName, lastName, email, status}) | (first | keys_unsorted) as $keys | map([to_entries[] | .value]) as $rows | $keys,$rows[] | @csv' ${2}_users.json > $2_users.csv
	fi
	return 0
}

getGroups

ids_length=${#group_ids[@]}
for (( k=0; k<$ids_length; k++ ))
do
	getUsersByGroupId ${group_ids[$k]} ${group_names[$k]}
done

