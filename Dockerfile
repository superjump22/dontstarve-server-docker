###################################################################
# Dockerfile that builds a Don't Starve Together dedicated server #
###################################################################

# First stage: Download game
FROM cm2network/steamcmd:root AS downloader

# Build Arguments for downloader
ARG DEBIAN_FRONTEND=noninteractive
ARG LANG=C.UTF-8
ARG LC_ALL=C.UTF-8
ARG DST_BRANCH
ARG DST_BUILDID
ARG DST_TIMEUPDATED

# Environment settings for downloader
ENV STEAM_APPID=343050
ENV STEAM_WORKSHOPID=322330
ENV DST_DIR=${HOMEDIR}/dst
ENV DST_GAMEDIR=${DST_DIR}/game
ENV DST_SAVEDIR=${DST_DIR}/save
ENV DST_MODDIR=${DST_GAMEDIR}/mods
ENV DST_UGCMODDIR=${DST_GAMEDIR}/ugc_mods

RUN set -x && \
    # Install dependencies
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests libcurl4-gnutls-dev:i386 libcurl3-gnutls && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* && \
    chown -R root:root "${STEAMCMDDIR}" && \
    # Install Don't Starve Together
    mkdir -p "${DST_DIR}" "${DST_GAMEDIR}" "${DST_SAVEDIR}" "${DST_MODDIR}" "${DST_UGCMODDIR}" && \
    bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir ${DST_GAMEDIR} +login anonymous +app_update ${STEAM_APPID} -beta "${DST_BRANCH}" validate +quit

# Second stage: Setup environment
FROM downloader AS game

# Build Arguments
ARG DST_BRANCH
ARG DST_BUILDID
ARG DST_TIMEUPDATED
ARG DST_VERSION

# Clear inherited labels
LABEL maintainer=""

# Metadata
LABEL branch="${DST_BRANCH}"
LABEL buildid="${DST_BUILDID}"
LABEL timeupdated="${DST_TIMEUPDATED}"
LABEL version="${DST_VERSION}"

# Additional environment settings
ENV DST_VERSION=${DST_VERSION}

# Set the working directory
WORKDIR ${DST_GAMEDIR}/bin64

# Specify the entrypoint
ENTRYPOINT ["./dontstarve_dedicated_server_nullrenderer_x64"]

# Third stage: Setup toolbox
FROM game AS toolbox

ENV DST_ENTRYPOINT=${DST_GAMEDIR}/bin64/dontstarve_dedicated_server_nullrenderer_x64

WORKDIR /root

RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests build-essential libreadline-dev unzip cmake curl wget tree jq ca-certificates && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# Install Lua
COPY lua-5.4.6.tar.gz /root/
RUN tar -zxf lua-5.4.6.tar.gz && \
    cd lua-5.4.6 && \
    make linux test && \
    make install

# Install LuaRocks & rapidjson
COPY luarocks-3.11.0.tar.gz /root/
RUN tar -zxf luarocks-3.11.0.tar.gz && \
    cd luarocks-3.11.0 && \
    ./configure && make && make install && \
    luarocks install rapidjson

# Unzip lua scripts of Don't Starve Together
RUN cd ${DST_GAMEDIR}/data && \
    unzip databundles/scripts.zip -d scripts_backup && \
    rm -f databundles/scripts.zip

COPY entry.sh /root/entry.sh
COPY toolbox /root/toolbox

RUN chmod +x /root/entry.sh

ENTRYPOINT ["/root/entry.sh"]

CMD ["help"]
