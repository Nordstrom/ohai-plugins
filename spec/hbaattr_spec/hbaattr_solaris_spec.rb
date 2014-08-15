# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'ostruct'
require 'spec_helper'

describe Ohai::System, 'Hbaattr solaris plugin' do
  let(:fcinfo_shell_out) do
    <<-EOF.gsub(/^\s*/, '')
    HBA Port WWN: 10000000c97c4b7a
      OS Device Name: /dev/cfg/c2
      Node WWN: 2000000c97c4b7a
      Manufacturer: Emulex
 Model: LP11000-S
 Firmware Version: 2.80x5 (B3D2.80X5)
 FCode/BIOS Version: Boot:5.03a0 Fcode:3.01a1
 Serial Number: 0999BG0-083700002D
 Driver Name: emlxs
 Driver Version: 2.80.8.0 (2012.09.17.15.45)
 Type: N-port
 State: online
 Supported Speeds: 1Gb 2Gb 4Gb
 Current Speed: 4Gb
HBA Port WWN: 10000000c97c4b7a
 OS Device Name: /dev/cfg/c2
 Node WWN: 2000000c97c4b7a
 Manufacturer: Emulex
 Model: LP11000-#S
 Firmware Version: 2.80x5 (B3D2.80X5)
 FCode/BIOS Version: Boot:5.03a0 Fcode:3.01a1
 Driver Version: 2.80.8.0 (2012.09.17.15.45)
 Type: N-port
 State: online
 Supported Speeds: 1Gb 2Gb 4Gb
 Current Speed: 2Gb
  EOF
  end

  before(:each) do
    @plugin = (get_plugin('hbaattr'))
    @plugin.stub(:collect_os).and_return(:solaris2)
    @plugin.stub(:shell_out).with('/usr/sbin/fcinfo hba-port').and_return(OpenStruct.new(stdout: fcinfo_shell_out))
    @plugin.run
  end

  it 'should return a Mash' do
    expect @plugin.to be_a_kind_of(Mash)
  end

  it 'should not include tab or new line characters' do
    string = @plugin[:hbaattr][:host1].to_s
    string2 = @plugin[:hbaattr][:host2].to_s
    expect(string).to_not include('\t' || '\n')
    expect(string2).to_not include('\t' || '\n')
  end

  it 'should include all given attributes' do
    expect(@plugin[:hbaattr][:host1]).to include((:port_name),
      (:driver_name),
      (:driver_version),
      (:fcode_bios_version),
      (:firmware_version),
      (:model),
      (:node_name),
      (:os_device_name),
      (:serial_number),
      (:speed),
      (:state),
      (:supported_speeds),
      (:type))
  end

  it 'should include all given hosts' do
    expect(@plugin[:hbaattr]).to have_key(:host1)
  end

end
