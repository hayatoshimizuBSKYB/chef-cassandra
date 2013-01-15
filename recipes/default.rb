# Cookbook Name:: cassandra
include_recipe "cassandra::cloud"
include_recipe "cassandra::create_seed_list"
include_recipe "cassandra::token_generation"


bash "Set ulimits" do
  code <<-EOH
    if [ `grep "nofile 32768" /etc/security/limits.conf | wc -l` -gt 0 ]
    then
      echo "* soft nofile 32768" | sudo tee -a /etc/security/limits.conf
      echo "* hard nofile 32768" | sudo tee -a /etc/security/limits.conf
      echo "* soft memlock unlimited" | sudo tee -a /etc/security/limits.conf
      echo "* hard memlock unlimited" | sudo tee -a /etc/security/limits.conf
      sync
      echo 3 > /proc/sys/vm/drop_caches
    fi
  EOH
end

bash "Add hosts entry" do
  code <<-EOH
    if [ `grep #{node[:cassandra][:ip_address]} /etc/hosts | wc -l` = 0 ]
    then
      chattr -i /etc/hosts
      echo #{node[:cassandra][:ip_address]} `hostname` >> /etc/hosts
    fi
  EOH
end

# Create Cassandra User
user "#{node[:cassandra][:user]}" do
  comment "Cassandra User"
  home "/home/#{node[:cassandra][:user]}"
  shell "/bin/bash"
end

# Download Cassandra from Apache

remote_file "#{node[:cassandra][:download_path]}/apache-cassandra-#{node[:cassandra][:version]}-bin.tar.gz" do
  source "#{node[:cassandra][:download_url_base]}/#{node[:cassandra][:version]}/apache-cassandra-#{node[:cassandra][:version]}-bin.tar.gz"
  mode "0644"
  checksum node[:cassandra][:checksum]
end

directory "#{node[:cassandra][:data_file_directories]}" do
  owner "#{node[:cassandra][:user]}"
  group "#{node[:cassandra][:group]}"
  mode "0755"
  action :create
  recursive true
end

directory "#{node[:cassandra][:commitlog_directory]}" do
  owner "#{node[:cassandra][:user]}"
  group "#{node[:cassandra][:group]}"
  mode "0755"
  action :create
  recursive true
end

directory "#{node[:cassandra][:saved_caches_directory]}" do
  owner "#{node[:cassandra][:user]}"
  group "#{node[:cassandra][:group]}"
  mode "0755"
  action :create
  recursive true
end

directory "#{node[:cassandra][:log_path]}" do
  owner "#{node[:cassandra][:user]}"
  group "#{node[:cassandra][:group]}"
  mode "0755"
  action :create
  recursive true
end


directory "/home/#{node[:cassandra][:user]}" do
  owner "#{node[:cassandra][:user]}"
  group "#{node[:cassandra][:group]}"
  mode "0755"
  action :create
end

# Install Cassandra
bash "Unpack Cassandra" do
  code <<-EOH
    if [ ! -d #{node[:cassandra][:install_path]}/apache-cassandra-#{node[:cassandra][:version]} ]
    then
      cd #{node[:cassandra][:install_path]}
      tar xzf #{node[:cassandra][:download_path]}/apache-cassandra-#{node[:cassandra][:version]}-bin.tar.gz
      ln -s #{node[:cassandra][:install_path]}/apache-cassandra-#{node[:cassandra][:version]} cassandra
    fi
  EOH
end

# Download jna.jar
remote_file "#{node[:cassandra][:install_path]}/cassandra/lib/jna.jar" do
  source "http://repo1.maven.org/maven2/net/java/dev/jna/jna/#{node[:cassandra][:jna_version]}/jna-#{node[:cassandra][:jna_version]}.jar"
  mode "0644"
  not_if { File.exists?("#{node[:cassandra][:install_path]}/cassandra/lib/jna.jar") }
end

# Install startup script from template
template "/etc/init.d/cassandra" do
  source "cassandra.erb"
  owner "root"
  group "root"
  mode "0755"
end
      
# Deifne cassandra as a service.
service "cassandra" do
  supports :status => true, :start => true, :stop => true, :restart => true, :reload => true
end

# Configure cassandra.yaml
#   Copy cassandra.yaml template
template "#{node[:cassandra][:install_path]}/cassandra/conf/cassandra.yaml" do
  source "cassandra.yaml.erb"
  owner node[:cassandra][:user]
  group node[:cassandra][:group]
  mode "0644"
#  notifies :restart , resources(:service => "cassandra")
end

      
# Copy cassandra-env.sh template
template "#{node[:cassandra][:install_path]}/cassandra/conf/cassandra-env.sh" do
  source "cassandra-env.sh.erb"
  owner node[:cassandra][:user]
  group node[:cassandra][:group]
  mode "0755"
#  notifies :restart , resources(:service => "cassandra")
end

# Copy log4j-server.properties template
template "#{node[:cassandra][:install_path]}/cassandra/conf/log4j-server.properties" do
  source "log4j-server.properties.erb"
  owner node[:cassandra][:user]
  group node[:cassandra][:group]
  mode "0644"
#  notifies :restart , resources(:service => "cassandra")
end

template "#{node[:cassandra][:install_path]}/cassandra/bin/snapshot.sh" do
   owner "cassandra"
   group "cassandra"
   mode "0755"
   source "snapshot.sh.erb"
   notifies :restart , resources(:service => "cassandra")
end

ruby_block "Restore from snapshots" do
  block do
    require 'date'

    # Is data volume empty?
    if Dir.entries(node[:cassandra][:data_file_directories]).size == 2
      # Check if snapshots exists
      cassandra_backup_dir = "#{node[:cassandra][:backup_dir]}/cassandra"
      if Dir.exists?(cassandra_backup_dir)
        # Find the directory for latest backup date
        latest_date_str = ""
        latest_date_obj = Date.parse("1970-01-01")
        Dir.foreach(cassandra_backup_dir) do |date|
          next if (date.eql?(".")) || (date.eql?(".."))
          d = Date.parse(date)
          if d > latest_date_obj
            latest_date_str = date
            latest_date_obj = d
          end
        end
        
        # If backup directory is found
        if latest_date_str.length > 0
          Dir.foreach("#{cassandra_backup_dir}/#{latest_date_str}") do |keyspace|
            next if (keyspace.eql?(".")) || (keyspace.eql?(".."))
            
            Dir.foreach("#{cassandra_backup_dir}/#{latest_date_str}/#{keyspace}") do |ks_component|
              # Remove Cassandra keyspace component directory
              FileUtils.rm_rf "#{node[:cassandra][:data_file_directories]}/#{keyspace}/#{ks_component}"
              
              # Copy the snapshot directory
              FileUtils.mkdir_p "#{node[:cassandra][:data_file_directories]}/#{keyspace}"
              FileUtils.cp_r "#{cassandra_backup_dir}/#{latest_date_str}/#{keyspace}/#{ks_component}", "#{node[:cassandra][:data_file_directories]}/#{keyspace}/#{ks_component}"
              puts "Recovered #{keyspace}:#{ks_component} from backup."
            end
            
          end
          
          FileUtils.chown_R "cassandra", "cassandra", node[:cassandra][:data_file_directories]
        end
        
      end
    end
    
  end
  action :create
end


# Start Cassandra
service "cassandra" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
