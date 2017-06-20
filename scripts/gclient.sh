sudo su
set -x

echo "Reading config...." >&2
source /vagrant/setup.rc

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
sudo sed -i "s/MONITORNODE/$cfg_ip_gserver/g" /etc/ganglia/gmond.conf
sudo sed -i "s/THISNODEID/$cfg_ip_gclient/g" /etc/ganglia/gmond.conf
sudo /etc/init.d/ganglia-monitor restart

exit 0