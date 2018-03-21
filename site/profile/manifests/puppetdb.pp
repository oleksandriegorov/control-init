class profile::puppetdb (
    Boolean $manage_puppet_config = false,
) {
    class { '::puppetdb': }
    class { '::puppetdb::master::config':
        manage_storeconfigs     => $manage_puppet_config,
        manage_report_processor => $manage_puppet_config,
    }

