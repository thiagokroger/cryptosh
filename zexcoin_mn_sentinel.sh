echo "=================================================================="
echo "Cryptosh ZEX MN Sentinel Install"
echo "=================================================================="

sudo apt-get update
sudo apt-get -y install python-virtualenv
sudo apt-get -y install virtualenv
cd /root/.zexcoincore

wget https://github.com/thiagokroger/cryptosh/raw/master/sentinel/zexcoin/sentinel.tar.gz

tar -zxvf sentinel.tar.gz && cd sentinel


virtualenv ./venv
./venv/bin/pip install -r requirements.txt

crontab -l > zex
#echo new cron into cron file
echo "* * * * * cd /root/.zexcoincore && ./venv/bin/python bin/sentinel.py >/dev/null 2>&1" >> zex
#install new cron file
crontab zex
rm zex
./venv/bin/py.test ./test

SENTINEL_DEBUG=1 ./venv/bin/python bin/sentinel.py