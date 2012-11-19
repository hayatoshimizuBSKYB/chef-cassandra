# Cookbook Name:: cassandra

include_recipe "cassandra::create_seed_list"
include_recipe "cassandra::token_generation"


execute 'bash -c "ulimit -n 32768"'
execute 'echo "* soft nofile 32768" | sudo tee -a /etc/security/limits.conf'
execute 'echo "* hard nofile 32768" | sudo tee -a /etc/security/limits.conf'
execute 'sync'
execute 'echo 3 > /proc/sys/vm/drop_caches'


# Download Cassandra from Apache

remote_file "/tmp/apache-cassandra-#{ node[:cassandra][:version] }-bin.tar.gz" do
  source "http://www.mirrorservice.org/sites/ftp.apache.org/cassandra/#{ node[:cassandra][:version] }/apache-cassandra-#{ node[:cassandra][:version] }-bin.tar.gz"
  mode "0644"
  checksum node[:cassandra][:checksum]
end

# Create Cassandra User
user "#{ node[:cassandra][:user] }" do
  comment "Cassandra User"
  home "/home/#{ node[:cassandra][:user] }"
  shell "/bin/bash"
end

# Install Cassandra
bash "Unpack Cassandra" do
  code <<-EOH
    if [ ! -d #{ node[:cassandra][:install_path] }/apache-cassandra-#{ node[:cassandra][:version] } ]
    then
      cd #{ node[:cassandra][:install_path] }
      tar xzf /tmp/apache-cassandra-#{ node[:cassandra][:version] }-bin.tar.gz
      ln -s #{ node[:cassandra][:install_path] }/apache-cassandra-#{ node[:cassandra][:version] } cassandra
    fi
  EOH
end

# Download jna.jar
remote_file "#{ node[:cassandra][:install_path] }/cassandra/lib" do
  source "http://repo1.maven.org/maven2/net/java/dev/jna/jna/#{ node[:cassandra][:jna_version] }/jna-#{ node[:cassandra][:jna_version] }.jar"
  mode "0644"
end


# Configure cassandra.yaml
#   Copy cassandra.yaml template
template "#{node[:cassandra][:install_path]}/cassandra/conf/cassandra.yaml" do
  source "cassandra.yaml.erb"
  owner node[:cassandra][:user]
  group node[:cassandra][:group]
  mode "0644"
  notifies :restart , resources(:service => "cassandra")
end

# Generate cassandra-topology.properties
template "#{node[:cassandra][:install_path]}/cassandra/conf/cassandra-topology.properties" do
  owner node[:cassandra][:user]
  group node[:cassandra][:group]
  mode "0644"
  source "cassandra-topology.properties.erb"
  # Pass the topology array as 't' to the template.
  variables(
    :t => t
  )
   notifies :restart , resources(:service => "cassandra")
end
      
#   Copy cassandra-env.sh template
template "#{node[:cassandra][:install_path]}/cassandra/conf/cassandra-env.sh" do
  source "cassandra.yaml.erb"
  owner node[:cassandra][:user]
  group node[:cassandra][:group]
  mode "0755"
  notifies :restart , resources(:service => "cassandra")
end

# Install startup script from template
template "/etc/init.d/cassandra" do
  source "cassandra.erb"
  owner "root"
  group "root"
  mode "0755"
  notifies :restart , resources(:service => "cassandra")
end


# Deifne cassandra as a service.
service "cassandra" do
  supports :status => true, :start => true, :stop => true, :restart => true, :reload => true
end



# Start Cassandra

