# pglogical needed settings
wal_level='logical'
max_worker_processes=10
max_replication_slots=10
max_wal_senders=10
shared_preload_libraries='pglogical'
track_commit_timestamp=on