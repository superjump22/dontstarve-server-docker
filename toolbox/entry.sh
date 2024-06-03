#!/bin/bash

function help() {
    echo "Available commands:"
    echo "  help    - Display this help."
    echo "  modinfo - Generate the modinfo json of all installed mods."
    echo "  clientversion - Get the client version."
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

function clientversion() {
    cat $DST_GAMEDIR/version.txt
}

case "$1" in
help)
    help
    ;;
modinfo)
    modinfo
    ;;
clientversion)
    clientversion
    ;;
*)
    echo "Unknown command: $1"
    help
    exit 1
    ;;
esac
