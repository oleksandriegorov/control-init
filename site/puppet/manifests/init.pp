class puppet (
    String  $server,
    Optional[Array[String]]
            $server_aliases,
    Optional[String]
            $server_ipaddress,
    Boolean $hosts_update,
)
{
    if $server_ipaddress and $hosts_update {
        host { $server:
            ensure       => 'present',
            ip           => $server_ipaddress,
            host_aliases => $server_aliases,
        }
    }
}
