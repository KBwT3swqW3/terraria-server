# Terraria Server

## Description

This is mainly a personal repo for creating a "more secure" docker container
for hosting [Terraria](https://www.terraria.org) dedicated server.

## Table of Contents

- [Terraria Server](#terraria-server)
  - [Description](#description)
  - [Table of Contents](#table-of-contents)
  - [Info](#info)
  - [Quick Start](#quick-start)
  - [Docker Compose Example](#docker-compose-example)

## Info

The container expects a serverconfig.txt in the volume mount `/world` and
that the host path is owned by user 30000

As the Terraria server expects a tty and attached stdin those need to be enabled
at runtime `-ti` this means if you're running the container in detached mode `-d`
access to the console is gained with docker attach `docker attach <container name>`


## Quick Start

First create your data directory for storing the Terraria world and configs if
for example we wanted to save the new world in `/opt/terraria/my_world` we would
run the following commands:

> sudo mkdir /opt/terraria/my_world

Then you can create a serverconfig.txt file (see
[serverconfig.txt.example](serverconfig.txt.example) as an example) in the
`/opt/terraria/my_world` directory and make sure it's owned by the user 30000
replace vim with your text editor of choice:

> sudo vim /opt/terraria/my_world/serverconfig.txt  
> sudo chown 30000:30000 -R /opt/terraria/my_world  
> sudo chmod u+rwX,go-rwx -R /opt/terraria/my_world

You can then run the container mounting in your new volume:

> docker run --rm --name terraria -it -d -p 7777:7777 --cap-drop=ALL -v
> /opt/terraria/my_world:/world kbwt3swqw3/terraria-server:latest

To get access to the console you can then attach to stdin/stdout of the running
image with:

> docker attach terraria

You can detach from the session by pressing `ctrl-p` followed by `ctrl-q`

## Docker Compose Example

``` YAML
version: '3'
services:
  terraria:
    image: "kbwt3swqw3/terraria-server:latest"
    volumes:
      - /path/to/host/storage/my_world:/world
    ports:
      - "7777:7777"
    cap_drop:
      - ALL
    stdin_open: true
    tty: true
    read_only: true
    privileged: false
    restart: unless-stopped
```