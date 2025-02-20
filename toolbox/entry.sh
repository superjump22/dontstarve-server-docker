#!/bin/bash

function help() {
    echo "Available commands:"
    echo "  help    - Display this help."
    echo "  version - Get the game version."
    echo "  modinfo - Generate the modinfo json of all installed mods."
    echo "  worldgenoverride - Generate 'worldgenoverride.lua' templates."
}

function version() {
    echo $DST_VERSION
}

function modinfo() {
    mkdir -p /tmp/modinfo
    json_dict="{}"
    # search for v1 mods
    for mod_dir in $DST_MODDIR/workshop-*; do
        if [ -d "$mod_dir" ]; then
            mod_id=$(basename "$mod_dir" | cut -d '-' -f 2)
            modinfo_jsonify "$mod_id" "$mod_dir/modinfo.lua"
        fi
    done
    # seach for v2 mods
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
        json_dict=$(echo "$json_dict" | jq -crMS --arg key "$mod_id" --argjson value "$output" '. + {($key): $value}')
    fi
}

function worldgenoverride() {
    # cleanup
    rm -rf $DST_GAMEDIR/data/scripts
    rm -f $DST_GAMEDIR/data/worldgenoverride.json
    for lang in en zh zht; do
        rm -f $DST_GAMEDIR/data/$lang.json
    done

    # inject
    cp -r $DST_GAMEDIR/data/scripts_backup/scripts/ $DST_GAMEDIR/data/
    cp -r /root/toolbox/worldgenoverride/scripts/ $DST_GAMEDIR/data/
    echo -e "\nrequire 'inject_toolbox/main'\n" >>$DST_GAMEDIR/data/scripts/gamelogic.lua

    # generate
    for lang in en zh zht; do
        cd $DST_GAMEDIR/bin64
        ./dontstarve_dedicated_server_nullrenderer_x64 -skip_update_server_mods -ugc_directory "$DST_UGCMODDIR" -persistent_storage_root "/root/toolbox/worldgenoverride" -conf_dir "save" -cluster "Cluster_$lang" -shard "Master" >/dev/null 2>&1
        cd $DST_GAMEDIR/data
        mv worldgenoverride.json $lang.json
    done

    # merge
    jq -scrMS '{en: .[0], zh: .[1], zht: .[2]}' en.json zh.json zht.json

    # cleanup
    rm -rf $DST_GAMEDIR/data/scripts
    rm -f $DST_GAMEDIR/data/worldgenoverride.json
    for lang in en zh zht; do
        rm -f $DST_GAMEDIR/data/$lang.json
    done
}

case "$1" in
help)
    help
    ;;
version)
    version
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
