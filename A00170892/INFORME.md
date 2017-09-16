# WORKSHOP 1 SISTEMAS DISTRIBUIDOS #

***1. Consigne los comandos de Linux necesarios para el aprovisionamiento de los servicios solicitados. 
En este punto no debe incluir recetas solo se requiere que usted identifique los comandos o acciones que debe automatizar***

***BASE DE DATOS***

__Instalación de mariadb__

  * yum install mariadb-server
  *	service firewalld start
  *	firewall-cmd --zone=public --add-port=3306/tcp --permanent
  *	firewall-cmd --reload
  *	service mariadb.service start

__Configuración de la base de datos__

  * /usr/bin/mysql_secure_installation

Se ejecuta un script para la configuración de la base de datos. Esto se hace a través de una serie de pasos. 
Las respuestas a cada paso son:

        o	Enter current password for root (enter for none):
        o	Set root password? [Y/n] y
        o	New password:  distribuidos
        o	Re-enter new password: distribuidos
        o	Remove anonymous users? [Y/n] n
        o	Disallow root login remotely? [Y/n] n
        o	Remove test database and access to it? [Y/n] n
        o	Reload privilege tables now? [Y/n] y
        
   * mysql -u root –pdistribuidos

     Se ingresa a la base de datos para crear el esquema y las tablas

   * create database database1
   * use database1
   * create table WebServer(id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id), name VARCHAR(30), ip VARCHAR(30))
   * INSERT INTO WebServer (name,ip) VALUES ('WebServer1','192.168.56.103');
   * INSERT INTO WebServer (name,ip) VALUES ('WebServer2','192.168.56.104');

     ![database](https://user-images.githubusercontent.com/17281733/30508614-d22073ba-9a60-11e7-898f-d1483c4dd58c.jpeg)


__Configuracion de permisos__

Una vez creado el esquema, la tabla y los datos de la misma, se debe dar permiso de consulta a los servidores web.

   * GRANT ALL PRIVILEGES ON *.* to 'WebServer1'@'192.168.56.103' IDENTIFIED by 'WebServer1';
   * GRANT ALL PRIVILEGES ON *.* to 'WebServer2'@'192.168.56.104' IDENTIFIED by 'WebServer2';


***SERVIDORES WEB***

__Instalacion de httpd__

   * yum install httpd
   * service firewalld start
   * firewall-cmd --zone=public --add-port=80/tcp --permanent
   * firewall-cmd –reload

__Configuracion para conexión remota__

   * yum install mariadb
   * sudo setsebool httpd_can_network_connect_db on

     Para permitir consultas a base de datos desde httpd

   * yum install php
   * yum install php-mysql

__Creación del servicio web__

   * cd /var/www/html/
   * vi template.php (se inserta el código html y php)
    
      En el código php que realiza la conexión a la base de datos, se ponen las credenciales del servidor. En el
      
      ![php-webserver1](https://user-images.githubusercontent.com/17281733/30508627-60ea2046-9a61-11e7-8312-fb1ad6a13e88.jpeg)
      
   * service httpd start
      
      
***BALANCEADOR DE CARGA HAPROXY***

__Instalacion de haproxy__

   * yum install haproxy

__Configuracion de haproxy__

Modificar archivo /etc/haproxy/haproxy.cfg con los datos de los servidores web.

![haproxy](https://user-images.githubusercontent.com/17281733/30508638-ad38e0cc-9a61-11e7-9d17-0c80179d3275.jpeg)

***2. Escriba el archivo Vagrantfile para realizar el aprovisionamiento, teniendo en cuenta definir: maquinas a aprovisionar, 
interfaces solo anfitrión, interfaces tipo puente, declaración de cookbooks, variables necesarias para plantillas. 
Incluya el Vagrantfile añadiendo comentarios en cada línea encargada del aprovisionamiento de la infraestructura.***

```ruby
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
```


***3. Escriba los cookbooks necesarios para realizar la instalación de los servicios solicitados. 
Incluya una tabla como se muestra a continuación explicando la función de cada archivo o directorio en los cookbooks. 
No incluya código fuente en el informe para esta sección.***

La estructura del directorio de cookbooks es la siguiente:

![tree-cookbooks](https://user-images.githubusercontent.com/17281733/30508670-0b4d30c8-9a62-11e7-9649-9ad679fe380c.jpeg)


![haproxytable](https://user-images.githubusercontent.com/17281733/30508699-96ce44d4-9a62-11e7-83d7-ab7862d76354.jpeg)
![httpd](https://user-images.githubusercontent.com/17281733/30508702-a3da4952-9a62-11e7-95c3-10b5327e94f6.jpeg)
![mariad-client](https://user-images.githubusercontent.com/17281733/30508703-b09a3076-9a62-11e7-8f1d-bbdd4a2f6372.jpeg)
![mariadb-server](https://user-images.githubusercontent.com/17281733/30508707-b7c66a36-9a62-11e7-9d2f-76d550034310.jpeg)


***4. Incluya evidencias gráficas que muestran el funcionamiento de lo solicitado***

__Características de los nodos__

| Nodo          | Ip             |
| ------------- |:--------------:|
| load_balancer | 192.168.56.101 |
| db_server     | 192.168.56.101 |
| web_server1   | 192.168.56.101 |
| web_server2   | 192.168.56.101 |


__Funcionamiento__

    * el cliente pide el servicio “template.php” a traves del balanceador: 192.168.56.101/template.php
    * el servicio consiste en dar las características (nombre y dirección ip) del servidor web que atiende el servicio
    * el balanceador redirige la petición a uno de los servidores web
    * el servidor web consulta la base de datos y responde al servicio

__Evidencias graficas__

![demostracion](https://user-images.githubusercontent.com/17281733/30508741-790598a2-9a63-11e7-8f3f-2a9b9147546b.gif)







