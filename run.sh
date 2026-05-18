#!/bin/bash
cd /opt/web-nodejs-spx-gc-gerador-de-caracteres-cpp
git checkout master || git checkout -b master
git pull
/usr/bin/docker compose up -d
