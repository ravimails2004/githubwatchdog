#
# Cookbook Name:: git_watchdog
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
watchdog_root="/home/watchdog"
watchdog_exe="/usr/bin"
watchdog_service_dir="/etc/systemd/system/"

execute 'display_banner' do
 command 'echo "##################Lets run the yum update and fix the pkg dependency, this is really needed as we need to add some packages to run this program #########################"'
end

execute 'yum_update' do
 command 'yum -y update'
end

execute 'display_pip_banner' do
 command 'echo "###################Installing PIP###############################"'
end

execute 'python_dependeny' do
    command '/usr/bin/curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && /usr/bin/python get-pip.py && /usr/bin/pip install pyyaml requests twython'
    not_if do ::File.exists?('/usr/bin/pip') end
end   

user 'watchdog' do
  comment 'a user to run the github daemon'
  home '/home/watchdog'
  shell '/sbin/nologin'
end

cookbook_file "/home/watchdog/github_watchdog-1.0.0-1.x86_64.rpm" do
  source "github_watchdog-1.0.0-1.x86_64.rpm"
  mode "0755"
  user "watchdog"
  group "watchdog"
end

execute "cd /home/watchdog && yum install github_watchdog-1.0.0-1.x86_64.rpm -y" do
  not_if "rpm -qa | grep '^github_watchdog'"
end

%w[/home/watchdog/config.yaml /home/watchdog/contributors.json /home/watchdog/git_watchdog.log /home/watchdog/watchdog.py  ].each do |item|
  file item do
    owner "watchdog"
    group "watchdog"
   end 
end

template "#{watchdog_exe}/watchdog.sh" do
	source "watchdog.sh.erb"
	mode "0755"
variables ({
      "startup_options" => node["watchdog"]["startup"]
  })
end

template "#{watchdog_service_dir}/watchdog.service" do
        source "watchdog.service.erb"
        mode "0755"
variables ({
      "startup_options" => node["watchdog"]["startup"]
  })
end

template "#{watchdog_root}/config.yaml" do
        source "config.yaml.erb"
        mode "0755"
variables ({
      "startup_options" => node["watchdog"]["startup"],
      "config_yaml_params" => node["watchdog"]["config_yaml_params"],
      "twitter_secrets"  =>  node["watchdog"]["twitter"]
  })
end

service "watchdog" do
  supports :restart => true, :start => true, :stop => true
  action [ :enable, :start ]
end
