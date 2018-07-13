#ACTIVAR EL SERVICIO DE BASE DE DATOS
service 'mariadb.service' do
    action [ :start, :enable ]
end


#ABRIR PUERTOS PARA COMUNICACION REMOTA CON LA BASE DE DATOS
service 'firewalld' do
    action [ :enable, :start ]
end

bash 'open port' do
	user 'root'
	code <<-EOH
	firewall-cmd --zone=public --add-port=3306/tcp --permanent
	EOH
end

bash 'reload' do
	user 'root'
	code <<-EOH
	firewall-cmd --reload
	EOH
end

#CONFIGURACION DE PERMISOS
##Instalacion de expect
yum_package 'expect' do
 action :install
end

##copiar plantilla en un archivo
cookbook_file '/tmp/configure_mariadb.sh' do
	source 'configure_mariadb.sh'
	mode 0711
	owner 'root'
	group 'wheel'
end

##ejecutar archivo creado
bash 'configure mariadb' do
 user 'root'
 group 'wheel'
 cwd '/tmp'
 code <<-EOH
 ./configure_mariadb.sh
 EOH
end

##crear archivo con los datos del esquema
cookbook_file '/tmp/create_schema.sql' do
	source 'create_schema.sql'
	mode 0644
	owner 'root'
	group 'wheel'
end

##crear esquema
bash 'create schema' do
	user 'root'
	cwd '/tmp'
	code <<-EOH
	cat create_schema.sql | mysql -u root -pdistribuidos
	EOH
end
