# Class: php5-fpm
#
# This class manage php5-fpm installation and configuration. 
# Config file 'php5-fpm.conf' is very minimal : only include /etc/php5/fpm/fpm.d/*.conf
# Use php5-fpm::config for configuring php5-fpm 
#
# Templates:
#	- php5-fpm.conf.erb
#
class php5-fpm {

    $package_name = $operatingsystem ? {
        /(Fedora|CentOS)/  => 'php-fpm',
        /(Debian|Ubuntu)/  => 'php5-fpm',
        default         => 'php5-fpm'
    }

    $service_name = $operatingsystem ? {
        /(Fedora|CentOS|RedHat)/  => 'php-fpm',
        /(Debian|Ubuntu)/  => 'php5-fpm',
        default         => 'php5-fpm'
    }

    $config_file = $operatingsystem ? {
        /(Fedora|CentOS|RedHat)/  => '/etc/php-fpm.conf',
        /(Debian|Ubuntu)/  => "/etc/php5/fpm/main.conf",
        default         => "/etc/php5/fpm/main.conf"
    }

    $config_dir = $operatingsystem ? {
        /(Fedora|CentOS|RedHat)/  => '/etc/php-fpm.d',
        /(Debian|Ubuntu)/  => "/etc/php5/fpm/fpm.d",
        default         => "/etc/php5/fpm/fpm.d"
    }


	package { $package_name: ensure => installed	}

	service { $service_name:
		ensure => running,
		enable => true,
		require => File["${config_file}"],
	}

	file{"${config_file}":
		ensure => present,
		owner	=> root,
		group	=> root,
		mode	=> 644,
		content => template("php5-fpm/main.conf.erb"),
		require => Package[$package_name],
	}

	file{"/etc/php5/fpm/php-fpm.conf":
		ensure => present,
		owner	=> root,
		group	=> root,
		mode	=> 644,
		content => template("php5-fpm/main.conf.erb"),
		require => Package["${package_name}"],
	}
	
	file{"/etc/php5/fpm/pool.d/www.conf":
		ensure => absent,
		force	=> true,
	}

	file{"/etc/php5/fpm/pool.d/":
		ensure => absent,
		force	=> true,
	}

	file{"${config_dir}":
		ensure => directory,
		checksum => mtime,
		owner	=> root,
		group	=> root,
		mode	=> 644,
		require => Package["${package_name}"],
	}

	# Define : php5-fpm::config
	#
	# Define a php-fpm config snippet. Places all config snippets into
	# /etc/php5/fpm/fpm.d, where they will be automatically loaded
	#
	# Parameters :
	#	* ensure: typically set to "present" or "absent".  Defaults to "present"
	#	* content: set the content of the config snipppet.  Defaults to	'template("php5-fpm/fpm.d/$name.conf.erb")'
	#	* order: specifies the load order for this config snippet.  Defaults to "500"
	#
	# Sample Usage:
	# 	php5-fpm::config{"global":
	#		ensure	=> present,
	#		order	=> "000",
	#	}
	#	php5-fpm::config{"www":
	#		ensure	=> present,
	#		content	=> template("php5-fpm/fpm.d/www.conf.erb"),
	#	}
	#	
    define config ( 
		$ensure = 'present', 
		$content = '',
		$order="500", 
		$listen = '/var/run/php5-fpm.sock', 
		$user = 'www-data', 
		$group = 'www-data', 
		$pm = 'dynamic',
		$pm_max_children = 10,
		$pm_min_spare_servers = 5,
		$pm_max_spare_servers = 10,
		$pm_max_requests = 0
		) {
		$real_content = $content ? { 
			'' => template("php5-fpm/fpm.d/${name}.conf.erb"),
	    		default => $content,
	  	}

        $config_dir = $operatingsystem ? {
            /(Fedora|CentOS|RedHat)/  => '/etc/php-fpm.d',
            /(Debian|Ubuntu)/  => "/etc/php5/fpm/fpm.d",
            default         => "/etc/php5/fpm/fpm.d"
        }

		file { "${config_dir}/${order}-${name}.conf":
			ensure => $ensure,
			content => $real_content,
			mode => 644,
			owner => root,
			group => root
		}
   }
		
		
}


