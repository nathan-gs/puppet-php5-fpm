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

	package { php5-fpm: ensure => installed	}

	service { php5-fpm:
		ensure => running,
		enable => true,
		require => File["/etc/php5/fpm/main.conf"],
	}

	file{"/etc/php5/fpm/main.conf":
		ensure => present,
		owner	=> root,
		group	=> root,
		mode	=> 644,
		content => template("php5-fpm/main.conf.erb"),
		require => Package["php5-fpm"],
	}
	
	file{"/etc/php5/fpm/pool.d/":
		ensure => absent,
	}

	file{"/etc/php5/fpm/fpm.d":
		ensure => directory,
		checksum => mtime,
		owner	=> root,
		group	=> root,
		mode	=> 644,
		require => Package["php5-fpm"],
	}

	exec{"reload-php5-fpm":
		command => "/etc/init.d/php5-fpm reload",
                refreshonly => true,
		require => File["/etc/php5/fpm/main.conf"],
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

		file { "/etc/php5/fpm/fpm.d/${order}-${name}.conf":
			ensure => $ensure,
			content => $real_content,
			mode => 644,
			owner => root,
			group => root,
			notify => Exec["reload-php5-fpm"],
			before => Service["php5-fpm"],
		}
   }
		
		
}


