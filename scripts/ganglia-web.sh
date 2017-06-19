sudo su
set -x

echo "Reading config...." >&2
source /vagrant/setup.rc

export DEBIAN_FRONTEND=noninteractive

apt-get -y update
apt-get -y upgrade

apt-get install -y ganglia-monitor rrdtool gmetad ganglia-webfrontend

##########################################
# apache2 setting
##########################################
#cp /etc/ganglia-webfrontend/apache.conf /etc/apache2/sites-enabled/ganglia.conf
#rm /etc/apache2/sites-enabled/000-default.conf

#sudo sh -c "echo '' >> /etc/apache2/apache2.conf"
#sudo sh -c "echo 'ServerName localhost' >> /etc/apache2/apache2.conf"
 
#/etc/init.d/apache2 restart
#service apache2 restart
#service apache2 stop

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

sudo ufw allow "Nginx HTTP"
sudo ufw reload

sudo rm -rf /var/www/html/
sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default

sudo touch /etc/nginx/sites-available/ganglia
sudo ln -s /etc/nginx/sites-available/ganglia /etc/nginx/sites-enabled/ganglia

sudo cp /vagrant/etc/nginx/ganglia /etc/nginx/sites-available/ganglia
sudo service nginx stop
sudo nginx -s stop
sudo nginx

##########################################
# first stop main gmond (ganglia-monitor) and gmetad processes
##########################################
stop ganglia-monitor
stop gmetad
/etc/init.d/gmetad stop
/etc/init.d/ganglia-monitor stop
/etc/init.d/apache2 stop

rm /etc/init.d/ganglia-monitor
rm /etc/init.d/gmetad

###############################################################
# modify ganglia-monitor configs and its upstart jobs
###############################################################
clusters=""

for i in 8649; 
do
	#copy base file for ganglia
	cp /etc/ganglia/gmond.conf "/etc/ganglia/gmond-$i.conf"
	sed -i "s/host_dmax = 0/host_dmax = 600/g" "/etc/ganglia/gmond-$i.conf"
	sed -i "s/send_metadata_interval = 0/send_metadata_interval = 30\\noverride_hostname = monitor-$i/g" "/etc/ganglia/gmond-$i.conf"
	sed -i "s/name = \"unspecified\"/name = \"cluster-$i\"/g" "/etc/ganglia/gmond-$i.conf"
	#replace only first instance
	sed -i "0,/mcast_join = 239.2.11.71/s/mcast_join = 239.2.11.71/host = 127.0.0.1/g" "/etc/ganglia/gmond-$i.conf"
	sed -i "s/bind = 239.2.11.71//g" "/etc/ganglia/gmond-$i.conf"
	sed -i "s/port = 8649/port = $i/g" "/etc/ganglia/gmond-$i.conf"
	
	#now init job
	cp /etc/init/ganglia-monitor.conf "/etc/init/gmond-$i.conf"
	sed -i "s/env PIDFILE=\"\\/var\\/run\\/ganglia-monitor.pid\"/env PIDFILE=\"\\/var\\/run\\/gmond-$i.pid\"/g" "/etc/init/gmond-$i.conf"
	sed -i "s/exec \\/usr\\/sbin\\/gmond --pid-file=\$PIDFILE/exec \\/usr\\/sbin\\/gmond --pid-file=\$PIDFILE -c \\/etc\\/ganglia\\/gmond-$i.conf/g" "/etc/init/gmond-$i.conf"
	
	clusters+="data_source \"cluster-$i\" 60 localhost:$i\n"
	
	echo start gmond-$i
	start gmond-$i
done

#delete originals
rm /etc/init/ganglia-monitor.conf
rm /etc/ganglia/gmond.conf

##########################################
# modify gmetad
##########################################
sed -i "s/data_source \"my cluster\" localhost/$clusters/g" /etc/ganglia/gmetad.conf
sed -i "s/# carbon_server \"my.node1.box\"/carbon_server $NODE1/g" /etc/ganglia/gmetad.conf
sed -i "s/# node1_prefix \"datacenter1.gmetad\"/node1_prefix \"ganglia\"/g" /etc/ganglia/gmetad.conf

start gmetad
/etc/init.d/apache2 start

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
