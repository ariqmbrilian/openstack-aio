sudo ip link set dev ens36 up
sudo apt update
sudo apt install -y python3-dev libffi-dev gcc libssl-dev
sudo apt install -y python3-venv
python3 -m venv openstack/venv
source ~/openstack/venv/bin/activate
pip install -U pip
pip install 'ansible<3.0'
pip install kolla-ansible
sudo mkdir -p /etc/kolla
sudo chown ariq:ariq /etc/kolla -R
mkdir ~/openstack
cp -r ~/openstack/venv/share/kolla-ansible/etc_examples/kolla/* /etc/kolla
cp ~/openstack/venv/share/kolla-ansible/ansible/inventory/* .
sudo mkdir /etc/ansible
cat << EOF > etc/ansible/ansible.cfg
[defaults]
host_key_checking=False
pipelining=True
forks=100
EOF
ansible -i all-in-one all -m ping
kolla-genpwd
echo "kolla_base_distro: "ubuntu"" >> /etc/kolla/globals.yml
echo "network_interface: "ens160"" >> /etc/kolla/globals.yml
echo "neutron_external_interface: "ens36"" >> /etc/kolla/globals.yml
echo "kolla_internal_vip_address: "192.168.99.116"" >> /etc/kolla/globals.yml
kolla-ansible -i all-in-one bootstrap-servers
kolla-ansible -i all-in-one prechecks
kolla-ansible -i all-in-one deploy
pip install python-openstackclient
kolla-ansible post-deploy
. /etc/kolla/admin-openrc.sh
/usr/local/share/kolla-ansible/init-runonce
