Vagrant.configure("2") do |config|
  config.vm.box = "centos_65_puppet"
  config.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/centos-65-x64-virtualbox-puppet.box"
  config.vm.hostname = "typo3.local"
  config.vm.network "private_network", ip: "192.168.33.62"

  # Only works for mac osx and linux, windows wont works
  # config.vm.synced_folder "./www", "/var/www", id: "vagrant-www", :nfs => true
  # config.vm.synced_folder "./www", "/vagrant-nfs/www", id: "vagrant-www", :nfs => true
  # config.bindfs.bind_folder "/vagrant-nfs/www", "/var/www"

  config.vm.provider :virtualbox do |virtualbox|
      virtualbox.customize ["modifyvm", :id, "--memory", "1024"]
  end

  config.vm.provision :puppet do |puppet|
      puppet.facter = {
        "ssh_username" => "vagrant"
      }

      puppet.manifests_path = "vagrant/puppet/manifests"
      puppet.module_path = "vagrant/puppet/modules"
      puppet.manifest_file = "init.pp"
      puppet.options = ["--verbose",]
  end
end