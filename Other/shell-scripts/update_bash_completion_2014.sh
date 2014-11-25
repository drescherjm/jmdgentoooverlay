#!/bin/bash

find /usr/share/bash-completion -maxdepth 1 -type f \
        '!' -name 'bash_completion' -exec emerge -1v {} +

find /etc/bash_completion.d -type l -delete

emerge -n app-shells/bash-completion
