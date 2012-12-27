#
# Cookbook Name:: cassandra
# Recipe:: create_seed_list
#
# Copyright 2011, DataStax
#
# Apache License
#

###################################################
# 
# Build the Seed List
# 
###################################################


if not node[:cassandra][:seed]
  seeds = []
  node[:env_props][:nodes].each_pair do |key, value|
    seeds << value[:ip_address]
  end
else
  # Parse the seedlist into an array, if provided
  seeds = node[:cassandra][:seed].gsub(/ /,'').split(",")
end


Chef::Log.info "[SEEDS] Chosen seed(s): " << seeds.inspect

node[:cassandra][:seed] = seeds.join(",")

