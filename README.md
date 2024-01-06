<div align="center">
  <h1>Dockerized Don't Starve Together Dedicated Server</h1>
</div>

<p align="center">
  <span>English</span> | <a href="README-zh.md">中文</a>
</p>

<br />
<br />

# Introduction

A minimalist containerized image for the Don't Starve Together dedicated server program. Just pack the program and use `dontstarve_dedicated_server_nullrenderer_x64` as the container entry point.

# Supported Tags

- `latest`, `public`: Stable version
- Others: you can find the corresponding test branches in Steam, by right-clicking -> Properties -> Betas -> Beta Participation

# Update Frequency

The image updates automatically every half hour if outdated, keeping this repository practically in real-time sync with the latest official version.

# Usage

## Prerequisites

- A `64`-bit system with a `docker` environment installed
- You are sufficiently familiar with `docker`
- You are sufficiently familiar with deploying Don't Starve Together dedicated servers in non-`docker` environments

## Description

- This image is based on the official `SteamCMD` image and installs the latest version of the Don't Starve Together dedicated server program in it, and uses the `64`-bit program as the container entry point
- In the container, the game directory is `/home/steam/dst/game`
- In the container, the save directory is `/home/steam/dst/save`
- In the container, the `V1` mod directory is `/home/steam/dst/game/mods`
- In the container, the `V2` mods (or `UGC` mods) directory is `/home/steam/dst/ugc_mods`
- Outside of the container, the persistent storage of save files and mods is defined by you. You just need to mount them into the corresponding directories inside the container when running.

## Examples

Since this image directly uses `dontstarve_dedicated_server_nullrenderer_x64` as the container entry point, the command line parameters are the same as those provided by the official command line program (because it is just the same program). All supported commands can refer to the official guide:

[Dedicated Server Command Line Options Guide](https://forums.kleientertainment.com/forums/topic/64743-dedicated-server-command-line-options-guide/)

Before the initial use, you should create directories for archiving and mods on your host machine, and then mount them when running the container to persist the archived data and avoid repeatedly downloading mods:

```shell
# On your host machine
$ mkdir -p <path>/dst/save
$ mkdir -p <path>/dst/mods
$ mkdir -p <path>/dst/ugc_mods
```

`<path>` represents a custom directory, which depends entirely on you (for example, mine is `~/.klei`),
`save` is used to place the save files, `mods` and `ugc_mods` are used to place mods (`mods` put `V1` version, `ugc_mods` put `V2` version)

Then, you need to put `2` empty files in `<path>/dst/mods`:

```shell
$ cd <path>/dst/mods
$ touch dedicated_server_mods_setup.lua
$ touch modsettings.lua
```

The subsequent start commands completely depend on how you want to use the container. It is highly recommended to read through the [Dedicated Server Command Line Options Guide](https://forums.kleientertainment.com/forums/topic/64743-dedicated-server-command-line-options-guide/) first. Below are a few typical use cases:

### Example 1: Starting the Overworld

First, you can pre-place the appropriate configuration in the save directory of your host machine:

```
# On your host machine
<path>/dst/save/<cluster>/cluster.ini
<path>/dst/save/<cluster>/<shard>/server.ini
```

`<cluster>` represents the root directory of a save, you can name it arbitrarily, like `Cluster_1`; `<shard>` represents the directory of the world instance, for the overworld, usually use `Master` (actually the name is arbitrary)

For how to set the configuration file, please refer to the official guide:

[Dedicated Server Settings Guide](https://forums.kleientertainment.com/forums/topic/64552-dedicated-server-settings-guide/)

Later we will mount to the corresponding directory of the container through the `-v` parameter of `docker run`:

```
# Inside the container
/home/steam/dst/save/<cluster>/cluster.ini
/home/steam/dst/save/<cluster>/<shard>/server.ini
```

This way `dontstarve_dedicated_server_nullrenderer_x64` will read these configuration files when starting

Below is a command template for starting the overworld, please modify according to your actual needs:

```shell
docker run --rm -itd --name=dst-master \
    -p 10888:10888/udp \ # The port needed by the main world instance, generally, the overworld is the main world, so this port is needed, and the underworld doesn't need it, the port number on the left of : needs to be unoccupied on the host machine
    -p 10999:10999/udp \ # The port needed by the current world instance, the port number on the left of : needs to be unoccupied on the host machine
    -p 27016:27016/udp \ # The port needed by Steam, the port number on the left of : needs to be unoccupied on the host machine
    -v "<path>/dst/save:/home/steam/dst/save" \ # Mount save path
    -v "<path>/dst/mods:/home/steam/dst/game/mods" \ # Mount V1 mod path
    -v "<path>/dst/ugc_mods:/home/steam/dst/ugc_mods" \ # Mount V2 mod path
    superjump22/dontstarvetogether:latest \
    # The following are parameters given to dontstarve_dedicated_server_nullrenderer_x64
    -skip_update_server_mods \ # Do not update mods, start directly (we will update mods in other ways, so please do not modify)
    -ugc_directory "/home/steam/dst/ugc_mods" \ # Specify the V2 mod storage path inside the container for ease of management (please do not modify)
    -persistent_storage_root "/home/steam/dst" \ # Persistent root directory required by the game program (please do not modify)
    -conf_dir "save" \ # "<persistent_storage_root>/<conf_dir>" is the total directory of all saves (please do not modify)
    -cluster "Cluster_1" \ # The directory name of the current world save, should be consistent with <cluster>
    -shard "Master" \ # Here is to start the overworld, usually called Master (actually, anything would do)
    ... # Other parameters you need, refer to the official guide
```

### Example 2: Starting the Underworld

First, you can pre-place the appropriate configuration in the save directory of your host machine:

```
# On your host machine
<path>/dst/save/<cluster>/cluster.ini
<path>/dst/save/<cluster>/<shard>/server.ini
```

`<cluster>` represents the root directory of a save, you can name it arbitrarily, like `Cluster_1`; `<shard>` represents the directory of the world instance, for the underworld, usually use `Caves` (actually the name is arbitrary)

For how to set the configuration file, please refer to the official guide:

[Dedicated Server Settings Guide](https://forums.kleientertainment.com/forums/topic/64552-dedicated-server-settings-guide/)

Later we will mount to the corresponding directory of the container through the `-v` parameter of `docker run`:

```
# Inside the container
/home/steam/dst/save/<cluster>/cluster.ini
/home/steam/dst/save/<cluster>/<shard>/server.ini
```

This way `dontstarve_dedicated_server_nullrenderer_x64` will read these configuration files when starting

Below is a command template for starting the underworld, please modify according to your actual needs:

```shell
docker run --rm -itd --name=dst-caves \
    -p 11000:10999/udp \ # The port needed by the current world instance, the port number on the left of : needs to be unoccupied on the host machine
    -p 27017:27016/udp \ # The port needed by Steam, the port number on the left of : needs to be unoccupied on the host machine
    -v "<path>/dst/save:/home/steam/dst/save" \ # Mount save path
    -v "<path>/dst/mods:/home/steam/dst/game/mods" \ # Mount V1 mod path
    -v "<path>/dst/ugc_mods:/home/steam/dst/ugc_mods" \ # Mount V2 mod path
    superjump22/dontstarvetogether:latest \
    # The following are parameters given to dontstarve_dedicated_server_nullrenderer_x64
    -skip_update_server_mods \ # Do not update mods, start directly (we will update mods in other ways, so please do not modify)
    - ugc_directory "/home/steam/dst/ugc_mods" \ # Specify the V2 mod storage path inside the container for ease of management (please do not modify)
    -persistent_storage_root "/home/steam/dst" \ # Persistent root directory required by the game program (please do not modify)
    -conf_dir "save" \ # "<persistent_storage_root>/<conf_dir>" is the total directory of all saves (please do not modify)
    -cluster "Cluster_1" \ # The directory name of the current world save, should be consistent with <cluster>
    -shard "Caves" \ # Here is to start the underworld, usually called Caves (actually anything would do)
    ... # Other parameters you need, refer to the official guide
```

### Example 3: Download/Update Mods

First, you need to modify the `dedicated_server_mods_setup.lua` on your host machine to include the mods you need to download/update:

```shell
# On your host machine, modify <path>/dst/mods/dedicated_server_mods_setup.lua:
ServerModSetup("3055375757")
ServerModSetup("398858801")
```

(`3055375757` and `398858801` are the mod IDs in the steam workshop)

Here's the template for the command to download/update mods:

```shell
docker run --rm -itd --name=dst-updatemods \
    -v "<path>/dst/save:/home/steam/dst/save" \ # Mount save path
    -v "<path>/dst/mods:/home/steam/dst/game/mods" \ # Mount V1 mod path
    -v "<path>/dst/ugc_mods:/home/steam/dst/ugc_mods" \ # Mount V2 mod path
    superjump22/dontstarvetogether:latest \
    # The following are parameters given to dontstarve_dedicated_server_nullrenderer_x64
    -only_update_server_mods \ # Only update mods, do not start world
    -ugc_directory "/home/steam/dst/ugc_mods" \ # Specify the V2 mod storage path inside the container for ease of management (please do not modify)
    -persistent_storage_root "/home/steam/dst" \ # Persistent root directory required by the game program (please do not modify)
    -conf_dir "temp" \ # "<persistent_storage_root>/<conf_dir>" is the total directory of all saves, we use "temp" for downloading/updating mods (please do not use "save")
```

### Example 4: My Three Most Frequently Used Commands

Please note: I typically run the container in host mode and place the save files and mods in volumes named `dst_save`, `dst_mods` and `dst_ugc_mods`

Update mods:

```shell
docker run --rm -itd --name=dst-updatemods \
    -v "dst_save:/home/steam/dst/save" \
    -v "dst_mods:/home/steam/dst/game/mods" \
    -v "dst_ugc_mods:/home/steam/dst/ugc_mods" \
    superjump22/dontstarvetogether:latest \
    -only_update_server_mods \
    -ugc_directory "/home/steam/dst/ugc_mods" \
    -persistent_storage_root "/home/steam/dst" \
    -conf_dir "temp" \
    -cluster "updatemods"
```

Start overworld:

```shell
docker run --rm -itd --network=host --name=dst-master \
    -v "dst_save:/home/steam/dst/save" \
    -v "dst_mods:/home/steam/dst/game/mods" \
    -v "dst_ugc_mods:/home/steam/dst/ugc_mods" \
    superjump22/dontstarvetogether:latest \
    -skip_update_server_mods \
    -ugc_directory "/home/steam/dst/ugc_mods" \
    -persistent_storage_root "/home/steam/dst" \
    -conf_dir "save" \
    -cluster "test" \
    -shard "m"
```

Start caves:

```shell
docker run --rm -itd --network=host --name=dst-caves \
    -v "dst_save:/home/steam/dst/save" \
    -v "dst_mods:/home/steam/dst/game/mods" \
    -v "dst_ugc_mods:/home/steam/dst/ugc_mods" \
    superjump22/dontstarvetogether:latest \
    -skip_update_server_mods \
    -ugc_directory "/home/steam/dst/ugc_mods" \
    -persistent_storage_root "/home/steam/dst" \
    -conf_dir "save" \
    -cluster "test" \
    -shard "c"
```

### Example 5: Use in Scripts or Programs

In the previous examples, the `docker run` command includes the `-t` parameter, which is suitable for manually managing the container via terminal.

In a non-Docker environment, if you need to manage a `dontstarve_dedicated_server_nullrenderer_x64` process within a script or program, the usual way is to wrap it using tools like `supervisor` or `screen`. Then, you can pass commands to the `dontstarve_dedicated_server_nullrenderer_x64` process through something like `screen -r "dst" -p 0 -X stuff "c_shutdown()$(printf \\r)"`.

In a Docker environment, you don't need to do that. You just need to remove the `-t` parameter when starting the container:

```shell
docker run --rm -id --network=host --name=dst-master \
    -v "dst_save:/home/steam/dst/save" \
    -v "dst_mods:/home/steam/dst/game/mods" \
    -v "dst_ugc_mods:/home/steam/dst/ugc_mods" \
    superjump22/dontstarvetogether:latest \
    -skip_update_server_mods \
    -ugc_directory "/home/steam/dst/ugc_mods" \
    -persistent_storage_root "/home/steam/dst" \
    -conf_dir "save" \
    -cluster "test" \
    -shard "m"
```

Then in your script:

```shell
docker exec -i dst-master bash -c 'echo "c_shutdown()" > /proc/1/fd/0'
```

This is because `dontstarve_dedicated_server_nullrenderer_x64` is the main process of the container, with PID=1, and its standard input is `/proc/1/fd/0`.
