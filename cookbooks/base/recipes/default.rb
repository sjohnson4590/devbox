yum_repository 'chef' do
  baseurl 'https://packages.chef.io/repos/yum/stable/el/$releasever/$basearch/'
  gpgcheck true
  enabled true
  gpgkey 'https://packages.chef.io/repos/yum/stable/el/$releasever/$basearch/repodata/repomd.xml.key'
end

node['base']['default_packages'].each do |package_name|
    package package_name
end

bash 'install atom' do
  code <<-EOH
  wget --quiet https://github.com/atom/atom/releases/download/v1.11.2/atom.x86_64.rpm;
  yum install -y -q atom.x86_64.rpm
  EOH
  not_if { ::File.exists?('/bin/atom') }
end

user 'steve' do
  password '$1$3vQrHajO$/VxkV9QQEMR2Jdwj0BbZi0' # plaintext: vagrant
  home '/home/steve'
  shell '/bin/bash'
end

directory '/home/steve' do
  owner 'steve'
  group 'steve'
  mode 0700
end

template '/home/steve/.bashrc' do
  source 'bashrc.erb'
  owner 'steve'
  group 'steve'
  mode 0644
end

execute 'Add steve to root group' do
  command 'sudo usermod --groups wheel steve' # because I'm a piece of shit
end

node['base']['apm_packages'].each do |package|
  execute "Install APM package #{package}" do
    command "apm install #{package}"
    user 'steve'
    cwd '/home/steve'
    environment ({'HOME' => '/home/steve', 'USER' => 'steve'})
  end
end

node['base']['gui_packages'].each do |package|
  package package
end

link '/etc/systemd/system/default.target' do
  to '/lib/systemd/system/graphical.target'
  link_type :symbolic
end
