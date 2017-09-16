#pagina inicial de icesi usada para probar el funcionamiento de httpd
cookbook_file '/var/www/html/index.html' do
	source 'index.html'
	mode 0644
	owner 'root'
	group 'wheel'
end

#pagina de prueba
cookbook_file '/var/www/html/info.php' do
	source 'info.php'
	mode 0644
	owner 'root'
	group 'wheel'
end

#pagina solicitada por los clientes
template '/var/www/html/template.php' do
	source 'template.php.erb'
	mode 0644
	owner 'root'
	group 'wheel'
	variables(
		:service_name => node[:service_name]
	)
end

#pagina de prueba
template '/var/www/html/prueba.php' do
	source 'prueba.php.erb'
	mode 0644
	owner 'root'
	group 'wheel'
	variables(
		:service_name => node[:service_name]
	)
end
