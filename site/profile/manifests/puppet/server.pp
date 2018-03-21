class profile::puppet::server (
    Boolean $use_puppetdb = true,
) {
    class { '::puppet':
        master       => true,
        use_puppetdb => $use_puppetdb,
    }
    class { '::puppet::install::server': }
    class { '::puppet::install::r10k': }
    class { '::puppet::setup::server': }
    class { '::puppet::service': }
    if $use_puppetdb {
        include profile::puppetdb
    }
}
