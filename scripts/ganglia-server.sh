sudo su
set -x

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

sudo ufw --force enable
sudo ufw allow "Nginx HTTP"
sudo ufw allow 8653/tcp
sudo ufw allow 8653/udp
sudo ufw allow 8649/tcp
sudo ufw allow 8649/udp
sudo ufw reload
sudo ufw status verbose

sudo rm -rf /var/www/html/
sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default

sudo touch /etc/nginx/sites-available/ganglia
sudo ln -s /etc/nginx/sites-available/ganglia /etc/nginx/sites-enabled/ganglia

sudo cp /vagrant/etc/nginx/ganglia /etc/nginx/sites-available/ganglia
sudo service nginx stop
sudo nginx -s stop

##########################################
# first stop main gmond (ganglia-monitor) and gmetad processes
##########################################
sudo cp /vagrant/etc/ganglia/server/gmond.conf /etc/ganglia/gmond.conf
service ganglia-monitor restart 

sudo cp /vagrant/etc/ganglia/server/gmetad.conf /etc/ganglia/gmetad.conf
service gmetad restart

sudo nginx -s stop
sudo nginx

exit 0

##########################################
# firewall rules
##########################################
mkdir -p /etc/iptables
cp /vagrant/etc/iptables/rules /etc/iptables/rules

sed -i "s/^iptables-restore//g" /etc/network/if-up.d/iptables
echo "iptables-restore < /etc/iptables/rules" >> /etc/network/if-up.d/iptables
iptables-restore < /etc/iptables/rules

##########################################
# install failtoban
##########################################
apt-get install fail2ban sendmail -y
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sed -i "s/^destemail.*/destemail = doohee323@gmail.com/g" /etc/fail2ban/jail.local
sed -i "s/^action = %(action_)s/action = %(action_mwl)s/g" /etc/fail2ban/jail.local
service fail2ban stop
service fail2ban start
service rsyslog restart

exit 0
