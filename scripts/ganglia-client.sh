sudo su
set -x

echo "Reading config...." >&2
source /vagrant/setup.rc

export DEBIAN_FRONTEND=noninteractive

apt-get -y update
apt-get -y upgrade

apt-get install -y ganglia-monitor

##########################################
# first stop main gmond (ganglia-monitor) and gmetad processes
##########################################
sudo cp /vagrant/etc/ganglia/server/gmond.conf /etc/ganglia/gmond.conf
service ganglia-monitor restart 

##########################################
# firewall rules
##########################################
mkdir -p /etc/iptables
cp /vagrant/etc/iptables/rules /etc/iptables/rules

sed -i "s/^iptables-restore//g" /etc/network/if-up.d/iptables
echo "iptables-restore < /etc/iptables/rules" >> /etc/network/if-up.d/iptables
iptables-restore < /etc/iptables/rules

exit 0

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
