#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Unit tests for neutron::agents::vpnaas class
#

require 'spec_helper'

describe 'neutron::agents::vpnaas' do

  let :pre_condition do
    "class { 'neutron': }"
  end

  let :params do
    {}
  end

  let :default_params do
    { :package_ensure              => 'present',
      :vpn_device_driver           => 'neutron.services.vpn.device_drivers.ipsec.OpenSwanDriver',
      :interface_driver            => 'neutron.agent.linux.interface.OVSInterfaceDriver',
      :purge_config                => false,
    }
  end

  let :test_facts do
    { :operatingsystem           => 'default',
      :operatingsystemrelease    => 'default'
    }
  end

  shared_examples_for 'neutron vpnaas agent' do
    let :p do
      default_params.merge(params)
    end

    it { is_expected.to contain_class('neutron::params') }

    it_configures 'openswan vpnaas_driver'

    it 'passes purge to resource' do
      is_expected.to contain_resources('neutron_vpnaas_agent_config').with({
        :purge => false
      })
    end

    it 'configures vpnaas_agent.ini' do
      is_expected.to contain_neutron_vpnaas_agent_config('vpnagent/vpn_device_driver').with_value(p[:vpn_device_driver]);
      is_expected.to contain_neutron_vpnaas_agent_config('ipsec/ipsec_status_check_interval').with_value('<SERVICE DEFAULT>');
      is_expected.to contain_neutron_vpnaas_agent_config('DEFAULT/interface_driver').with_value(p[:interface_driver]);
    end

    it 'installs neutron vpnaas agent package' do
      if platform_params.has_key?(:vpnaas_agent_package)
        is_expected.to contain_package('neutron-vpnaas-agent').with(
          :name   => platform_params[:vpnaas_agent_package],
          :ensure => p[:package_ensure],
          :tag    => ['openstack', 'neutron-package'],
        )
        is_expected.to contain_package('neutron').that_requires('Anchor[neutron::install::begin]')
        is_expected.to contain_package('neutron').that_notifies('Anchor[neutron::install::end]')
      end
    end
  end

  shared_examples_for 'openswan vpnaas_driver' do
    it 'installs openswan packages' do
      if platform_params.has_key?(:vpnaas_agent_package)
        is_expected.to contain_package('openswan')
      end
      is_expected.to contain_package('openswan').with(
        :ensure => 'present',
        :name   => platform_params[:openswan_package]
      )
    end
  end

  context 'on Debian platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge({
         :osfamily => 'Debian',
         :os       => { :name  => 'Debian', :family => 'Debian', :release => { :major => '8', :minor => '0' } },
      }))
    end

    let :platform_params do
      { :openswan_package     => 'openswan',
        :vpnaas_agent_package => 'neutron-vpn-agent'}
    end

    it_configures 'neutron vpnaas agent'

    context 'when configuring the LibreSwan driver' do
      before do
      params.merge!(
        :vpn_device_driver => 'neutron_vpnaas.services.vpn.device_drivers.libreswan_ipsec.LibreSwanDriver'
      )
      end

      it 'fails when configuring LibreSwan on Debian' do
        is_expected.to raise_error(Puppet::Error, /LibreSwan is not supported on osfamily Debian/) 
      end
    end
  end

  context 'on RedHat 6 platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge(
        { :osfamily                  => 'RedHat',
          :operatingsystemrelease    => '6.5',
          :os       => { :name  => 'CentOS', :family => 'RedHat', :release => { :major => '6', :minor => '5' } },
          :operatingsystemmajrelease => 6 }))
    end

    let :platform_params do
      { :openswan_package     => 'openswan',
        :vpnaas_agent_package => 'openstack-neutron-vpnaas'}
    end

    it_configures 'neutron vpnaas agent'
  end

  context 'on RedHat 7 platforms' do
    let :facts do
      @default_facts.merge(test_facts.merge(
        { :osfamily                  => 'RedHat',
          :operatingsystemrelease    => '7.1.2',
          :os       => { :name  => 'CentOS', :family => 'RedHat', :release => { :major => '7', :minor => '1.2' } },
          :operatingsystemmajrelease => 7 }))
    end

    let :platform_params do
      { :openswan_package     => 'libreswan',
        :libreswan_package    => 'libreswan',
        :vpnaas_agent_package => 'openstack-neutron-vpnaas'}
    end

    it_configures 'neutron vpnaas agent'

    context 'when configuring the LibreSwan driver' do
      before do
      params.merge!(
        :vpn_device_driver => 'neutron_vpnaas.services.vpn.device_drivers.libreswan_ipsec.LibreSwanDriver'
      )
      end

      it 'configures LibreSwan' do
        is_expected.to contain_neutron_vpnaas_agent_config('vpnagent/vpn_device_driver').with_value(params[:vpn_device_driver]);
        is_expected.to contain_package('libreswan').with(
          :ensure => 'present',
          :name   => platform_params[:libreswan_package]
        )
        end
      end
  end
end
