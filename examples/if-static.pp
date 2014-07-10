network::if::static { 'eth1':
  ensure       => 'up',
  ipaddress    => '1.2.3.4',
  netmask      => '255.255.255.0',
  gateway      => '1.2.3.1',
  macaddress   => 'fe:fe:fe:aa:aa:aa',
  mtu          => '9000',
  ethtool_opts => 'autoneg off speed 1000 duplex full',
}
