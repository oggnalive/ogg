#!/bin/bash

sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get install libxcb-xinerama0 -y

cd $HOME

wget "https://dl.walletbuilders.com/download?customer=551dbd8088fa7c503397382ff323cad009185e9b7abf405f86&filename=oggnalive-qt-linux.tar.gz" -O oggnalive-qt-linux.tar.gz

mkdir $HOME/Desktop/oggnalive

tar -xzvf oggnalive-qt-linux.tar.gz --directory $HOME/Desktop/oggnalive

mkdir $HOME/.oggnalive

cat << EOF > $HOME/.oggnalive/oggnalive.conf
rpcuser=rpc_oggnalive
rpcpassword=dR2oBQ3K1zYMZQtJFZeAerhWxaJ5Lqeq9J2
rpcbind=127.0.0.1
rpcallowip=127.0.0.1
listen=1
server=1
addnode=node3.walletbuilders.com
EOF

cat << EOF > $HOME/Desktop/oggnalive/start_wallet.sh
#!/bin/bash
SCRIPT_PATH=\`pwd\`;
cd \$SCRIPT_PATH
./oggnalive-qt
EOF

chmod +x $HOME/Desktop/oggnalive/start_wallet.sh

cat << EOF > $HOME/Desktop/oggnalive/mine.sh
#!/bin/bash
SCRIPT_PATH=\`pwd\`;
cd \$SCRIPT_PATH
while :
do
./oggnalive-cli generatetoaddress 1 \$(./oggnalive-cli getnewaddress)
done
EOF

chmod +x $HOME/Desktop/oggnalive/mine.sh
    
exec $HOME/Desktop/oggnalive/oggnalive-qt &

sleep 15

exec $HOME/Desktop/oggnalive/oggnalive-cli -named createwallet wallet_name="" &
    
sleep 15

cd $HOME/Desktop/oggnalive/

clear

exec $HOME/Desktop/oggnalive/mine.sh