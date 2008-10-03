#! /bin/sh

glsa-check -tv all | awk '{print $1}' | xargs -n1 -i glsa-check -fv {}
