fbShellAlbumUpload
==============

## Introduction

fbShellAlbumUpload is a Bash shell script to create an album and upload photos to Facebook. It places calls using Facebook's Graph API v2.0.

In order to get started, generate a short lived user access token from https://developers.facebook.com with the scopes "publish_actions" and "user_photos". Add the generated access token to the script by changing the line

```
accessToken='XXXXXXXXXXXXXXXXXXXXXX'
```

## Usage

```
./fbShellAlbumUpload -n <"My Album Name"> -d <path to photos directory>
```
The default privacy setting for the album is "Only me"