#!/bin/bash
# Demyx
# https://github.com/demyxco/demyx

CONTAINER_PATH=$1
FORCE=$2

if [ -f "$CONTAINER_PATH"/conf/my.cnf ]; then
	NO_UPDATE=$(grep -r "AUTO GENERATED" "$CONTAINER_PATH"/conf/my.cnf)
	[[ -z "$NO_UPDATE" ]] && [[ -z "$FORCE" ]] && echo -e "\e[33m[WARNING] Skipped my.cnf\e[39m" && exit 1
fi

cat > "$CONTAINER_PATH"/conf/my.cnf <<-EOF
[client]
port = 3306
socket = /run/mysqld/mysqld.sock

default-character-set = utf8

[mysqld]
port = 3306
socket = /run/mysqld/mysqld.sock

character-set-server = utf8
collation-server = utf8_general_ci

skip-external-locking
key_buffer_size = 16M
net_buffer_length = 8K

max_connections		= 100
connect_timeout		= 5
wait_timeout		= 60
max_allowed_packet	= 16M
thread_cache_size   = 128
sort_buffer_size	= 4M
bulk_insert_buffer_size	= 16M
tmp_table_size		= 32M
max_heap_table_size	= 32M

myisam_recover_options = BACKUP
key_buffer_size		 = 64M
open-files-limit	 = 500000
table_open_cache	 = 500000
myisam_sort_buffer_size	= 256M
concurrent_insert	 = 2
read_buffer_size	 = 2M
read_rnd_buffer_size = 1M

query_cache_limit		= 128K
query_cache_size		= 0
query_cache_type		= 0

slow_query_log = 1
slow_query_log_file	= /var/lib/mysql/mariadb-slow.log
long_query_time = 10
log_slow_verbosity	= query_plan

tmpdir = /tmp


log-bin = mysql-bin
binlog_format = mixed


server-id = 1

# innodb_log_file_size = innodb_buffer_pool_size / 8
innodb_log_file_size	= 128M
# innodb_buffer_pool_size = RAM / 2
innodb_buffer_pool_size	= 1G
# innodb_log_buffer_size = innodb_buffer_pool_size / 4
innodb_log_buffer_size	= 256M

innodb_file_per_table	= 1
innodb_open_files	= 500000
innodb_io_capacity	= 500000
innodb_flush_method	= O_DIRECT

innodb_data_home_dir = /var/lib/mysql
innodb_data_file_path = ibdata1:10M:autoextend
innodb_log_group_home_dir = /var/lib/mysql
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 50
innodb_use_native_aio = 1
innodb_file_per_table = ON

[mysqldump]
quick
quote-names
max_allowed_packet = 16M

[mysql]
no-auto-rehash

[myisamchk]
key_buffer_size = 16M
sort_buffer_size = 512K
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout

!includedir /etc/mysql/conf.d/
EOF
echo -e "\e[32m[SUCCESS] Generated my.cnf\e[39m"