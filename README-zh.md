<div align="center">
  <h1>Dockerized Don't Starve Together Dedicated Server</h1>
</div>

<p align="center">
  <a href="README.md">English</a> | <span>中文</span>
</p>

<br />
<br />

## 简介

饥荒联机版独立服务器程序容器化后的极简镜像。仅仅将程序打包并把`dontstarve_dedicated_server_nullrenderer_x64`作为容器入口

## 使用方法

### 前提

- `64`位且安装有`docker`环境的系统
- 您对`docker`使用足够熟悉
- 您对非`docker`环境下部署饥荒联机版独立服务器足够熟悉

### 说明

- 该镜像基于`SteamCMD`的官方镜像修改而来，在其中安装最新版的饥荒联机版独立服务器程序，并将`64`位的程序作为容器入口
- 容器默认用户为`steam`
- 容器内，游戏目录为`/home/steam/dst/game`
- 容器内，存档目录为`/home/steam/dst/save`
- 容器内，`V1`模组目录为`/home/steam/dst/game/mods`
- 容器内，`V2`模组（`UGC`模组）目录为`/home/steam/dst/ugc_mods`

### 示例

因为本镜像是直接将`dontstarve_dedicated_server_nullrenderer_x64`作为容器入口，所以命令参数与官方提供的命令行程序参数一致（因为本身就是同一个程序），所有支持的命令可参考官方指南：

[Dedicated Server Command Line Options Guide](https://forums.kleientertainment.com/forums/topic/64743-dedicated-server-command-line-options-guide/)

首次使用前，您应当先在您的宿主机上创建存档和模组的目录，之后运行容器的时候再挂载进去，以持久化存档数据并避免重复下载模组：

```shell
# 在您的宿主机上
$ mkdir -p <path>/dst/save
$ mkdir -p <path>/dst/mods
$ mkdir -p <path>/dst/ugc_mods
```

`<path>`代表某个合适的目录，这完全取决于您（例如我的是`~/.klei`），
`save`用来放置存档，`mods`和`ugc_mods`用来放置模组（`mods`放置`V1`版本的，`ugc_mods`放置`V2`版本的）

随后，您需要在`<path>/dst/mods`中放入`2`个空文件：

```shell
$ cd <path>/dst/mods
$ touch dedicated_server_mods_setup.lua
$ touch modsettings.lua
```

由于容器内默认用户为`steam`，而您刚刚创建的三个目录的所有权属于您，因此，在挂载进容器后，容器内的`steam`用户不一定能向其中写入数据。举个例子，假设以上三条命令是您在宿主机上以`root`用户执行，则这三个目录在挂载进容器后，仍然属于`root`用户，那么容器内以`steam`用户运行的游戏进程就将无法向其中写入数据。因此，建议先把这三个目录的权限开放：

```shell
# 在您的宿主机上
$ chmod -R 777 <path>/dst
```

之后的启动命令就完全取决于您要如何使用容器了，强烈建议先完整看一遍[Dedicated Server Command Line Options Guide](https://forums.kleientertainment.com/forums/topic/64743-dedicated-server-command-line-options-guide/)
，以下是几个典型的使用场景：

#### 示例一：启动地上世界

首先，您可以预先在宿主机的存档目录里放入合适的配置：

```
# 在您的宿主机上
<path>/dst/save/<cluster>/cluster.ini
<path>/dst/save/<cluster>/<shard>/server.ini
```

`<cluster>`代表一个存档的根目录，取名随意，如`Cluster_1`；`<shard>`代表世界实例的目录，对于地上世界，通常会使用`Master`（但其实取名随意）

至于配置文件如何设定，请参考官方指南：

[Dedicated Server Settings Guide](https://forums.kleientertainment.com/forums/topic/64552-dedicated-server-settings-guide/)

稍后我们会通过`docker run`的`-v`参数挂载到容器的对应目录：

```
# 在容器内部
/home/steam/dst/save/<cluster>/cluster.ini
/home/steam/dst/save/<cluster>/<shard>/server.ini
```

这样在`dontstarve_dedicated_server_nullrenderer_x64`启动的时候就会读取这些配置文件

以下是启动地上世界的指令模板，请根据您的实际需求修改：

```shell
docker run --rm -itd --name=dst-master \
    -p 10888:10888/udp \ # 主世界实例需要使用的端口，一般来说，地上世界是主世界，因此需要该端口，而地下世界不用，:左边的端口号需要在宿主机上未被占用
    -p 10999:10999/udp \ # 当前世界实例需要使用的端口，:左边的端口号需要在宿主机上未被占用
    -p 27016:27016/udp \ # Steam需要使用的端口，:左边的端口号需要在宿主机上未被占用
    -v "<path>/dst/save:/home/steam/dst/save" \ # 挂载存档路径
    -v "<path>/dst/mods:/home/steam/dst/game/mods" \ # 挂载V1模组路径
    -v "<path>/dst/ugc_mods:/home/steam/dst/ugc_mods" \ # 挂载V2模组路径
    superjump22/dontstarvetogether:latest \
    # 以下为传给dontstarve_dedicated_server_nullrenderer_x64的参数
    -skip_update_server_mods \ # 不更新模组，直接启动（我们会用别的方式更新模组，因此请勿修改）
    -ugc_directory "/home/steam/dst/ugc_mods" \ # 指定容器内部的V2模组存放路径，方便管理（请勿修改）
    -persistent_storage_root "/home/steam/dst" \ # 游戏程序需要指定的持久化根目录（请勿修改）
    -conf_dir "save" \ # "<persistent_storage_root>/<conf_dir>"是所有存档的总目录（请勿修改）
    -cluster "Cluster_1" \ # 当前世界存档的目录名，请与<cluster>保持一致
    -shard "Master" \ # 此处是开启地上世界，通常叫Master（实际上改成什么都行）
    ... # 其它你需要的参数，参考官方指南
```

#### 示例二：启动地下世界

首先，您可以预先在宿主机的存档目录里放入合适的配置：

```
# 在您的宿主机上
<path>/dst/save/<cluster>/cluster.ini
<path>/dst/save/<cluster>/<shard>/server.ini
```

`<cluster>`代表一个存档的根目录，取名随意，如`Cluster_1`；`<shard>`代表世界实例的目录，对于地下世界，通常会使用`Caves`（但其实取名随意）

至于配置文件如何设定，请参考官方指南：

[Dedicated Server Settings Guide](https://forums.kleientertainment.com/forums/topic/64552-dedicated-server-settings-guide/)

稍后我们会通过`docker run`的`-v`参数挂载到容器的对应目录：

```
# 在容器内部
/home/steam/dst/save/<cluster>/cluster.ini
/home/steam/dst/save/<cluster>/<shard>/server.ini
```

这样在`dontstarve_dedicated_server_nullrenderer_x64`启动的时候就会读取这些配置文件

以下是启动地下世界的指令模板，请根据您的实际需求修改：

```shell
docker run --rm -itd --name=dst-caves \
    -p 11000:10999/udp \ # 当前世界实例需要使用的端口，:左边的端口号需要在宿主机上未被占用
    -p 27017:27016/udp \ # Steam需要使用的端口，:左边的端口号需要在宿主机上未被占用
    -v "<path>/dst/save:/home/steam/dst/save" \ # 挂载存档路径
    -v "<path>/dst/mods:/home/steam/dst/game/mods" \ # 挂载V1模组路径
    -v "<path>/dst/ugc_mods:/home/steam/dst/ugc_mods" \ # 挂载V2模组路径
    superjump22/dontstarvetogether:latest \
    # 以下为传给dontstarve_dedicated_server_nullrenderer_x64的参数
    -skip_update_server_mods \ # 不更新模组，直接启动（我们会用别的方式更新模组，因此请勿修改）
    -ugc_directory "/home/steam/dst/ugc_mods" \ # 指定容器内部的V2模组存放路径，方便管理（请勿修改）
    -persistent_storage_root "/home/steam/dst" \ # 游戏程序需要指定的持久化根目录（请勿修改）
    -conf_dir "save" \ # "<persistent_storage_root>/<conf_dir>"是所有存档的总目录（请勿修改）
    -cluster "Cluster_1" \ # 当前世界存档的目录名，请与<cluster>保持一致
    -shard "Caves" \ # 此处是开启地下世界，通常叫Caves（实际上改成什么都行）
    ... # 其它你需要的参数，参考官方指南
```

#### 示例三：下载/更新模组

首先，您需要修改宿主机上的`dedicated_server_mods_setup.lua`，往其中写入需要下载/更新的模组：

```shell
# 在您的宿主机上修改<path>/dst/mods/dedicated_server_mods_setup.lua：
ServerModSetup("3055375757")
ServerModSetup("398858801")
```

（`3055375757`和`398858801`是创意工坊的模组id）

以下为下载/更新模组的指令模板：

```shell
docker run --rm -itd --name=dst-updatemods \
    -v "<path>/dst/save:/home/steam/dst/save" \ # 挂载存档路径
    -v "<path>/dst/mods:/home/steam/dst/game/mods" \ # 挂载V1模组路径
    -v "<path>/dst/ugc_mods:/home/steam/dst/ugc_mods" \ # 挂载V2模组路径
    superjump22/dontstarvetogether:latest \
    # 以下为传给dontstarve_dedicated_server_nullrenderer_x64的参数
    -only_update_server_mods \ # 只更新模组，不启动世界
    -ugc_directory "/home/steam/dst/ugc_mods" \ # 指定容器内部的V2模组存放路径，方便管理（请勿修改）
    -persistent_storage_root "/home/steam/dst" \ # 游戏程序需要指定的持久化根目录（请勿修改）
    -conf_dir "temp" \ # "<persistent_storage_root>/<conf_dir>"是所有存档的总目录，这里用”temp“来下载/更新模组（别用"save"）
```
