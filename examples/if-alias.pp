network::alias { 'eth0:1':
  ensure    => 'up',
  ipaddress => '1.2.3.5',
  netmask   => '255.255.255.0',
}
