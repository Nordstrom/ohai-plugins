# Copyright 2014, Nordstrom, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# license ^^

require 'spec_helper'

describe Ohai::System, 'Hbaattr linux plugin' do

  let(:host2_hash) do
    { 'port_name' => '0x10000090fa1fd128',
      'port_state' => 'Online',
      'node_name' => '0x20000090fa1fd128',
      'supported_speeds' => '2Gbit, 4Gbit, 8Gbit',
      'speed' => '4Gbit',
      'symbolic_name' => 'Emulex AJ763B/AH403A FV1.11A5 DV8.3.5.86.1p'
    }
  end

  let(:host3_hash) do
    { 'port_name' => '0x10000090fa1fd129',
      'port_state' => 'Offline',
      'node_name' => '0x20000090fa1fd129',
      'supported_speeds' => '2Gbit, 4Gbit, 8Gbit',
      'speed' => '4Gbit',
      'symbolic_name' => 'Emulex AJ763B/AH403A FV1.11A5 DV8.3.5.86.1p'
    }
  end

  let(:attr) do
    %w{ port_name
        port_state
        node_name
        supported_speeds
        speed
        symbolic_name
      }
  end

  before(:each) do
    @plugin = (get_plugin('hbaattr'))
    @plugin.stub(:collect_os).and_return(:linux)
    Dir.stub(:glob).with('/sys/class/fc_host/host*/').and_return(['/sys/class/fc_host/host2/', '/sys/class/fc_host/host3/'])
    host2_hash.each do |key, value|
      File.stub(:readlines).with("/sys/class/fc_host/host2/#{key}").and_return([value])
    end
    host3_hash.each do |key, value|
      File.stub(:readlines).with("/sys/class/fc_host/host3/#{key}").and_return([value])
    end
  end

  it 'should not have collect_data raise and error' do
    @plugin.run
    expect { @plugin.collect_data }.to_not raise_error
  end

  it 'should return a Mash' do
    @plugin.run
    expect @plugin.to be_a_kind_of(Mash)
  end

  it 'should report the hosts correct port name' do
    @plugin.run
    expect(@plugin[:hbaattr][:host2][:port_name]).to eq '0x10000090fa1fd128'
  end

  it 'should report the hosts correct port state' do
    @plugin.run
    expect(@plugin[:hbaattr][:host2][:port_state]).to eq 'Online'
  end

  it 'should report the hosts correct node name' do
    @plugin.run
    expect(@plugin[:hbaattr][:host2][:node_name]).to eq '0x20000090fa1fd128'
  end

  it 'should report the hosts supported speeds' do
    @plugin.run
    expect(@plugin[:hbaattr][:host2][:supported_speeds]).to eq '2Gbit, 4Gbit, 8Gbit'
  end

  it 'should report the hosts current speed' do
    @plugin.run
    expect(@plugin[:hbaattr][:host2][:speed]).to eq '4Gbit'
  end

  it 'should report the hosts port_name' do
    @plugin.run
    expect(@plugin[:hbaattr][:host3][:port_name]).to eq '0x10000090fa1fd129'
  end

  it 'should report the hosts port_state' do
    @plugin.run
    expect(@plugin[:hbaattr][:host3][:port_state]).to eq 'Offline'
  end

  it 'should report the hosts correct node name' do
    @plugin.run
    expect(@plugin[:hbaattr][:host3][:node_name]).to eq '0x20000090fa1fd129'
  end

  it 'should report the hosts supported speeds' do
    @plugin.run
    expect(@plugin[:hbaattr][:host3][:supported_speeds]).to eq '2Gbit, 4Gbit, 8Gbit'
  end

  it 'should report the hosts current speed' do
    @plugin.run
    expect(@plugin[:hbaattr][:host3][:speed]).to eq '4Gbit'
  end

  it 'should contain the expected number of hosts' do
    @plugin.run
    num_of_hosts = @plugin[:hbaattr].keys
    expect(num_of_hosts.length).to eq 2
  end

  it 'should notify if plugin does not supported platforms' do
    allow(@plugin).to receive(:collect_os).and_call_original
    @plugin.stub(:collect_os).with(:Cloud)
    @plugin.run
    expect(@plugin[:hbaattr]).to eq 'Platform not supported'
  end

  it 'should raise an error with invalid host' do
    Dir.stub(:glob).with('/sys/class/fc_host/host*/').and_return(['/sys/class/fc_host/host4/'])
    attr.each do |item|
      File.stub(:readlines).with("/sys/class/fc_host/host4/#{item}").and_raise(Errno::ENOENT)
    end
    @plugin.run
    expect(@plugin[:hbaattr][:host4][:port_name]).to eq 'No value found'
  end
end
