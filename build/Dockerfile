###################################################################
# Dockerfile that builds a Don't Starve Together dedicated server #
###################################################################

# Base image: cm2network/steamcmd:root
FROM cm2network/steamcmd:root-bookworm

# Build Arguments
ARG DEBIAN_FRONTEND=noninteractive
ARG LANG=C.UTF-8
ARG LC_ALL=C.UTF-8
ARG DST_BRANCH
ARG DST_BUILDID
ARG DST_TIMEUPDATED

# Metadata
LABEL branch="${DST_BRANCH}"
LABEL buildid="${DST_BUILDID}"
LABEL timeupdated="${DST_TIMEUPDATED}"

# Environment settings
ENV STEAM_APP_ID=343050
ENV STEAM_WORKSHOP_ID=322330
ENV DST_BRANCH=${DST_BRANCH}
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
    chown -R root:root "${STEAMCMDDIR}" && \
    # Install Don't Starve Together
    mkdir -p "${DST_DIR}" "${DST_GAME_DIR}" "${DST_SAVE_DIR}" "${DST_MOD_DIR}" "${DST_UGC_MOD_DIR}" && \
    bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir ${DST_GAME_DIR} +login anonymous +app_update ${STEAM_APP_ID} -beta "${DST_BRANCH}" validate +quit

# Set the working directory
WORKDIR ${DST_GAME_DIR}/bin64

# Specify the entrypoint
ENTRYPOINT ["./dontstarve_dedicated_server_nullrenderer_x64"]