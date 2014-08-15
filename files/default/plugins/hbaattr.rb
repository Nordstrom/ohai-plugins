# Cookbook Name: ohai_plugins
# Recipe: default
#
# Copyright 2014, Nordstrom, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

Ohai.plugin(:HbaAttr) do

  provides 'hbaattr'
  hba_attributes = Mash.new
  uniform_names = {
    'HBA Port WWN' => 'port_name',
    'Node WWN' => 'node_name',
    'Supported Speeds' =>  'supported_speeds',
    'Current Speed' => 'speed',
    'OS Device Name' => 'os_device_name',
    'Manufacturer' => 'manufacturer',
    'Model' => 'model',
    'Firmware Version' => 'firmware_version',
    'FCode/BIOS Version' => 'fcode_bios_version',
    'Serial Number' => 'serial_number',
    'Driver Name' => 'driver_name',
    'Driver Version' => 'driver_version',
    'Type' => 'type',
    'State' => 'state'
  }

  collect_data(:default) do
    hba_attributes = 'Platform not supported'
    hbaattr hba_attributes
  end

  collect_data(:solaris2) do
    stdout = shell_out('/usr/sbin/fcinfo hba-port').stdout
    stdarray = cleanup_output(stdout)
    host_num = 0
    host = 'unknown port'
    stdarray.each do |key_value_pair|
      key, value = key_value_pair.split(':', 2)
      value.strip!
      if key == 'HBA Port WWN'
        host_num += 1
        host = "host#{host_num}"
        hba_attributes[host] = Mash.new
      end
      attr = defined(uniform_names[key]) ? uniform_names[key] : key
      hba_attributes[host][attr] = value
    end
    hbaattr hba_attributes
  end

  collect_data(:linux) do
    host_base = '/sys/class/fc_host/'
    @attributes = %w(port_name port_state node_name supported_speeds speed)
    all_dirs = find_all_host_dirs('/sys/class/fc_host/host*/')
    hosts = find_host_names(all_dirs)
    hosts.each do |host|
      hba_attributes[host] = Mash.new
      @attributes.each do |attr|
        hba_attributes[host][attr] = get_attr_value(File.join(host_base, host), attr)
      end
    end
    hbaattr hba_attributes
  end

  def cleanup_output(output)
    to_array = output.split("\n")
    to_array.each { |item| item.gsub!(/^\s*/, '') }
  end

  def find_all_host_dirs(host_path)
    Dir.glob(host_path)
  end

  def find_host_names(all_host_dirs)
    all_hosts = []
    all_host_dirs.each do |dir|
      host = File.basename(dir)
      all_hosts.push(host)
    end
    all_hosts
  end
  #comment

  def get_attr_value(dir, attr)
    path = File.join(dir, attr)
    begin
      File.readlines(path).first.chomp
    rescue Errno::ENOENT
      'No value found'
    end
  end
end
