
require 'ohai/application'
require 'json'

ohai = Ohai::System.new

node[:cassandra][:ohai] = JSON.parse(ohai.to_json)

node[:cassandra][:ohai][:network][:interfaces][:eth0][:addresses].each_key do |key|
  family = node[:cassandra][:ohai][:network][:interfaces][:eth0][:addresses][key][:family]
  if family.eql? "inet"
    node[:cassandra][:ip_address] = key
  end
end

