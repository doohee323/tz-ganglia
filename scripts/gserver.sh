sudo su
set -x

echo "Reading config...." >&2
source /vagrant/setup.rc

export DEBIAN_FRONTEND=noninteractive

apt-get -y update
apt-get -y upgrade

apt-get install -y ganglia-monitor rrdtool gmetad ganglia-webfrontend
#service ganglia-monitor stop 
#service gmetad stop
#apt-get purge -y ganglia-monitor gmetad
#rm -Rf /etc/ganglia

###############################################################
# install nginx
###############################################################
sudo apt-get remove --purge apache2  -y
sudo apt-get autoclean -y 
sudo apt-get autoremove -y

sudo add-apt-repository ppa:nginx/development
sudo apt-get update 
sudo apt-get install nginx php5 php5-fpm php5-gd -y

sudo chown -R www-data:www-data /usr/share/ganglia-webfrontend/

#sudo ufw --force enable
sudo ufw allow "Nginx HTTP"
sudo ufw reload
#sudo ufw status verbose

sudo rm -rf /var/www/html/
sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default

sudo touch /etc/nginx/sites-available/ganglia
sudo ln -s /etc/nginx/sites-available/ganglia /etc/nginx/sites-enabled/ganglia

sudo cp /vagrant/etc/nginx/ganglia /etc/nginx/sites-available/ganglia
sudo service nginx stop
sudo nginx -s stop

##########################################
# firewall rules
##########################################
sudo mkdir -p /etc/iptables
sudo cp /vagrant/etc/iptables/rules /etc/iptables/rules

sudo sed -i "s/^iptables-restore//g" /etc/network/if-up.d/iptables
sudo sh -c "echo 'iptables-restore < /etc/iptables/rules' >> /etc/network/if-up.d/iptables"
sudo iptables-restore < /etc/iptables/rules

##########################################
# first stop main gmond (ganglia-monitor) and gmetad processes
##########################################
sudo cp /vagrant/etc/ganglia/server/gmetad.conf /etc/ganglia/gmetad.conf
service gmetad restart

sudo cp /vagrant/etc/ganglia/server/gmond.conf /etc/ganglia/gmond.conf
sudo sed -i "s/MONITORNODE/localhost/g" /etc/ganglia/gmond.conf
sudo sed -i "s/THISNODEID/localhost/g" /etc/ganglia/gmond.conf
sudo /etc/init.d/ganglia-monitor restart

#sudo service gmetad stop
#sudo /etc/init.d/ganglia-monitor stop 

sudo nginx -s stop
sudo nginx

exit 0
