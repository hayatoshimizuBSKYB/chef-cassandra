
require 'ohai/application'
require 'json'

ohai = Ohai::System.new
os = `ohai`
oj = JSON.parse(os)


oj["network"]["interfaces"]["eth0"]["addresses"].each_key do |key|
  family = oj["network"]["interfaces"]["eth0"]["addresses"][key]["family"]
  if family.eql? "inet"
    node[:cassandra][:ip_address] = key
  end
end

