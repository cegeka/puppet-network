network::if::dynamic { 'eth3':
  ensure       => 'up',
  macaddress   => 'fe:fe:fe:ae:ae:ae',
  mtu          => '1500',
  ethtool_opts => 'autoneg off speed 100 duplex full',
}
