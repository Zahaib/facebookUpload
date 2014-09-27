#!/bin/bash

accessToken='XXXXXXXXXXXXXXXXXXXXXX' 

#
# CHANGELOG:
# Version 1.1, 27th Sep 2014: Support added for album names with spaces
#

#
# TODO: Improve optarg checks
# TODO: Add error checking to returned flags
#

usage () { 
	cat <<-USAGE
	usage: $0 -n <ALBUMNAME> -d <PATH TO PHOTODIR> 

	USAGE
	exit 1
} 

descrip () {
	cat <<-HELP

	This script uses Facebook's Graph API v2.0 to create and upload photos to an Album, the default album privacy is set to "Only me".

	User needs to authenticate themselves using an oauth access_token with scopes: user_photos and publish_actions.
	Short lived Facebook access_tokens (max. of 2 hours) with required scopes can be generated from here: https://developers.facebook.com/
	Tools --> Graph API Explorer --> Get Access Token

	-n		Name of the album
	-d		Path to the directory where photos are held
	-version	Print version number and exit
	-h		Help

	Examples:

	./$0 -n myAlbumName -d /home/bob/photos/

	HELP
	exit 1
}

printVersion () {
	cat <<-VERSION
	$0 version 1.1
	VERSION
	exit 1
}

album_name=invalid
path=invalid

while getopts ":n:d:v:h" OPTNAME
do
	case "$OPTNAME" in
	n)		album_name_raw="$OPTARG" ;;
	d)		path="$OPTARG" ;;
	v)		printVersion ;;
	h)		descrip ;;
	-)  	break ;;
	\?) 	;;
	*)		echo "Unhandled option $OPTNAME" ;;
	?)		usage 
			exit 1 ;;
	esac
done

album_name=$(echo $album_name_raw | sed 's/ /%20/g')

# check if the album name and path is valid, this needs to be improved
test $album_name != invalid || usage
test $path  != invalid || usage


if [ $accessToken = 'XXXXXXXXXXXXXXXXXXXXXX' ]
	then
	printf "\nPlease add an access token first above. Short lived user sccess tokens can be generated from: https://developers.facebook.com/\n"
	exit 1
fi


# generate new album create URL
createAlbum_url="https://graph-video.facebook.com/me/albums?name=$album_name&access_token=$accessToken"

# place the cURL request parse the returned flag to get albumID
albumID=$(curl -s -X POST --url $createAlbum_url | cut -d: --complement -f1 | cut -d\" --complement -f1 | cut -d\" -f1) 
printf "Album created with name: \'$album_name_raw\' and albumID: $albumID\n"

# generate photo upload URL
upload_url="https://graph-video.facebook.com/$albumID/photos?&access_token=$accessToken"

# CD to path and find all files of extension .jpg .jpeg .JPG .png and .gif
cd $path
for i in `find . '(' -name '*.jpg' -o -name '*.jpeg' -o -name '*.JPG' -o -name '*.png' -o -name '*.gif' ')'`; do
	photoName=$(echo $i | cut -d/ --complement -f1)
	# generate full path to the photo
	photoPath=$(pwd)/$photoName
	# place cURL request to upload photo, parse returned flag and print
	flag=$(curl -s POST -F "file=@$photoPath" "$upload_url")
	printf "$photoName uploaded with photo ID: $(echo $flag | cut -d: --complement -f1 | cut -d\" --complement -f1 | cut -d\" -f1)\n"

done
