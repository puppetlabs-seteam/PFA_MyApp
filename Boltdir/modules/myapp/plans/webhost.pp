plan myapp::webhost(
) {
  # Prep this node for applying Puppet code
  apply_prep('localhost')

  # Apply MyApp nginx config
  $report = apply('localhost') {

    class { 'nginx':
      names_hash_bucket_size => 128
    }

    file { '/var/www/myapp':
      ensure  => directory,
      owner   => 'nginx',
      group   => 'nginx',
      mode    => '0755',
      seltype => 'httpd_sys_rw_content_t',
      recurse => true
    }

    nginx::resource::server { 'myapp':
      server_name         => [ $facts['ec2_metadata']['public-hostname'] ],
      listen_port         => 80,
      www_root            => '/var/www/myapp',
      index_files         => ['index.php'],
      location_cfg_append => {
        try_files => '$uri $uri/ =404'
      },
    }

    nginx::resource::location { 'myapp_root':
      ensure             => present,
      server             => 'myapp' ,
      www_root           => '/var/www/myapp',
      location           => '~ \.php$',
      fastcgi            => '127.0.0.1:9000',
      fastcgi_index      => 'index.php',
      fastcgi_split_path => '^(.+\.php)(/.+)$',
    }

  }

  # return $report

}
