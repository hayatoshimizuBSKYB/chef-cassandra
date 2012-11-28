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


ruby_block "Set token for this node" do
  block do
    private_ip = node[:cloud][:private_ips].first
    Chef::Log.info "private ip: #{private_ip}"

    dc = ""
    node_no = 0
    node[:cassandra][:nodes].each_pair do |position, ip_address|
      dc = position.split(":")[0]
      node_no = position.split(":")[1].to_i
    end
    
    results = []
    open("/tmp/tokens").each do |line|
      if line.match(".*#{dc}:\s*Node")
        results << line.chomp.split(':')[2].strip 
      end 
    end

    Chef::Log.info "Setting token for this node."
    
    node[:cassandra][:initial_token] = results[node_no]
  end
end
