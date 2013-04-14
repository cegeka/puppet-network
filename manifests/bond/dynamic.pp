# Definition: network::bond::dynamic
#
# Creates a bonded interface with static IP address and enables the bonding
# driver.  bootp support is unknown for bonded interfaces.  Thus no bootp
# bond support in this module.
#
# Parameters:
#   $ensure       - required - up|down
#   $mtu          - optional
#   $ethtool_opts - optional
#   $bonding_opts - optional
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  # bonded master interface - dhcp
#  network::bond::dynamic { 'bond2':
#    ensure => 'up',
#  }
#
define network::bond::dynamic (
  $ensure,
  $mtu = '',
  $ethtool_opts = '',
  $bonding_opts = ''
) {
  # Validate our regular expressions
  $states = [ '^up$', '^down$' ]
  validate_re($ensure, $states, '$ensure must be either "up" or "down".')

  network_if_base { $title:
    ensure       => $ensure,
    ipaddress    => '',
    netmask      => '',
    gateway      => '',
    macaddress   => '',
    bootproto    => 'dhcp',
    mtu          => $mtu,
    ethtool_opts => $ethtool_opts,
    bonding_opts => $bonding_opts,
  }

  $ifstate = $ensure ? {
    'up'    => Exec["ifup-${title}"],
    'down'  => Exec["ifdown-${title}"],
    default => undef,
  }

  # Only install "alias bondN bonding" on old OSs that support
  # /etc/modprobe.conf.
  case $::operatingsystem {
    /^(RedHat|CentOS|OEL|OracleLinux|SLC|Scientific)$/: {
      case $::operatingsystemrelease {
        /^[45]/: {
          augeas { "modprobe.conf_${title}":
            context => '/files/etc/modprobe.conf',
            changes => [
              "set alias[last()+1] ${title}",
              'set alias[last()]/modulename bonding',
            ],
            onlyif  => "match alias[*][. = '${title}'] size == 0",
            before  => $ifstate
          }
        }
        default: {}
      }
    }
    'Fedora': {
      case $::operatingsystemrelease {
        /^(1|2|3|4|5|6|7|8|9|10|11)$/: {
          augeas { "modprobe.conf_${title}":
            context => '/files/etc/modprobe.conf',
            changes => [
              "set alias[last()+1] ${title}",
              'set alias[last()]/modulename bonding',
            ],
            onlyif  => "match alias[*][. = '${title}'] size == 0",
            before  => $ifstate
          }
        }
        default: {}
      }
    }
    default: {}
  }
} # define network::bond::dynamic
