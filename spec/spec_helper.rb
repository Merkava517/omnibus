require 'chefspec'
require 'chefspec/berkshelf'
require 'chef/sugar'

# load all libraries for testing
Dir['libraries/*.rb'].each { |f| require_relative "../#{f}" }

RSpec.configure do |config|
  config.before(:each) do
    # We need to stub the build_user_home because ChefSpec isn't smart enough
    # to realize that a resource has already been touched once the attribute
    # changes. Global state is hard...
    allow_any_instance_of(Chef::Recipe).to receive(:build_user_home)
      .and_return('/home/omnibus')

    # Allow us to mimic a Windows node
    stub_const('File::ALT_SEPARATOR', '\\')
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with('SYSTEMDRIVE').and_return('C:')
    # This stops "undefined method `split' for nil:NilClass" errors from
    # being thrown by ChefSpec. This works around a Chef compatibility
    # issue that was introduced in Chef 12.18+.
    #
    # See the following Chef issue for more details:
    #
    #   https://github.com/chef/chef/issues/5769
    #
    allow(ENV).to receive(:[]).with('PATH').and_return('')
  end

  config.log_level = :fatal

  # Guard against people using deprecated RSpec syntax
  config.raise_errors_for_deprecations!

  # Why aren't these the defaults?
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  # Set a default platform (this is overriden as needed)
  config.platform  = 'ubuntu'
  config.version   = '16.04'

  # Be random!
  config.order = 'random'
end
