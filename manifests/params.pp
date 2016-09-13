class newrelic_java_agent::params {
    $install_base = '/opt'
    $config_file = "${install_base}/newrelic/newrelic.yml"
    $chown_install_dir = true
    $owner = 'root'
    $group = 'root'
    $apm_download_location = '/tmp'
    $apm_download_command = 'curl -O -L'
    $apm_download_user = undef
    $apm_download_pass = undef
    $apm_zip_download_url = undef
    $apm_zip_file_location = undef
    $run_before = undef
}