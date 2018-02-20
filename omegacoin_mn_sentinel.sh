echo "=================================================================="
echo "Cryptosh OMEGA MN Sentinel Install"
echo "=================================================================="

sudo apt-get update
sudo apt-get -y install python-virtualenv
sudo apt-get -y install virtualenv
git clone https://github.com/omegacoinnetwork/sentinel.git && cd sentinel
virtualenv ./venv
./venv/bin/pip install -r requirements.txt

crontab -l > mycron
#echo new cron into cron file
echo "* * * * * cd /root/sentinel && ./venv/bin/python bin/sentinel.py >/dev/null 2>&1" >> mycron
#install new cron file
crontab mycron
rm mycron
./venv/bin/py.test ./test
omegacoin_conf=/path/to/omegacoin.conf
SENTINEL_DEBUG=1 ./venv/bin/python bin/sentinel.py