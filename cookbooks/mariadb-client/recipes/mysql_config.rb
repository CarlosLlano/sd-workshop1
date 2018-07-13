#permitir conexion a la base de datos desde httpd
=begin
By default, the httpd_can_network_connect_db Boolean is off,
preventing Apache HTTP Server scripts and modules from connecting to database servers:
=end
bash 'open port' do
	user 'root'
	code <<-EOH
	setsebool httpd_can_network_connect_db on
	EOH
end

#instalar php
yum_package 'php' do
    action :install
end

#instalar php-mysql para conexion a la base de datos con php
yum_package 'php-mysql' do
    action :install
end
