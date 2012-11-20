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

if node[:cassandra][:initial_token] == false

  # Write tokentool to a an executable file
  cookbook_file "/tmp/tokentool.py" do
    source "tokentool.py"
    mode "0755"
  end

  # Run tokentool accordingly
  ruby_block "Run Tokentool" do
    block do
      node[:cassandra][:data_centres].each do |dc|
        node[:cassandra][:cluster_size_list] = cluster_size_list + " " + dc[:cluster_size]
      end
    end
  end

  execute "/tmp/tokentool.py #{ node[:cassandra][:cluster_size_list] } > /tmp/tokens" do
    creates "/tmp/tokens"
  end
  
  ruby_block "ReadTokens" do
    block do
      results = []
      open("/tmp/tokens").each do |line|
        results << line.chomp.split(':')[1].strip if line.include? 'Node'
      end

      Chef::Log.info "Setting token for this node."
      private_ip = node[:cloud][:private_ips].first
      token_position = node[:cassandra][:nodes][private_ip.to_str]
      node[:cassandra][:initial_token] = results[node[:cassandra][token_position.to_str]]
    end
  end
end
