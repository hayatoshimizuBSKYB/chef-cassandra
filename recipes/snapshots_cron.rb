# Recipe: cassandra::snapshots_cron
include_recipe "cron"
require "digest/md5"

checksum   = Digest::MD5.hexdigest "#{node['fqdn'] or 'unknown-hostname'}"
sleep_time = checksum.to_s.hex % node[:cassandra][:splay].to_i
log_file   = node[:cassandra][:snapshot_log_file]


cron_d "cassandra-snapshot" do
  action :delete
end

cron_d "cassandra-snapshot" do
  minute 0
  hour 3
  command "/bin/sleep #{sleep_time}; #{node[:cassandra][:install_path]}/cassandra/bin/snapshot.sh >> #{node[:cassandra][:logs_directory]}/snapshot.log"
  user "#{node[:cassandra][:user]}"
end

