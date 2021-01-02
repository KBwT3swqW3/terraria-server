FROM alpine AS builder

RUN apk add --update-cache \
  libxml2-utils \
  unzip \
  wget

RUN adduser --no-create-home --disabled-password --uid 30000 terraria

ENV INSTALL_PATH=/server
RUN mkdir $INSTALL_PATH \
  && chown terraria:terraria $INSTALL_PATH

USER terraria:terraria

# Links at the bottom of terraria.org PC Server Version
# ENV TERRARIA_URL=https://terraria.org/system/dedicated_servers/archives/000/000/042/original/terraria-server-1412.zip
RUN wget -qO /tmp/terraria.html https://terraria.org/ \
  && export LATEST_DL_PATH=$(xmllint --html --xpath '/html/body/div[contains(@class, "page-footer")]/a' /tmp/terraria.html 2>/dev/null | egrep -Eo '(\/system/dedicated_servers/.*?.zip)\?' | tr -d '?') \
  && export TERRARIA_URL=$(echo https://terraria.org$LATEST_DL_PATH) \
  && echo $TERRARIA_URL \
  && wget -qO $INSTALL_PATH/terraria.zip $TERRARIA_URL \
  && cd $INSTALL_PATH \
  && unzip terraria.zip \
  && rm terraria.zip \
  && mv $INSTALL_PATH/*/* $INSTALL_PATH/ \
  && rm -rf $INSTALL_PATH/Windows \
  && rm -rf $INSTALL_PATH/Mac \
  && mv $INSTALL_PATH/Linux/* $INSTALL_PATH/ \
  && chmod 700 $INSTALL_PATH/TerrariaServer.bin.x86_64 \
  && rm -rf $INSTALL_PATH/Linux/ $INSTALL_PATH/TerrariaServer.bin.x86



FROM ubuntu:20.04

RUN groupadd -g 30000 terraria \
  && useradd --no-log-init --create-home -u 30000 -g terraria terraria

ENV INSTALL_PATH=/server
RUN mkdir $INSTALL_PATH \
  && chown terraria:terraria $INSTALL_PATH

COPY --from=builder $INSTALL_PATH $INSTALL_PATH

RUN chown terraria:terraria -R $INSTALL_PATH

VOLUME /world
WORKDIR /server
EXPOSE 7777

USER terraria

CMD ["./TerrariaServer.bin.x86_64", "-config", "/world/serverconfig.txt"]
