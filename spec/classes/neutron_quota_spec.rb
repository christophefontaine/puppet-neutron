require 'spec_helper'

describe 'neutron::quota' do

  let :params do
    {}
  end

  let :default_params do
    { :quota_firewall_rule       => -1,
      :quota_network_gateway     => 5,
      :quota_packet_filter       => 100 }
  end

  let :facts do
    { :operatingsystem           => 'default',
      :operatingsystemrelease    => 'default'
    }
  end

  shared_examples_for 'neutron quota' do
    let :params_hash do
      default_params.merge(params)
    end

    it 'configures quota in neutron.conf' do
      params_hash.each_pair do |config,value|
        is_expected.to contain_neutron_config("quotas/#{config}").with_value( value )
      end
    end
  end

  context 'with default parameters' do
    it_configures 'neutron quota'
  end

  context 'with provided parameters' do
    before do
      params.merge!({
        :quota_network             => 20,
        :quota_subnet              => 20,
        :quota_port                => 100,
        :quota_router              => 20,
        :quota_floatingip          => 100,
        :quota_security_group      => 20,
        :quota_security_group_rule => 200,
        :quota_firewall            => 1,
        :quota_firewall_policy     => 1,
        :quota_firewall_rule       => -1,
        :quota_healthmonitor       => -1,
        :quota_member              => -1,
        :quota_network_gateway     => 5,
        :quota_packet_filter       => 100,
        :quota_loadbalancer        => 10,
        :quota_pool                => 10,
        :quota_vip                 => 10
      })
    end

    it_configures 'neutron quota'
  end
end
