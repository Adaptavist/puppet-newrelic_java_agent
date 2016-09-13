# Newrelic_Java_Agent Module
[![Build Status](https://travis-ci.org/Adaptavist/puppet-newrelic_java_agent.svg?branch=master)](https://travis-ci.org/Adaptavist/puppet-newrelic_java_agent)
## Overview

The **Newrelic_Java_Agent** module installs and configures a basic Newrelic Java APM, running the agent as part of your java app is outside the scope of this module

Currently this modue only supports the most basic configuration for the New Java APM, namely the license key and application name, over time more options will be added to make the APM agent more configurable via puppet

## Configuration

`newrelic_java_agent::install_base:`

The instalaltion base, defaults to "/opt"

`newrelic_java_agent::chown_install_dir:`

Flag to determine if the installations directory (install_base/newrelic) should have its owner and group changed recursivly, defaults to true

`newrelic_java_agent::config_file:` 

The location of the APM config file, defaults to "/opt/newrelic/newrelic.yml"

`newrelic_java_agent::owner:` 

The owner to chown the installation to if `chown_install_dir` is set to true, defaults to "root"

`newrelic_java_agent::group:` 

The group to chown the installation to if `chown_install_dir` is set to true, defaults to "root"

`newrelic_java_agent::apm_zip_file_location:`

The location the APM zip on the filesystem, if `apm_zip_download_url` is set then this is ignored, defaults to undef

`newrelic_java_agent::apm_zip_download_url:`

The URL to download the APM zip, if both this and `` are set the download takes precidence, defaults to undef

`newrelic_java_agent::apm_download_location:`

The location to download the APM zip to if `apm_zip_download_url` is set, defaults to "/tmp"

`newrelic_java_agent::apm_download_command:`

The command to use to download the APM zip if `apm_zip_download_url` is set, defaults to "curl -O -L"

`newrelic_java_agent::apm_download_user:`

The username to use in order to download the APM zip if `apm_zip_download_url` is set, this is optional and is only used if `apm_download_pass` is also set, defaults to undef

`newrelic_java_agent::apm_download_pass:`

The password to use in order to download the APM zip if `apm_zip_download_url` is set, this is optional and is only used if `apm_download_user` is also set, defaults to undef

`newrelic_java_agent::run_before:`

Allows a class dependency to be introduced to force Newrelic_Java_Agent to run before another puppet resource, Examples "Class[avstapp]" or "File[/tmp/somefile]", defaults to undef

`newrelic_java_agent::application_name:`

The application name to set in the newrelic.yml, this is mandatory and has no default value

`newrelic_java_agent::license_key`

The license key to set in the newrelic.yml, this is mandatory and has no default value


## Dependencies

This module depends on the following puppet modules:

* stdlib

