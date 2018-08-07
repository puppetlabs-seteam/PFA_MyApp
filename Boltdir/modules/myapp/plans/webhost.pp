plan myapp::webhost(
) {
  # Prep this node for applying Puppet code (doesn't work yet)
  apply_prep('localhost')
  #run_task('puppet_agent::install', 'localhost')

  # Retrieve facts
  #run_plan('facts', nodes => 'localhost')

  # Apply SampleApp prereqs
  $report = apply('localhost') {

    class { 'nginx':
      names_hash_bucket_size => 128
    }

    nginx::resource::server { 'myapp':
      server_name         => [ $facts['ec2_metadata']['public-hostname'] ],
      listen_port         => 80,
      www_root            => '/var/www/myapp/web',
      index_files         => ['index.php'],
      location_cfg_append => {
        try_files => '$uri $uri/ =404'
      },
    }

    nginx::resource::location { 'myapp-php':
      ensure              => present,
      server              => $facts['ec2_metadata']['public-hostname'],
      www_root            => '/var/www/myapp/web',
      location            => '~ \.php$',
      index_files         => ['index.php'],
      fastcgi             => 'unix:/var/run/php-fpm.sock',
      fastcgi_script      => '$document_root$fastcgi_script_name;',
      fastcgi_split_path  => '^(.+\.php)(/.+)$'
    }

  }

  # return $report

}
