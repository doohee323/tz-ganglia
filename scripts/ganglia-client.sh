sudo su
set -x

export DEBIAN_FRONTEND=noninteractive

apt-get -y update
apt-get -y upgrade

##########################################
# firewall rules
##########################################
sudo mkdir -p /etc/iptables
sudo cp /vagrant/etc/iptables/rules /etc/iptables/rules

sudo sed -i "s/^iptables-restore//g" /etc/network/if-up.d/iptables
sudo sh -c "echo 'iptables-restore < /etc/iptables/rules' >> /etc/network/if-up.d/iptables"
sudo iptables-restore < /etc/iptables/rules

##########################################
# install ganglia
##########################################
sudo apt-get install ganglia-monitor -y

sudo cp /vagrant/etc/ganglia/client/gmond.conf /etc/ganglia/gmond.conf
sudo sed -i "s/MONITORNODE/$cfg_ip_ganglia-server/g" /etc/ganglia/gmond.conf
sudo sed -i "s/THISNODEID/$cfg_ip_ganglia-client/g" /etc/ganglia/gmond.conf
sudo /etc/init.d/ganglia-monitor restart

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
