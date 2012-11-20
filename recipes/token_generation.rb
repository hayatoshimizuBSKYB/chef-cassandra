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
    token_position = node[:cassandra][:nodes][private_ip].split(':')
    dc = token_position[0]
    position = token_position[1]
    
    
    results = []
    open("/tmp/tokens").each do |line|
      results << line.chomp.split(':')[2].strip if line.match(".*#{dc}:\sNodes")
    end

    Chef::Log.info "Setting token for this node."
    
    node[:cassandra][:initial_token] = results[node[:cassandra][position]]
  end
end
