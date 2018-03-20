class profile::puppet::server {
    class { '::puppet':
        master => true,
    }
    class { '::puppet::install::server': }
    class { '::puppet::install::r10k': }
    class { '::puppet::setup::server': }
    class { '::puppet::service': }
}
