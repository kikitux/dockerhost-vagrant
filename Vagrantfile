Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox"
  config.vm.provider "vmware_desktop"
  config.vm.define vm_name = "dockerhost" do |dh|
    dh.vm.hostname = vm_name
    dh.vm.box = "ubuntu/trusty64"
    dh.vm.network :forwarded_port, guest: 8080, host: 8080
    dh.vm.provider "virtualbox" do |vb|
      vb.customize ['modifyvm', :id, '--memory', '2048']
      vb.customize ['modifyvm', :id, '--cpus', '2']
      vb.name=vm_name
      #create disk for docker
      disk="#{File.dirname(__FILE__)}/disk.vdi"
      vb.customize ['createhd', '--filename', disk, '--size', '20480'] unless File.exists?("disk.vdi")
      vb.customize ['storageattach', :id, '--storagectl', 'SATAController', '--port', 1, '--device', '0', '--type', 'hdd', '--medium', disk]
    end
    #polipo proxy
    dh.vm.synced_folder "polipo", "/var/cache/polipo" , :mount_options => ["uid=13,gid=13"], create: true
    dh.vm.provision :shell, :path => "scripts/proxy.sh", :run => "always"
    # format the disk and mount it as /var/lib/docker
    dh.vm.provision :shell, :path => "scripts/sdb.sh"
    # provision the box
    dh.vm.provision :shell, :path => "scripts/provision.sh"

    # sample base docker
    dh.vm.provision :shell, :path => "scripts/trusty.sh"
    #dh.vm.provision :shell, :path => "scripts/ol7.sh"
    #dh.vm.provision :shell, :path => "scripts/ol7-glibc.sh"
    #dh.vm.provision :shell, :path => "scripts/xenial.sh"
  end
end
