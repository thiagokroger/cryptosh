systemctl stop Apollon
rm Apollond.tar.gz >/dev/null 2>&1
wget https://github.com/apollondeveloper/ApollonCoin/releases/download/1.0.6/Apollond.tar.gz
tar xvzf Apollond.tar.gz
cp Apollond /usr/local/bin
systemctl start Apollon
