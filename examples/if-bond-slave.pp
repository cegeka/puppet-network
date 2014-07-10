network::bond::slave { 'eth1':
  macaddress   => $macaddress_eth1,
  ethtool_opts => 'autoneg off speed 1000 duplex full',
  master       => 'bond0',
}
