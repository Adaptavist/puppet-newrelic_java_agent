class newrelic_java_agent (
    $application_name,
    $license_key,
    $install_base          = $newrelic_java_agent::params::install_base,
    $chown_install_dir     = $newrelic_java_agent::params::chown_install_dir,
    $config_file           = $newrelic_java_agent::params::config_file,
    $owner                 = $newrelic_java_agent::params::owner,
    $group                 = $newrelic_java_agent::params::group,
    $apm_download_location = $newrelic_java_agent::params::apm_download_location,
    $apm_download_command  = $newrelic_java_agent::params::apm_download_command,
    $apm_download_user     = $newrelic_java_agent::params::apm_download_user,
    $apm_download_pass     = $newrelic_java_agent::params::apm_download_pass,
    $apm_zip_download_url  = $newrelic_java_agent::params::apm_zip_download_url,
    $apm_zip_file_location = $newrelic_java_agent::params::apm_zip_file_location,
    $run_before            = $newrelic_java_agent::params::run_before,
    $run_after             = $newrelic_java_agent::params::run_after,
    ) inherits  newrelic_java_agent::params {

    # only support RedHat and Debian based systems
    if ($::osfamily != 'RedHat' and $::osfamily != 'Debian') {
        fail("newrelic_java_agent - Unsupported Operating System family: ${::osfamily}")
    }

    # if we must run before a specific object enforce that
    if ($run_before and $run_before != 'false' ) {
        Class['newrelic_java_agent'] -> $run_before
    }

    # if we must run after a specific object enforce that
    if ($run_after and $run_after != 'false' ) {
        $run_after -> Class['newrelic_java_agent']
    }

    # if there is a download link, attempt to download the agent
    if ( $apm_zip_download_url and $apm_zip_download_url != 'false') {
        if ($apm_download_user and $apm_download_user != 'false' and $apm_download_pass and $apm_download_pass != 'false') {
            $download_creds = "-u ${apm_download_user}:${apm_download_pass}"
        } else {
            $download_creds = ''
        }

        $download_command = "${apm_download_command} ${download_creds}"
        $zip_url_splitted = split($apm_zip_download_url, '/')
        $zip_file_name = $zip_url_splitted[-1]
        $real_apm_zip_file_location = "${apm_download_location}/${zip_file_name}"

        exec { 'download_newrelic_apm':
            cwd     => $apm_download_location,
            command => "${download_command} ${apm_zip_download_url}",
            unless  => "test -f ${real_apm_zip_file_location}",
            timeout => 3600,
            before  => Exec['unzip_newrelic_apm']
        }
    } elsif ( ! $apm_zip_file_location or $apm_zip_file_location == 'false') {
        fail('newrelic_java_agent - You must specify either apm_zip_download_url or apm_zip_file_location')
    } else {
        $real_apm_zip_file_location = $apm_zip_file_location
    }

    # unzip the agent tar
    exec { 'unzip_newrelic_apm':
        command => "unzip -d ${install_base} ${real_apm_zip_file_location}",
        unless  => ["test -f ${config_file}"],
    }

    # if we need to chown the install dir do so
    if (str2bool($chown_install_dir)) {
        exec { 'change_newrelic_apm_owner':
            command => "chown -R ${owner}:${group} ${install_base}/newrelic",
            require => Exec['unzip_newrelic_apm']
        }
    }

    # deploy the APM config file
    file { $config_file:
        ensure  => file,
        owner   => $owner,
        group   => $group,
        mode    => '0664',
        content => template("${module_name}/newrelic.yml.erb"),
        require => Exec['unzip_newrelic_apm']
    }

}