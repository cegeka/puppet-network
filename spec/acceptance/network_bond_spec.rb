require 'spec_helper_acceptance'

describe 'network' do
  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
      network::bond::dynamic { 'bond0':
        ensure => 'up',
      }

      network::bond::static { 'bond1':
        ensure       => 'up',
        ipaddress    => '10.10.0.1',
        netmask      => '255.255.255.0',
        gateway      => '10.10.0.254',
        mtu          => '1500',
        bonding_opts => 'mode=active-backup miimon=100',
        dns1         => '8.8.8.8',
        dns2         => '8.8.4.4',
        peerdns      => true
      }

      network::bond::slave { 'eth8':
        macaddress   => 'C4:34:6B:B8:05:25',
        ethtool_opts => 'autoneg off speed 1000 duplex full',
        master       => 'bond1',
      }

      network::bond::slave { 'eth9':
        macaddress   => 'C4:34:6B:B8:05:24',
        ethtool_opts => 'autoneg off speed 1000 duplex full',
        master       => 'bond0',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures  => false)
      apply_manifest(pp, :catch_changes   => true)
    end

    describe file('/etc/sysconfig/network-scripts/ifcfg-eth9') do
      it { should contain 'DEVICE=eth9' }
      it { should contain 'HWADDR=C4:34:6B:B8:05:24' }
      it { should contain 'MASTER=bond0' }
      it { should contain 'ETHTOOL_OPTS="autoneg off speed 1000 duplex full"' }
      it { should contain 'NM_CONTROLLED=no' }
      it { should contain 'TYPE=Ethernet' }
      it { should contain 'SLAVE=yes' }
    end

    describe file('/etc/sysconfig/network-scripts/ifcfg-eth8') do
      it { should contain 'DEVICE=eth8' }
      it { should contain 'HWADDR=C4:34:6B:B8:05:25' }
      it { should contain 'MASTER=bond1' }
      it { should contain 'ETHTOOL_OPTS="autoneg off speed 1000 duplex full"' }
      it { should contain 'NM_CONTROLLED=no' }
      it { should contain 'TYPE=Ethernet' }
      it { should contain 'SLAVE=yes' }
    end

    describe file('/etc/sysconfig/network-scripts/ifcfg-bond0') do
      it { should contain 'DEVICE=bond0' }
      it { should contain 'BOOTPROTO=dhcp' }
      it { should contain 'TYPE=Ethernet' }
    end

    describe file('/etc/sysconfig/network-scripts/ifcfg-bond1') do
      it { should contain 'DEVICE=bond1' }
      it { should contain 'BOOTPROTO=none' }
      it { should contain 'TYPE=Ethernet' }
      it { should contain 'IPADDR=10.10.0.1' }
      it { should contain 'GATEWAY=10.10.0.254' }
      it { should contain 'MTU=1500' }
      it { should contain 'BONDING_OPTS="mode=active-backup miimon=100"' }
      it { should contain 'DNS1=8.8.8.8' }
      it { should contain 'DNS2=8.8.4.4' }
      it { should contain 'PEERDNS=yes' }
      it { should contain 'NETMASK=255.255.255.0' }
    end
  end
end
