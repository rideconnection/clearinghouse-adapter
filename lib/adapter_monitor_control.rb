require 'win32/service'
require 'rbconfig'

include Win32

RUBY = File.join(RbConfig::CONFIG['bindir'], RbConfig::CONFIG['ruby_install_name'])
TARGET = File.expand_path("adapter_monitor.rb", File.dirname(__FILE__))

if ARGV[0] == "install"
  puts "Installing service..."

  # TODO make sure Ruby and target exist
  # TODO provide ability to update the service

  Service.create(
    :service_name => 'adapter_test_service',
    :host => nil,
    :service_type => Service::WIN32_OWN_PROCESS,
    :description => 'A proof of concept for the Clearinghouse Adapter',
    :start_type => Service::AUTO_START,
    :error_control => Service::ERROR_NORMAL,
    :binary_path_name => "\"#{RUBY}\" \"#{TARGET}\"",
    :service_start_name => 'LocalSystem',
    :display_name => 'Adapter Test Service'
  )
  puts "Done."
elsif ARGV[0] == "remove"
  puts "Removing service..."
  Service.delete('adapter_test_service')
  puts "Done."
else
  puts "Command not recognized, use install or remove."
end