#!/bin/bash

# (c) Stanislaw Trust 2022

# Disclaimer
##################################################################################################################
# You running this script/function means you will not blame the author(s)
# if this breaks your stuff. This script/function is provided AS IS without warranty of any kind. 
# Author(s) disclaim all implied warranties including, without limitation, 
# any implied warranties of merchantability or of fitness for a particular purpose. 
# The entire risk arising out of the use or performance of the sample scripts and documentation remains with you.
# In no event shall author(s) be held liable for any damages whatsoever 
# (including, without limitation, damages for loss of business profits, business interruption, 
# loss of business information, or other pecuniary loss) arising out of the use of or inability 
# to use the script or documentation. Neither this script/function, 
# nor any part of it other than those parts that are explicitly copied from others, 
# may be republished without author(s) express written permission. 
# Author(s) retain the right to alter this disclaimer at any time.
##################################################################################################################

# Vars
iUser="$(whoami)"
iGroup="$(id -gn)"
iHOME=$HOME
ipv4="$(curl -s -4 ifconfig.me)"
# Start the action



PS3="Please enter your choice: "
options=("Install 1" "Update 2" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Install 1")
            sudo apt update \
                && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y --no-install-recommends \
                tzdata \
                git \
                ca-certificates \
                curl \
                build-essential \
                libssl-dev \
                pkg-config \
                libclang-dev \
                cmake
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source $HOME/.cargo/env

            git clone -v https://github.com/MystenLabs/sui.git $HOME/sui
            cd $HOME/sui

            git remote add upstream https://github.com/MystenLabs/sui 
            git fetch upstream
            git checkout --track upstream/devnet
            sudo mkdir -p /var/sui/db
            chown -R $iUser:$iGroup /var/sui

            cp -pv crates/sui-config/data/fullnode-template.yaml  /var/sui/fullnode.yaml
            sed -i.bak "s/db-path:.*/db-path: \"\/var\/sui\/db\"/ ; s/genesis-file-location:.*/genesis-file-location: \"\/var\/sui\/genesis.blob\"/" /var/sui/fullnode.yaml

            curl -fLJ https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob -o /var/sui/genesis.blob

            cargo build -p sui-node --release

            sudo bash -c 'cat > /etc/systemd/system/sui.service' << EOF
            [Unit]
            Description=Sui Node
            After=network.target syslog.target

            [Service]
            Type=simple
            User=$iUser
            Group=$iGroup
            Restart=always
            RestartSec=1
            LimitNOFILE=1024000
            ExecStart=$iHOME/sui/target/release/sui-node --config-path /var/sui/fullnode.yaml
            ExecReload=/bin/kill -s HUP \$MAINPID
            ExecStop=/bin/kill -s QUIT \$MAINPID

            [Install]
            WantedBy=multi-user.target
EOF

            sudo systemctl restart systemd-journald
            sudo systemctl daemon-reload
            sudo systemctl enable --now sui
            systemctl --no-pager status sui

            ###
            printf "\nPost this address to #node-ip-application\n\n>>  http://$ipv4:9000 \n\n"
            printf "\n\n\n Check node status command: systemctl status sui\nNode log: journalctl -u sui -f \n "
            break
            ;;
        "Update 2")
            rm -rf /var/sui/db/*
            cd $HOME/sui
            git fetch upstream
            git checkout -B devnet --track upstream/devnet
            curl -fLJ https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob -o /var/sui/genesis.blob
            cp -pv crates/sui-config/data/fullnode-template.yaml  /var/sui/fullnode.yaml
            sed -i.bak "s/db-path:.*/db-path: \"\/var\/sui\/db\"/ ; s/genesis-file-location:.*/genesis-file-location: \"\/var\/sui\/genesis.blob\"/" /var/sui/fullnode.yaml
            sudo systemctl restart sui
            sleep 2
            systemctl --no-pager status sui
            break
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
