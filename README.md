lxc-container
=============

Handle LXC container creation, configuration and automation

Setup puppet client
-------------------

To setup the container to use puppet you can simply run the lxc-puppet.sh script

    curl -sS https://raw.github.com/marten-cz/lxc-container/master/lxc-puppet.sh | sudo bash

or

    wget -q --no-check-certificate -O - https://raw.github.com/marten-cz/lxc-container/master/lxc-puppet.sh | sudo bash

You can call the script with parameter --puppet [server] to specify the puppet server URI.

    curl -sS https://raw.github.com/marten-cz/lxc-container/master/lxc-puppet.sh | sudo bash /dev/stdin --puppet puppet.lan
