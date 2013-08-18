# == Definition: network::bridge::static
#
# Creates a bridge interface with static IP address.
#
# === Parameters:
#
#   $ensure       - required - up|down
#   $ipaddress    - required
#   $netmask      - required
#   $gateway      - optional
#   $userctl      - optional - defaults to false
#   $peerdns      - optional
#   $dns1         - optional
#   $dns2         - optional
#   $domain       - optional
#   $delay        - optional - defaults to 0
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$name.
#
# === Sample Usage:
#
#   network::bridge::static { 'br0':
#     ensure    => 'up',
#     ipaddress => '10.21.30.248',
#     netmask   => '255.255.255.128',
#     domain    => 'is.domain.com domain.com',
#   }
#
# === Authors:
#
# David Cote
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2013 David Cote, unless otherwise noted.
# Copyright (C) 2013 Mike Arnold, unless otherwise noted.
#
define network::bridge::static (
  $ensure,
  $ipaddress,
  $netmask,
  $gateway = '',
  $bootproto = 'static',
  $userctl = false,
  $peerdns = false,
  $dns1 = '',
  $dns2 = '',
  $domain = '',
  $delay = '0'
) {
  # Validate our regular expressions
  $states = [ '^up$', '^down$' ]
  validate_re($ensure, $states, '$ensure must be either "up" or "down".')
  # Validate our data
  if ! is_ip_address($ipaddress) { fail("${ipaddress} is not an IP address.") }
  # Validate booleans
  validate_bool($userctl)

  include 'network'

  $interface = $name

  # Deal with the case where $dns2 is non-empty and $dns1 is empty.
  if $dns2 != '' {
    if $dns1 == '' {
      $dns1_real = $dns2
      $dns2_real = ''
    } else {
      $dns1_real = $dns1
      $dns2_real = $dns2
    }
  } else {
    $dns1_real = $dns1
    $dns2_real = $dns2
  }

  $onboot = $ensure ? {
    'up'    => 'yes',
    'down'  => 'no',
    default => undef,
  }

  file { "ifcfg-${interface}":
    ensure  => 'present',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => "/etc/sysconfig/network-scripts/ifcfg-${interface}",
    content => template('network/ifcfg-br.erb'),
    notify  => Service['network'],
  }
} # define network::bridge::static
