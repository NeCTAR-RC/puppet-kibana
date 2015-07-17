class kibana::install {

  if $::rfc1918_gateway == 'true' {
    $environment = [ "HTTP_PROXY=$::http_proxy", "http_proxy=$::http_proxy", "https_proxy=$::http_proxy" ]
  }  else {
    $environment = []
  }

  wget::fetch { 'download_kibana':
    source      => "http://github.com/rashidkpc/Kibana/tarball/${kibana::git_hash}",
    destination => "/usr/local/src/kibana-ruby-${kibana::git_hash}.tar.gz",
    notify      => Exec['untar_kibana'],
  }

  exec { 'untar_kibana':
    command     => "/bin/tar xvf /usr/local/src/kibana-ruby-${kibana::git_hash}.tar.gz",
    cwd         => '/opt',
    creates     => "/opt/rashidkpc-Kibana-${kibana::git_hash}",
    before      => File['/opt/kibana'],
    refreshonly => true,
  }

  file { '/opt/kibana':
    ensure => link,
    target => "/opt/rashidkpc-Kibana-${kibana::git_hash}",
    notify => Exec['bundle_kibana'],
  }

  exec { 'bundle_kibana':
    command     => '/usr/bin/bundle install --path vendor',
    cwd         => '/opt/kibana',
    creates     => '/opt/kibana/vendor',
    timeout     => 1200,
    environment => $environment,
    unless      => '/usr/bin/test -d /opt/kibana/vendor',
    require     => File['/opt/kibana'],
  }

  $kibana_deps = ['ruby-bundler', 'rails', 'ruby1.8-dev', 'make', 'g++']

  package { $kibana_deps :
    ensure => installed,
  }
}
