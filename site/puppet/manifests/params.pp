class puppet5::params {
    $platform_name       = 'puppet5'
    $os_abbreviation     = 'el'
    $os_version          = $operatingsystemmajrelease
    $package_name        = "${platform_name}-release"
    $package_filename    = "${package_name}-${os_abbreviation}-${os_version}.noarch.rpm"
    $platform_repository = "https://yum.puppet.com/puppet5/${package_filename}"
    $agent_package_name  = 'puppet-agent'
    $server_package_name = 'puppetserver'
    $r10k_package_name   = 'r10k'
    $gem_path            = '/opt/puppetlabs/puppet/bin/gem'
    $r10k_path           = '/opt/puppetlabs/puppet/bin/r10k'
    $service_name        = 'puppetserver'
}

