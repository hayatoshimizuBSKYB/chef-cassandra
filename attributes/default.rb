# Needed for the Chef script to function properly
default[:setup][:deployment] = "11x"    # Choices are "07x", or "08x"
default[:setup][:cluster_size] = 8
default[:setup][:current_role] = "cassandra"


default[:cassandra][:version] = "1.2.0"
default[:cassandra][:checksum] = "47bd459fd103a539ef148089f4c8050eeaa950b0b19a798f69905a942fc59510"
default[:cassandra][:jna_version] = "3.5.1"

default[:cassandra][:user] = "cassandra"

default[:cassandra][:logs_directory] = "/var/lib/cassandra/logs"

# Advanced Cassandra settings
default[:cassandra][:token_position] = false
default[:cassandra][:initial_token] = false
default[:cassandra][:rpc_address] = false
default[:cassandra][:confPath] = "/etc/cassandra/"
default[:cassandra][:download_path] = "/var/tmp"

default[:internal][:prime] = true

default[:cassandra][:cluster_name] = "Test Cluster" 
default[:cassandra][:num_tokens] = 256
default[:cassandra][:auto_bootstrap] = true 
default[:cassandra][:hinted_handoff_enabled] = true 
default[:cassandra][:max_hint_window_in_ms] = 3600000
default[:cassandra][:hinted_handoff_throttle_in_kb] = 1024
default[:cassandra][:max_hints_delivery_threads] = 2
default[:cassandra][:hinted_handoff_throttle_delay_in_ms] = 50
default[:cassandra][:populate_io_cache_on_flush] = "false"
default[:cassandra][:authenticator] = "org.apache.cassandra.auth.AllowAllAuthenticator"
default[:cassandra][:authority] = "org.apache.cassandra.auth.AllowAllAuthority"
default[:cassandra][:partitioner] = "org.apache.cassandra.dht.Murmur3Partitioner"
default[:cassandra][:data_file_directories] =  "/var/lib/cassandra/data"
default[:cassandra][:commitlog_directory] = "/var/lib/cassandra/commitlog"
default[:cassandra][:saved_caches_directory] = "/var/lib/cassandra/saved_caches"
default[:cassandra][:disk_failure_policy] = "stop"
default[:cassandra][:key_cache_size_in_mb] = 1024
default[:cassandra][:key_cache_save_period] = 14400
default[:cassandra][:key_cache_keys_to_save] = 100
default[:cassandra][:row_cache_size_in_mb] = 128
default[:cassandra][:row_cache_save_period] = 0
default[:cassandra][:row_cache_keys_to_save] = 100
default[:cassandra][:row_cache_provider] = "SerializingCacheProvider"
default[:cassandra][:commitlog_rotation_threshold_in_mb] = 128
default[:cassandra][:commitlog_sync] = "periodic"
default[:cassandra][:commitlog_sync_period_in_ms] = 10000
default[:cassandra][:commitlog_segment_size_in_mb] = 32
default[:cassandra][:trickle_fsync] = "false"
default[:cassandra][:trickle_fsync_interval_in_kb] = 10240
default[:cassandra][:listen_address] = node[:cassandra][:ip_address]
default[:cassandra][:rpc_address] = "0.0.0.0"
default[:cassandra][:flush_largest_memtables_at] = 0.75
default[:cassandra][:reduce_cache_sizes_at] = 0.85
default[:cassandra][:reduce_cache_capacity_to] = 0.6
default[:cassandra][:seed_provider_class_name] = "org.apache.cassandra.locator.SimpleSeedProvider"
default[:cassandra][:disk_access_mode] = "auto"
default[:cassandra][:concurrent_reads] = 80 
default[:cassandra][:concurrent_writes] = 64
default[:cassandra][:memtable_flush_queue_size] = 4
default[:cassandra][:memtable_flush_writers] = 1
default[:cassandra][:sliced_buffer_size_in_kb] = 64
default[:cassandra][:storage_port] = 7000
default[:cassandra][:ssl_storage_port] = 7001
default[:cassandra][:rpc_port] = 9160
default[:cassandra][:rpc_keepalive] = "true"
default[:cassandra][:rpc_server_type] = "sync"
default[:cassandra][:start_rpc] = "true"
default[:cassandra][:thrift_framed_transport_size_in_mb] = 15
default[:cassandra][:thrift_max_message_length_in_mb] = 16
default[:cassandra][:incremental_backups] = "false"
default[:cassandra][:snapshot_before_compaction] = "false"
default[:cassandra][:read_request_timeout_in_ms] = 10000
default[:cassandra][:range_request_timeout_in_ms] = 10000
default[:cassandra][:write_request_timeout_in_ms] = 10000
default[:cassandra][:truncate_request_timeout_in_ms] = 60000
default[:cassandra][:request_timeout_in_ms] = 10000
default[:cassandra][:cross_node_timeout] = "false"
default[:cassandra][:auto_snapshot] = "true"
default[:cassandra][:column_index_size_in_kb] = 64
default[:cassandra][:in_memory_compaction_limit_in_mb] = 64
default[:cassandra][:concurrent_compactors] = 1
default[:cassandra][:compaction_throughput_mb_per_sec] = 16
default[:cassandra][:compaction_preheat_key_cache] = "true"
default[:cassandra][:concurrent_compactors] = 1
default[:cassandra][:stream_throughput_outbound_megabits_per_sec] = 400
default[:cassandra][:rpc_timeout_in_ms] = 10000
default[:cassandra][:phi_convict_threshold] = 8
default[:cassandra][:endpoint_snitch] = "org.apache.cassandra.locator.PropertyFileSnitch"
default[:cassandra][:dynamic_snitch_badness_threshold] = 0.0
default[:cassandra][:request_scheduler] = "org.apache.cassandra.scheduler.NoScheduler"
default[:cassandra][:index_interval] = 128
default[:cassandra][:memtable_total_space_in_mb] = 2048
default[:cassandra][:multithreaded_compaction] = "false"
default[:cassandra][:commitlog_total_space_in_mb] = 4096
default[:cassandra][:MAX_HEAP_SIZE] = "4G"
default[:cassandra][:HEAP_NEWSIZE] = "800M"
default[:cassandra][:dynamic_snitch_update_interval_in_ms] = 100
default[:cassandra][:dynamic_snitch_reset_interval_in_ms] = 600000
default[:cassandra][:dynamic_snitch_badness_threshold] = 0.1
default[:cassandra][:internode_compression] = "all"

default[:cassandra][:server_encryption_options_internode_encryption] = "none"
default[:cassandra][:server_encryption_options_keystore] = "conf/.keystore"
default[:cassandra][:server_encryption_options_keystore_password] = "cassandra"
default[:cassandra][:server_encryption_options_truststore] = "conf/.truststore"
default[:cassandra][:server_encryption_options_truststore_password] = "cassandra"
default[:cassandra][:client_encryption_options_enabled] = "false"
default[:cassandra][:client_encryption_options_keystore] = "conf/.keystore"
default[:cassandra][:client_encryption_options_keystore_password] = "cassandra"

default[:cassandra][:splay] = 600
default[:cassandra][:snapshots_retention_days] = 7
