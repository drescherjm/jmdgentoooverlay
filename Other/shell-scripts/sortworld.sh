#! /bin/bash

sort /var/lib/portage/world > /tmp/world.sorted
cp /tmp/world.sorted /var/lib/portage/world

