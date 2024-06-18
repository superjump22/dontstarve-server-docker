ARG DST_BRANCH
FROM superjump22/dontstarvetogether:${DST_BRANCH}

ENV DST_ENTRYPOINT=${DST_GAMEDIR}/bin64/dontstarve_dedicated_server_nullrenderer_x64

WORKDIR /root

RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests build-essential libreadline-dev unzip cmake curl wget tree jq ca-certificates && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# Install Lua
RUN curl -L -R -O https://github.com/lua/lua/archive/refs/tags/v5.4.6.tar.gz && \
    tar -zxf lua-5.4.6.tar.gz && \
    cd lua-5.4.6 && \
    make linux test && \
    make install

# Install LuaRocks & rapidjson
RUN curl -L -R -O https://luarocks.org/releases/luarocks-3.11.0.tar.gz && \
    tar -zxf luarocks-3.11.0.tar.gz && \
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