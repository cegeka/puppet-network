require 'spec_helper_acceptance'

describe 'network' do
  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS
          network::bridge::static { 'br0':
            ensure    => 'up',
            ipaddress => '10.21.30.248',
            netmask   => '255.255.255.128',
          }

          network::bridge::dynamic { 'br1':
            ensure => 'up',
          }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures  => false)
      apply_manifest(pp, :catch_changes   => true)
    end

    describe file('/etc/sysconfig/network-scripts/ifcfg-br0') do
      it { should contain 'IPADDR=10.21.30.248' }
      it { should contain 'NETMASK=255.255.255.128' }
      it { should contain 'DEVICE=br0' }
      it { should contain 'TYPE=Bridge' }
      it { should contain 'BOOTPROTO=static' }
    end

    describe file('/etc/sysconfig/network-scripts/ifcfg-br1') do
      it { should contain 'BOOTPROTO=dhcp' }
      it { should contain 'DEVICE=br1' }
      it { should contain 'TYPE=Bridge' }
    end
  end
end
