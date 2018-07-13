# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.ssh.insert_key = false

  #CREACION DE LA MAQUINA VIRTUAL QUE FUNCIONARA COMO BASE DE DATOS
  config.vm.define :db_server do |client|
    #definicion de la imagen del SO a utilizar (en este caso Centos7)
    client.vm.box = "centos1706_v0.2.0"
    #Configuracion de una red privada e ip asociada a la maquina
    client.vm.network :private_network, ip: "192.168.56.102"
    #Configuracion de la cantidad de memoria RAM, numero de cpus y nombre de la maquina virtual
    client.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024","--cpus", "1", "--name", "db_server" ]
    end
    #Definicion del aprovisionador a utilizar (chef solo)
    config.vm.provision :chef_solo do |chef|
      #No se instala el aprovisionador porque ya esta contenido en la imagen del sistema operativo
      chef.install = false
      #Definicion del directorio que contiene las recetas de aprovisionamiento
      chef.cookbooks_path = "cookbooks"
      #Se añade la receta de mariadb-server
      chef.add_recipe "mariadb-server"
    end
  end

  #CREACION DE UNA MAQUINA VIRTUAL QUE FUNCIONARA COMO SERVIDOR WEB
  config.vm.define :web_server1 do |wb1|
    #definicion de la imagen del SO a utilizar (en este caso Centos7)
    wb1.vm.box = "centos1706_v0.2.0"
    #Configuracion de una red privada e ip asociada a la maquina
    wb1.vm.network :private_network, ip: "192.168.56.103"
    #Configuracion de la cantidad de memoria RAM, numero de cpus y nombre de la maquina virtual
    wb1.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024","--cpus", "1", "--name", "web_server1" ]
    end
    #Definicion del aprovisionador a utilizar (chef solo)
    config.vm.provision :chef_solo do |chef|
      #No se instala el aprovisionador porque ya esta contenido en la imagen del sistema operativo
      chef.install = false
      #Definicion del directorio que contiene las recetas de aprovisionamiento
      chef.cookbooks_path = "cookbooks"
      #Se añade la receta de httpd
      chef.add_recipe "httpd"
      #Se añade la receta de mariadb-client
      chef.add_recipe "mariadb-client"
      #Se agrega una variable que servira como identificador del servidor web
      chef.json = {"service_name" => "WebServer1"}
    end
  end

  #CREACION DE UNA MAQUINA VIRTUAL QUE FUNCIONARA COMO SERVIDOR WEB
  config.vm.define :web_server2 do |wb2|
    #definicion de la imagen del SO a utilizar (en este caso Centos7)
    wb2.vm.box = "centos1706_v0.2.0"
    #Configuracion de una red privada e ip asociada a la maquina
    wb2.vm.network :private_network, ip: "192.168.56.104"
    #Configuracion de la cantidad de memoria RAM, numero de cpus y nombre de la maquina virtual
    wb2.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024","--cpus", "1", "--name", "web_server2" ]
    end
    #Definicion del aprovisionador a utilizar (chef solo)
    config.vm.provision :chef_solo do |chef|
      #No se instala el aprovisionador porque ya esta contenido en la imagen del sistema operativo
      chef.install = false
      #Definicion del directorio que contiene las recetas de aprovisionamiento
      chef.cookbooks_path = "cookbooks"
      #Se añade la receta de httpd
      chef.add_recipe "httpd"
      #Se añade la receta de mariadb-client
      chef.add_recipe "mariadb-client"
      #Se agrega una variable que servira como identificador del servidor web
      chef.json = {"service_name" => "WebServer2"}
    end
  end

  #CREACION DE LA MAQUINA VIRTUAL QUE FUNCIONARA COMO BALANCEADOR DE CARGA
  config.vm.define :load_balancer do |balancer|
    #definicion de la imagen del SO a utilizar (en este caso Centos7)
    balancer.vm.box = "centos1706_v0.2.0"
    #Configuracion de una red privada e ip asociada a la maquina
    balancer.vm.network :private_network, ip: "192.168.56.101"
    #Configuracion de la cantidad de memoria RAM, numero de cpus y nombre de la maquina virtual
    balancer.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024","--cpus", "1", "--name", "load_balancer" ]
    end
    #Definicion del aprovisionador a utilizar (chef solo)
    config.vm.provision :chef_solo do |chef|
      #No se instala el aprovisionador porque ya esta contenido en la imagen del sistema operativo
      chef.install = false
      #Definicion del directorio que contiene las recetas de aprovisionamiento
      chef.cookbooks_path = "cookbooks"
      #Se añade la receta de haproxy
      chef.add_recipe "haproxy"
      #Se agregan las ips de los servidores web, como variables, para luego ser utilizadas en
      #la modificacion del archivo de configuracion de haproxy
      chef.json = {
        "web_servers" => [
          {"ip":"192.168.56.103"},
          {"ip":"192.168.56.104"}
        ]
      }
    end
  end

end
