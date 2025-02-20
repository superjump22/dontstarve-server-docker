```bash
# help
docker run --rm \
    -v dst_mods:/home/steam/dst/game/mods:ro \
    -v dst_ugc_mods:/home/steam/dst/game/ugc_mods:ro \
    superjump22/dontstarvetogether-toolbox:public \
    help

# version
docker run --rm \
    -v dst_mods:/home/steam/dst/game/mods:ro \
    -v dst_ugc_mods:/home/steam/dst/game/ugc_mods:ro \
    superjump22/dontstarvetogether-toolbox:public \
    version

# modinfo
docker run --rm \
    -v dst_mods:/home/steam/dst/game/mods:ro \
    -v dst_ugc_mods:/home/steam/dst/game/ugc_mods:ro \
    superjump22/dontstarvetogether-toolbox:public \
    modinfo

# worldgenoverride
docker run --rm \
    -v dst_mods:/home/steam/dst/game/mods:ro \
    -v dst_ugc_mods:/home/steam/dst/game/ugc_mods:ro \
    superjump22/dontstarvetogether-toolbox:public \
    worldgenoverride
```
