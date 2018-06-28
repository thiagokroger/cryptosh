sudo apt-get update
sudo apt install nodejs-legacy -y
sudo apt-get install npm -y
sudo apt-get install -y

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb http://repo.mongodb.org/apt/debian wheezy/mongodb-org/3.2 main" > /etc/apt/sources.list.d/mongodb-org-3.2.list

sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl start mongod


cat <<EOF > ./config_mongo.js
use explorerdb
db.createUser( { user: "iquidus", pwd: "3xp!0reR", roles: [ "readWrite" ] } )
EOF

mongo < config_mongo.js
rm -rf config_mongo.js

git clone https://github.com/iquidus/explorer explorer
cd explorer && npm install --production

wget https://raw.githubusercontent.com/thiagokroger/cryptosh/master/explorers/$1_settings.json
mv $1_settings.json ./settings.json

npm install -g forever
forever start -c "npm start" ./

node scripts/sync.js index reindex
rm -f tmp/index.pid

cat <<EOF > ./config_cron
*/1 * * * * cd explorer && /usr/bin/nodejs scripts/sync.js index update > /dev/null 2>&1
*/5 * * * * cd explorer && /usr/bin/nodejs scripts/peers.js > /dev/null 2>&1
EOF
crontab config_cron
rm config_cron
