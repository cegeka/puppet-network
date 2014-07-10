network::bond::static { 'bond0':
  ensure       => 'up',
  ipaddress    => '1.2.3.5',
  netmask      => '255.255.255.0',
  gateway      => '1.2.3.1',
  mtu          => '9000',
  bonding_opts => 'mode=active-backup miimon=100',
}
