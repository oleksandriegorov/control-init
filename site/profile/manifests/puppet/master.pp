# profile::puppet::master
#
# Description
#     Puppet single host installation (Puppet Agent/Server/PuppetDB)
#
# Parameters:
#
# [*use_puppetdb*]
# Boolean. Default is true. If set puppet.conf will be set to use PuppetDB for
# storeconfigs and reports storage. Also PuppetDB will be managed through
# puppetlabs-puppetdb module (including PostgreSQL database)
#
# [*puppetdb_server*]
# String. Default is 'puppet'. Server name for PuppetDB. Puppetdb::Master::Config
# class (from puppetlabs-puppetdb) use ::fqdn for check connection to PuppetDB
# server. As ::fqdn could be ot resolvable it is possible to set up server name
# via parameter puppetdb_server. Class '::puppet' by default set into /etc/hosts
# file record
# 127.0.0.1 puppet
# therefore hostname 'puppet' is resolvable. If you changed this behavior - you
# should properly set parameter puppetdb_server as well
#
# [*manage_puppet_config*]
# Boolean. Default is false. If set then class Puppetdb::Master::Config will
# check puppet.conf (using Ini_setting resources) for proper setup of report/reports
# and storeconfigs/storeconfigs_backend directives. By default class Puppet
# generates Puppet config from template therefore we do not manage it inside
# class Puppetdb::Master::Config.
#
# [*manage_postgres_dbserver*]
# Boolean. Default is true. If set then class Puppetdb will use puppetlabs/postgresql
# for Postgres database server management and PuppetDB database setup
#
# [*manage_puppetdb_firewall*]
# Boolean. Default is false. If set than class Puppetdb::Server will use
# puppetlabs/firewall for firewall rules setup, iptables/ip6tables services
# management
#
class profile::puppet::master (
    Boolean $use_puppetdb             = true,
    String  $puppetdb_server          = 'puppet',
    Boolean $manage_puppet_config     = false,
    Boolean $manage_postgres_dbserver = true,
    Boolean $manage_puppetdb_firewall = false,
    String  $r10k_cachedir            = '/var/cache/r10k',
) {
    class { '::puppet':
        use_puppetdb => $use_puppetdb,
    }
    class { '::puppet::server::install': }
    class { '::puppet::server::setup':
        cachedir => $r10k_cachedir,
    }
    if $use_puppetdb {
        class { '::puppetdb':
            manage_dbserver => $manage_postgres_dbserver,
            manage_firewall => $manage_puppetdb_firewall,
        }
        # Notes:
        # 1) as 'puppet' hostname by default is set by class Puppet - use it as
        # PuppetDB server name (predefined in profile parameters as
        # puppetdb_server)
        # 2) By default class Puppet generates Puppet config (puppet.conf) from
        # template therefore we do not want to manage it inside class
        # Puppetdb::Master::Config (see 'manage_puppet_config' parameter
        # description)
        # 3) Puppet service resource name provided by Puppet::Service class has
        # alias 'puppet-server'
        #
        class { '::puppetdb::master::config':
            puppetdb_server                => $puppetdb_server,
            manage_storeconfigs            => $manage_puppet_config,
            manage_report_processor        => $manage_puppet_config,
            create_puppet_service_resource => false,
            puppet_service_name            => 'puppet-server',
        }
    }
    class { '::puppet::service': }
    # install ENC script
    class { '::puppet::enc': }
    # r10k is not optional in our workflow, it should replace initial setup with
    # real infrastructure setup.
    class { '::r10k':
        provider          => 'puppet_gem',
        manage_modulepath => $manage_puppet_config,
        cachedir          => $r10k_cachedir,
    }
}
