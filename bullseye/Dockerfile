###################################################################
# Dockerfile that builds a Don't Starve Together dedicated server #
###################################################################

# Base image: cm2network/steamcmd:root
FROM cm2network/steamcmd:root

LABEL maintainer="superjump22"

# Environment settings
ENV DST_DIR=${HOMEDIR}/dst
ENV DST_GAME_DIR=${DST_DIR}/game
ENV DST_SAVE_DIR=${DST_DIR}/save
ENV DST_MOD_DIR=${DST_GAME_DIR}/mods
ENV DST_UGC_MOD_DIR=${DST_DIR}/ugc_mods

# Build Arguments
ARG DEBIAN_FRONTEND=noninteractive
ARG LANG=C.UTF-8
ARG LC_ALL=C.UTF-8
ARG BRANCH=public

RUN set -x && \
    # Install dependencies
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests libcurl4-gnutls-dev:i386 libcurl3-gnutls screen && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* && \
    # Install Don't Starve Together, execute as user
    su "${USER}" -c 'mkdir -p "${DST_DIR}" "${DST_GAME_DIR}" "${DST_SAVE_DIR}" "${DST_UGC_MOD_DIR}"' && \
    su "${USER}" -c  \
        'if [ "${BRANCH}" = "public" ]; then \
            ${STEAMCMDDIR}/steamcmd.sh \
            +force_install_dir ${DST_GAME_DIR} \
            +login anonymous \
            +app_update 343050 validate \
            +quit; \
        else \
            ${STEAMCMDDIR}/steamcmd.sh \
            +force_install_dir ${DST_GAME_DIR} \
            +login anonymous \
            +app_update 343050 -beta "${BRANCH}" validate \
            +quit; \
        fi'

# Set up volumes
VOLUME ["${DST_SAVE_DIR}", "${DST_MOD_DIR}", "${DST_UGC_MOD_DIR}"]

# Expose necessary ports
EXPOSE 10888/udp 10999/udp 27016/udp

# Set the working directory
WORKDIR ${DST_GAME_DIR}/bin64

# Specify the entrypoint
ENTRYPOINT ["./dontstarve_dedicated_server_nullrenderer_x64"]