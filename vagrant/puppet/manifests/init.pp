# Set environment variables
Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/' ] }

# create group www-data
group { 'www-data':
    ensure => 'present',
}

# create apache run users
user { ['apache', 'httpd', 'www-data']:
  shell  => '/bin/bash',
  ensure => present,
  groups => 'www-data',
  require => Group['www-data']
}

# i think this tells it to first add the repos, and then load the packages
Yumrepo <| |> -> Package <| |>

# Those repositories provide php 5.4,5.5 and 5.6, CentOs 6.5 only provides 5.3.3
# it also provides a lot of php-modules
# More information about available packages at: http://rpms.famillecollet.com/
yumrepo   { "remi-repo":
        baseurl => "http://rpms.famillecollet.com/enterprise/6/remi/\$basearch/",
        descr => "remi repo",
        enabled => 1,
        gpgcheck => 0,
}

yumrepo   { "remi-php55":
        baseurl => "http://rpms.famillecollet.com/enterprise/6/php55/\$basearch/",
        descr => "remi php55 repo",
        enabled => 1,
        gpgcheck => 0,
}

# enable EPEL packages: https://fedoraproject.org/wiki/EPEL
# needed to provide lcms2 for php-pecl-imagick
package {"epel-release":
  ensure => present
}

# install ImageMagick, there seems to be no GraphicsMagick RPM Repository
# Might have to write a GM puppet module
package {"ImageMagick":
  ensure => present
}

# install apache
class { 'apache':}

# install apache modules, those are chained to avoid too many apache restarts during provisioning
apache::module { 'rewrite':
  notify_service => false
}
->
apache::module { 'headers':
  notify_service => false
}
->
apache::module { 'expires': }

# install php
class { 'php':
    service_autorestart => true,
    service => 'httpd',
    version => 'latest',
}


 # set php.ini variables, the chaining here also prevents too many apache restarts
php::augeas {
  'php-memorylimit':
    entry  => 'PHP/memory_limit',
    value  => '128M',
    require => Class['php'];
  'php-date_timezone':
    entry  => 'Date/date.timezone',
    value  => 'Europe/Amsterdam',
    require => Class['php'];
  'max_execution_time':
    entry  => 'PHP/max_execution_time',
    value  => '240',
    require => Class['php'];
  'upload_max_filesize':
    entry  => 'PHP/upload_max_filesize',
    value  => '10M',
    require => Class['php'];
  'post_max_size':
    entry  => 'PHP/post_max_size',
    value  => '10M',
    require => Class['php'];
}
->
php::augeas {
  'xdebug-max_nesting_level':
    entry  => 'PHP/xdebug.max_nesting_level',
    value  => '400', # srsyl... that's the proposed value these days....
    require => Class['php'],
    notify => Service['httpd']
}

# install php-modules, yay chaining helps once again
php::module { "gd":
  service_autorestart => false
}
->
php::module { "mbstring":
  service_autorestart => false
}
->
php::module { "soap":
  service_autorestart => false
}
->
php::module { "pear":
  service_autorestart => false
}
->
php::module { "mysqlnd":
  service_autorestart => false
}
->
php::module { "pecl-xdebug":
  service_autorestart => false
}
->
php::module { "pecl-imagick": }

# install mysql
class { 'mysql':
  root_password => 'toor',
}

mysql::grant { 'typo3':
  mysql_user => 'typo3',
  mysql_password => 'typo3',
  require => Class['mysql']
}

# create TYPO3 directory structure
file { "/var/www/typo3.local/":
  ensure => "directory",
  owner  => "vagrant",
  group  => "www-data",
  mode => 2770,
  require => Class['apache']
}

file { "/var/www/sources/":
  ensure => "directory",
  owner  => "vagrant",
  group  => "www-data",
  require => Class['apache']
}

# install TYPO3
typo3::project { 'typo3.local':
  version => '6.2.9',
  site_path => '/var/www/typo3.local/',
  typo3_src_path => '/var/www/sources/',
  enable_install_tool => true,
  site_user => 'vagrant',
  site_group => 'www-data',
  require => Class['mysql']
}

# create vhost for TYPO3
apache::vhost { "typo3.local" :
    docroot => "/var/www/typo3.local",
    directory => "/var/www/typo3.local",
    directory_allow_override   => 'All',
}
