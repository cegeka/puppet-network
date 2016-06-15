require 'spec_helper_acceptance'

describe 'network' do
  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
      network::if::static { 'eth7':
        ensure    => 'up',
        ipaddress => '10.10.10.1',
        netmask   => '255.255.255.0',
        dns1      => '8.8.8.8',
        dns2      => '8.8.4.4',
        peerdns   => true
      }


      network::alias { 'eth7:1':
        ensure    => 'up',
        ipaddress => '10.10.20.1',
        netmask   => '255.255.255.0',
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures  => false)
      apply_manifest(pp, :catch_changes   => true)
    end
    describe file('/etc/sysconfig/network-scripts/ifcfg-eth7') do
      it { should contain 'BOOTPROTO=none' }
      it { should contain 'DEVICE=eth7' }
      it { should contain 'TYPE=Ethernet' }
      it { should contain 'IPADDR=10.10.10.1' }
      it { should contain 'NETMASK=255.255.255.0' }
      it { should contain 'DNS1=8.8.8.8' }
      it { should contain 'DNS2=8.8.4.4' }
      it { should contain 'PEERDNS=yes' }
    end
    describe file('/etc/sysconfig/network-scripts/ifcfg-eth7:1') do
      it { should contain 'BOOTPROTO=none' }
      it { should contain 'DEVICE=eth7:1' }
      it { should contain 'TYPE=Ethernet' }
      it { should contain 'IPADDR=10.10.20.1' }
      it { should contain 'NETMASK=255.255.255.0' }
    end
  end
end
