# profile::puppet::server
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
class profile::puppet::server (
    Boolean $use_puppetdb         = true,
    String  $puppetdb_server      = 'puppet',
    Boolean $manage_puppet_config = false,
) {
    class { '::puppet':
        use_puppetdb => $use_puppetdb,
    }
    class { '::puppet::install::server': }
    class { '::puppet::install::r10k': }
    class { '::puppet::setup::server': }
    class { '::puppet::service': }
    if $use_puppetdb {
        class { '::puppetdb': }
        # Notes:
        # 1) as 'puppet' hostname by default is set - use it as PuppetDB server
        # name (predefined in profile parameters)
        # 2) By default class Puppet generates Puppet config from template
        # therefore we do not manage it inside class Puppetdb::Master::Config
        # (see 'manage_puppet_config' parameter description)
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
}
