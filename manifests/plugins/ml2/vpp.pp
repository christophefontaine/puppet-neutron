#
# Install the networking-vpp ML2 mechanism driver and generate config file
# from parameters in the other classes.
#
# === Parameters
#
# [*etcd_host*]
# (optional) etcd server host name or IP.
# Defaults to $::os_service_default
#
# [*etcd_port*]
# (optional) etcd server listening port.
# Defaults to $::os_service_default.
#
# [*etcd_user*]
# (optional) User name for etcd authentication
# Defaults to $::os_service_default.
#
# [*etcd_pass*]
# (optional) Password for etcd authentication
# Defaults to $::os_service_default.
#
# [*vhost_user_dir*]
#   (optional) Folder for vhost user sockets
#   For containerized deployments, the folder *must* be mounted
#   in the vpp-agent container
#   Defaults to '/var/lib/vhost_sockets'
#
# [*driver_ext*]
#   (optional) Comma-separated list of extensions to load for vpp driver
#   Defaults to $::os_service_default.
#
class neutron::plugins::ml2::vpp (
  $etcd_host = $::os_service_default,
  $etcd_port = $::os_service_default,
  $etcd_user = $::os_service_default,
  $etcd_pass = $::os_service_default,
  $vhost_user_dir = '/var/lib/vhost_sockets',
  $driver_ext     = $::os_service_default,
) {
  include ::neutron::deps
  require ::neutron::plugins::ml2

  neutron_plugin_ml2 {
    'ml2_vpp/etcd_host': value => $etcd_host;
    'ml2_vpp/etcd_port': value => $etcd_port;
    'ml2_vpp/etcd_user': value => $etcd_user;
    'ml2_vpp/etcd_pass': value => $etcd_pass, secret => true;
    'ml2_vpp/vhost_user_dir': value => $vhost_user_dir;
    'ml2_vpp/driver_extensions': value => $driver_ext;
  }
}
