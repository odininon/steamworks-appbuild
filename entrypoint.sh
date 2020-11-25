#!/bin/bash

set -eu

repo=`pwd`
export HOME=/home/steam
cd $STEAMCMDDIR

echo "Uploading item $2 for app $1 from $3"

cat << EOF > ./app_build.vdf
"appbuild"
{
	"appid"	"$1"
	"desc" "$4" // description for this build
	"buildoutput" "../output/" // build output folder for .log, .csm & .csd files, relative to location of this file
	"contentroot" "../content/" // root content folder, relative to location of this file
	"setlive"	"" // branch to set live after successful build, non if empty
	"preview" "0" // to enable preview builds
	"local"	""	// set to flie path of local content server 
	
	"depots"
	{
		"$2" "depot_build.vdf"
	}
}
EOF

cat << EOF > ./depot_build.vdf
"DepotBuildConfig"
{
	// Set your assigned depot ID here
	"DepotID" "$2"

	// Set a root for all content.
	// All relative paths specified below (LocalPath in FileMapping entries, and FileExclusion paths)
	// will be resolved relative to this root.
	// If you don't define ContentRoot, then it will be assumed to be
	// the location of this script file, which probably isn't what you want
	"ContentRoot"	"$repo/$3"

	// include all files recursivley
  "FileMapping"
  {
  	// This can be a full path, or a path relative to ContentRoot
    "LocalPath" "*"
    
    // This is a path relative to the install folder of your game
    "DepotPath" "."
    
    // If LocalPath contains wildcards, setting this means that all
    // matching files within subdirectories of LocalPath will also
    // be included.
    "recursive" "1"
  }

	// but exclude all symbol files  
	// This can be a full path, or a path relative to ContentRoot
  "FileExclusion" "*.pdb"
}

EOF

echo "$(cat ./app_build.vdf)"
echo "$(cat ./depot_build.vdf)"

(/home/steam/steamcmd/steamcmd.sh \
    +login $STEAM_USERNAME $STEAM_PASSWORD \
    +run_app_build_http `pwd -P`/app_build.vdf \
    +quit \
) || (
    # https://partner.steamgames.com/doc/features/workshop/implementation#SteamCmd
    echo /home/steam/Steam/logs/stderr.txt
    echo "$(cat /home/steam/Steam/logs/stderr.txt)"
    echo
    echo /home/steam/Steam/logs/Workshop_log.txt
    echo "$(cat /home/steam/Steam/logs/Workshop_log.txt)"
    echo
    echo /home/steam/Steam/workshopbuilds/depot_build_$1.log
    echo "$(cat /home/steam/Steam/workshopbuilds/depot_build_$1.log)"

    exit 1
)

exit 0