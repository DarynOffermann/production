include stdlib
include rhsm

node puppetagent3 {

	$packages=['rpm-build','gcc','python3','openssl-devel'
	,'munge','munge-devel','munge-libs','mysql'
	,'mysql-server','mysql-devel','javapackages-tools'
	,'readline-devel','openssl','openssl-libs','git']

	yumrepo { 'codeready-builder':
		enabled => 1,
		descr => 'repo for rpms',
		baseurl => 
"https://cdn.redhat.com/content/dist/rhel8/$releaserver/x86_64/codeready-builder/os",
			
	}
	
	rh_repo { 'codeready-builder-for-rhel-8-x86_64-source-rpms' :
		ensure => present,
	}	

	package { 'epel-release':
		ensure => present,
		provider => yum,
		source => "https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm",	
	}
##	wget::fetch {'https://github.com/Perl-Toolchain-Gang/ExtUtils-MakeMaker.git':
##		destination => '/tmp/',
##		timeout => 15,
##		verbose => true,
##	}

	package{$packages:
		ensure=>'installed',
	}

	file{'/tmp/status.txt':
		content=>'Slurm packages installed',
		mode =>'0644',
	}

	file{'/var/lib/munge':
		mode => '0711',
	}
	
	user { 'munge':
		name => munge,
		ensure => present,
		password => 'munge',
		comment => 'deamon',
		home => '/sbin',
		password_max_age => '99999',
		password_min_age => '0',
		shell => '/sbin/nologin',
	}

	user {'slurm':
		name => slurm,
		ensure => present,
		password => 'slurm',
		comment => 'deamon',
		home => '/sbin',
		password_max_age => '99999',
		password_min_age => '0',
		shell => '/sbin/nologin',
	}	

	Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', 'usr/sbin/' ] }

	exec { 'munge.key':
		command => 'dd if=/dev/urandom bs=1 count=1024 >/etc/munge/munge.key',
		user => 'munge',
		onlyif =>'systemctl status munge.service | grep inactive', 
	}

	file{'/etc/munge/munge.key':
		ensure => present,
		mode => '0400',
		owner => 'munge',
		path => '/etc/munge/munge.key',
	}

	service {'munge':
		name => 'munge.service',
		ensure => true,
		enable => true,
	}

	file {'/tmp/slurm.conf':
		ensure => 'present',
		content => file(
		'/etc/puppetlabs/code/environments/production/modules/slurm_conf/files/slurm.conf'),
	}
	
	file {'/etc/my.cnf':
		ensure => 'present',
		content => file(
		'/etc/puppetlabs/code/environments/production/modules/slurm_conf/files/my.cnf'),
	}

	service {'mysqld':
		name => 'mysqld.service',
		ensure => true,
		enable => true,
	}

	
}

