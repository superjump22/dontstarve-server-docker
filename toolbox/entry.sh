#!/bin/bash

function help() {
    echo "Available commands:"
    echo "  help    - Display this help."
    echo "  clientversion - Get the client version."
    echo "  modinfo - Generate the modinfo json of all installed mods."
    echo "  worldgenoverride - Generate 'worldgenoverride.lua' templates."
}

function clientversion() {
    cat $DST_GAMEDIR/version.txt
}

function modinfo() {
    mkdir -p /tmp/modinfo
    json_dict="{}"
    for mod_dir in $DST_MODDIR/workshop-*; do
        if [ -d "$mod_dir" ]; then
            mod_id=$(basename "$mod_dir" | cut -d '-' -f 2)
            modinfo_jsonify "$mod_id" "$mod_dir/modinfo.lua"
        fi
    done
    for mod_dir in $DST_UGCMODDIR/content/$STEAM_WORKSHOPID/*; do
        if [ -d "$mod_dir" ]; then
            mod_id=$(basename "$mod_dir")
            modinfo_jsonify "$mod_id" "$mod_dir/modinfo.lua"
        fi
    done
    rm -rf /tmp/modinfo
    echo "$json_dict"
}

function modinfo_jsonify() {
    local mod_id="$1"
    local modinfo_path="$2"
    if [ -f "$modinfo_path" ]; then
        cp "$modinfo_path" "/tmp/modinfo/$mod_id.lua"
        echo -e "\nlocal rapidjson = require('rapidjson')\nprint(rapidjson.encode(configuration_options))" >>"/tmp/modinfo/$mod_id.lua"
        output=$(lua "/tmp/modinfo/$mod_id.lua")
        json_dict=$(echo "$json_dict" | jq -c --arg key "$mod_id" --argjson value "$output" '. + {($key): $value}')
    fi
}

function worldgenoverride() {
    rm -rf $DST_GAMEDIR/data/scripts
    rm -f $DST_GAMEDIR/data/worldgenoverride_*.json
    cp -r $DST_GAMEDIR/data/scripts_backup/scripts/ $DST_GAMEDIR/data/
    cp -r /root/toolbox/worldgenoverride/scripts/ $DST_GAMEDIR/data/
    echo -e "\nrequire 'inject_toolbox/main'\n" >>$DST_GAMEDIR/data/scripts/gamelogic.lua
    cd $DST_GAMEDIR/bin64
    ./dontstarve_dedicated_server_nullrenderer_x64 -skip_update_server_mods -ugc_directory "$DST_UGCMODDIR" >/dev/null 2>&1
    cd $DST_GAMEDIR/data
    cat worldgenoverride_forest_master.json
    echo
    cat worldgenoverride_forest.json
    echo
    cat worldgenoverride_cave_master.json
    echo
    cat worldgenoverride_cave.json
    rm -rf $DST_GAMEDIR/data/scripts
    rm -f $DST_GAMEDIR/data/worldgenoverride_*.json
}

case "$1" in
help)
    help
    ;;
clientversion)
    clientversion
    ;;
modinfo)
    modinfo
    ;;
worldgenoverride)
    worldgenoverride
    ;;
*)
    echo "Unknown command: $1"
    help
    exit 1
    ;;
esac
