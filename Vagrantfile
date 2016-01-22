Vagrant.configure(2) do |config|
  vm_name = "dockerhost"
  config.vm.hostname = vm_name
  config.vm.box = "cbednarski/ubuntu-1404"
  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--memory', '2048']
    vb.customize ['modifyvm', :id, '--cpus', '2']
    vb.name=vm_name
    disk="disk.vdi"
    vb.customize ['createhd', '--filename', disk, '--size', '5128'] unless File.exists?("disk.vdi")
    vb.customize ['storageattach', :id, '--storagectl', 'IDE Controller', '--port', 1, '--device', '0', '--type', 'hdd', '--medium', "disk.vdi"]
  end
  config.vm.provision :shell, :path => "sdb.sh"
  config.vm.provision :shell, :path => "provision.sh"
end