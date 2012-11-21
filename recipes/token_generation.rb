#
# Cookbook Name:: cassandra
# Recipe:: token_generation
#
# Copyright 2012, DataStax
#
# Apache License
#

###################################################
# 
# Calculate the Token
# 
###################################################


# Write tokentool to a an executable file
cookbook_file "/tmp/tokentool.py" do
  source "tokentool.py"
  mode "0755"
end

# Run tokentool accordingly
ruby_block "Run Tokentool" do
  block do
    no_dcs = node[:cassandra][:data_centres].size
    Chef::Log.info "Number of data centres: #{no_dcs}"
    
    cluster_size_list = ""
    node[:cassandra][:data_centres].each do |dc, cluster_size|
      cluster_size_list = cluster_size_list + " " + cluster_size
    end
    Chef::Log.info "Cassandra cluster sizes: cluster_size_list"
    `/tmp/tokentool.py #{ cluster_size_list } > /tmp/tokens`
  end
end


ruby_block "ReadTokens" do
  block do
    
    private_ip = node[:cloud][:private_ips].first
    Chef::Log.info "private ip: #{private_ip}"

    token_position = node[:cassandra][:nodes][private_ip].split(':')
    Chef::Log.info "Token position: #{token_position}"
    dc = token_position[0]
    position = token_position[1]
    
    
    results = []
    open("/tmp/tokens").each do |line|
      Chef::Log.info "Line: #{line}"
      if line.match(".*#{dc}:\s*Node")
        Chef::Log.info "Line matched: #{line}"
        results << line.chomp.split(':')[2].strip 
      end 
    end

    Chef::Log.info "Setting token for this node."
    
    node[:cassandra][:initial_token] = results[position.to_i]
  end
end
