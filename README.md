# oktaUsersPerGroup
This is a script that pulls all the users per group into a csv file from an Okta account.


This script works with API key from an Okta account. It makes API requests to get all the groups and then gets all the users from each group. It finally saves the users in a csv file named under the group name.

The only dependency is the "jq" library.
