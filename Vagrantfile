Vagrant.configure(2) do |config|
  vm_name = "dockerhost"
  config.vm.hostname = vm_name
  #config.vm.box = "cbednarski/ubuntu-1404"
  config.vm.box = "ubuntu/trusty64"
  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--memory', '2048']
    vb.customize ['modifyvm', :id, '--cpus', '2']
    vb.name=vm_name
    #create disk for docker
    disk="disk.vdi"
    vb.customize ['createhd', '--filename', disk, '--size', '5128'] unless File.exists?("disk.vdi")
    vb.customize ['storageattach', :id, '--storagectl', 'SATAController', '--port', 1, '--device', '0', '--type', 'hdd', '--medium', "disk.vdi"]
  end
  # format the disk and mount it as /var/lib/docker
  config.vm.provision :shell, :path => "scripts/sdb.sh"
  # provision the box with docker and build/import a base ubuntu
  config.vm.provision :shell, :path => "scripts/provision.sh"
end
