require 'spec_helper'
 
describe 'newrelic_java_agent', :type => 'class' do

install_base          = '/install'
chown_install_dir     = 'true'
config_file           = '/install/newrelic/newrelic.yml'
owner                 = 'hosting'
group                 = 'hosting'
apm_download_location = '/download'
apm_download_command  = 'curl -O -L'
apm_download_user     = 'download_user'
apm_download_pass     = 'download_pass'
apm_zip_download_url  = 'https://download.example.com/newrelic-java-3.31.zip'
apm_zip_file_location = '/files/newrelic-java-3.31.1.zip'
download_filename     = 'newrelic-java-3.31.zip'
run_before            = 'Class[someclass]'
application_name      = 'my first test application'
license_key           = 'abcdefg1234567'

context "Should download and install" do
    let(:facts) {
      { :osfamily => 'RedHat',
        :operatingsystem => 'RedHat',
        :operatingsystemrelease => '6.0',
        :concat_basedir => '/tmp',
        :kernel => 'Linux',
        :id => 'root',
        :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      }
    }
    let(:params) {
      { :install_base => install_base,
        :chown_install_dir => chown_install_dir,
        :config_file => config_file,
        :owner => owner,
        :group => group,
        :apm_download_location => apm_download_location,
        :apm_download_command => apm_download_command,
        :apm_download_user => apm_download_user,
        :apm_download_pass => apm_download_pass,
        :apm_zip_download_url => apm_zip_download_url,
        :apm_zip_file_location => false, 
        :run_before  => false, 
        :application_name => application_name,
        :license_key => license_key
      }
    }
    
    it do
      should contain_exec('download_newrelic_apm').with(
          "command" => "#{apm_download_command} -u #{apm_download_user}:#{apm_download_pass} #{apm_zip_download_url}",
          "cwd" => apm_download_location,
          "unless"  => "test -f #{apm_download_location}/#{download_filename}",
          "timeout" => "3600",
          "before"  => "Exec[unzip_newrelic_apm]"
      )
      should contain_exec('unzip_newrelic_apm').with(
          "command" => "unzip -d #{install_base} #{apm_download_location}/#{download_filename}",
          "unless"  => ["test -f #{config_file}"],
      )
      should contain_exec('change_newrelic_apm_owner').with(
            "command" => "chown -R #{owner}:#{group} #{install_base}/newrelic",
            "require" => "Exec[unzip_newrelic_apm]"
      )
      should contain_file(config_file).with(
            "ensure"  => "file",
            "owner"   => owner,
            "group"   => group,
            "mode"    => '0664',
            "require" => "Exec[unzip_newrelic_apm]"
      )
      newrelic_apm_config = catalogue().resource('file', config_file).send(:parameters)[:content]
      expect(File.read('spec/files/newrelic.yml')).to eq(newrelic_apm_config)
    end
  end  

  context "Should install from file without downloading" do
    let(:facts) {
      { :osfamily => 'RedHat',
        :operatingsystem => 'RedHat',
        :operatingsystemrelease => '6.0',
        :concat_basedir => '/tmp',
        :kernel => 'Linux',
        :id => 'root',
        :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      }
    }
    let(:params) {
      { :install_base => install_base,
        :chown_install_dir => chown_install_dir,
        :config_file => config_file,
        :owner => owner,
        :group => group,
        :apm_download_location => apm_download_location,
        :apm_download_command => apm_download_command,
        :apm_download_user => apm_download_user,
        :apm_download_pass => apm_download_pass,
        :apm_zip_download_url => false,
        :apm_zip_file_location => apm_zip_file_location, 
        :run_before  => false, 
        :application_name => application_name,
        :license_key => license_key
      }
    }
    
    it do
      should_not contain_exec('download_newrelic_apm')
      should contain_exec('unzip_newrelic_apm').with(
          "command" => "unzip -d #{install_base} #{apm_zip_file_location}",
          "unless"  => ["test -f #{config_file}"],
      )
      should contain_exec('change_newrelic_apm_owner').with(
            "command" => "chown -R #{owner}:#{group} #{install_base}/newrelic",
            "require" => "Exec[unzip_newrelic_apm]"
      )
      should contain_file(config_file).with(
            "ensure"  => "file",
            "owner"   => owner,
            "group"   => group,
            "mode"    => '0664',
            "require" => "Exec[unzip_newrelic_apm]"
      )
      newrelic_apm_config = catalogue().resource('file', config_file).send(:parameters)[:content]
      expect(File.read('spec/files/newrelic.yml')).to eq(newrelic_apm_config)
    end
  end  
    
  context "Should throw an error if neither apm_zip_download_url or apm_zip_file_location are set" do
    let(:facts) {
      { :osfamily => 'RedHat',
        :operatingsystem => 'RedHat',
        :operatingsystemrelease => '6.0',
        :concat_basedir => '/tmp',
        :kernel => 'Linux',
        :id => 'root',
        :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      }
    }
    let(:params) {
      { :install_base => install_base,
        :chown_install_dir => chown_install_dir,
        :config_file => config_file,
        :owner => owner,
        :group => group,
        :apm_download_location => apm_download_location,
        :apm_download_command => apm_download_command,
        :apm_download_user => apm_download_user,
        :apm_download_pass => apm_download_pass,
        :apm_zip_download_url => false,
        :apm_zip_file_location => false, 
        :run_before  => false, 
        :application_name => application_name,
        :license_key => license_key
      }
    }
    
    it do
      should raise_error(Puppet::Error, /newrelic_java_agent - You must specify either apm_zip_download_url or apm_zip_file_location/)
    end
  end  

 context "Should throw an error if not running on RedHat or Debian based systems" do
    let(:facts) {
      { :osfamily => 'Solaris' }
    }
    let(:params) {
      { :install_base => install_base,
        :chown_install_dir => chown_install_dir,
        :config_file => config_file,
        :owner => owner,
        :group => group,
        :apm_download_location => apm_download_location,
        :apm_download_command => apm_download_command,
        :apm_download_user => apm_download_user,
        :apm_download_pass => apm_download_pass,
        :apm_zip_download_url => false,
        :apm_zip_file_location => false, 
        :run_before  => false, 
        :application_name => application_name,
        :license_key => license_key
      }
    }
    
    it do
      should raise_error(Puppet::Error, /newrelic_java_agent - Unsupported Operating System family: Solaris/)
    end
  end  


end
