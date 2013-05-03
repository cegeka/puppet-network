# aliased bonded interface (range)
network::bond::alias::range { 'bond1':
  ensure          => 'up',
  ipaddress_start => '1.2.3.5',
  ipaddress_end   => '1.2.3.20',
  clonenum_start  => '0',
  noaliasrouting  => true,
}
