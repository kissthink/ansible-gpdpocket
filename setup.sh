#!/bin/sh

# install all dependencies for ansible scripts to run
deb -i bootstrap/*.deb

# run ansible scripts
ansible main.yml