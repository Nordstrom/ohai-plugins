# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

require 'ohai'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'

  PLUGIN_PATH = File.expand_path('../../files/default/plugins', __FILE__)

  def get_plugin(plugin, ohai = Ohai::System.new, path = PLUGIN_PATH)
    loader = Ohai::Loader.new(ohai)
    loader.load_plugin(File.join(path, "#{plugin}.rb"))
  end

end
