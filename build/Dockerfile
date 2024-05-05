###################################################################
# Dockerfile that builds a Don't Starve Together dedicated server #
###################################################################

# Base image: cm2network/steamcmd:root
FROM cm2network/steamcmd:root

# Build Arguments
ARG DEBIAN_FRONTEND=noninteractive
ARG LANG=C.UTF-8
ARG LC_ALL=C.UTF-8
ARG DST_BRANCH
ARG DST_BUILDID
ARG DST_TIMEUPDATED

# Metadata
LABEL dockerfile="https://github.com/superjump22/dontstarve-server-docker/blob/main/build/Dockerfile"
LABEL dockerhub="https://hub.docker.com/r/superjump22/dontstarvetogether"
LABEL github="https://github.com/superjump22/dontstarve-server-docker"
LABEL maintainer="superjump"
LABEL repo="superjump22/dontstarvetogether"
LABEL branch="${DST_BRANCH}"
LABEL buildid="${DST_BUILDID}"
LABEL timeupdated="${DST_TIMEUPDATED}"

# Environment settings
ENV SteamAppId=322330
ENV SteamGameId=322330
ENV DST_DIR=${HOMEDIR}/dst
ENV DST_GAME_DIR=${DST_DIR}/game
ENV DST_SAVE_DIR=${DST_DIR}/save
ENV DST_MOD_DIR=${DST_GAME_DIR}/mods
ENV DST_UGC_MOD_DIR=${DST_GAME_DIR}/ugc_mods

RUN set -x && \
    # Install dependencies
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests libcurl4-gnutls-dev:i386 libcurl3-gnutls && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* && \
    # Install Don't Starve Together, execute as user
    su "${USER}" -c 'mkdir -p "${DST_DIR}" "${DST_GAME_DIR}" "${DST_SAVE_DIR}" "${DST_UGC_MOD_DIR}"' && \
    su "${USER}" -c  '${STEAMCMDDIR}/steamcmd.sh +force_install_dir ${DST_GAME_DIR} +login anonymous +app_update 343050 -beta "${DST_BRANCH}" validate +quit'

# Set the working directory
WORKDIR ${DST_GAME_DIR}/bin64

# Specify the entrypoint
ENTRYPOINT ["./dontstarve_dedicated_server_nullrenderer_x64"]