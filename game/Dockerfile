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
ENV STEAM_APPID=343050
ENV STEAM_WORKSHOPID=322330
ENV DST_BRANCH=${DST_BRANCH}
ENV DST_BUILDID=${DST_BUILDID}
ENV DST_TIMEUPDATED=${DST_TIMEUPDATED}
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
    bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir ${DST_GAMEDIR} +login anonymous +app_update ${STEAM_APPID} -beta "${DST_BRANCH}" validate +quit && \
    # Set DST_VERSION from version.txt
    DST_VERSION=$(cat ${DST_GAMEDIR}/version.txt)

# Set DST_VERSION environment variable
ENV DST_VERSION=${DST_VERSION}

# Set the working directory
WORKDIR ${DST_GAMEDIR}/bin64

# Specify the entrypoint
ENTRYPOINT ["./dontstarve_dedicated_server_nullrenderer_x64"]
