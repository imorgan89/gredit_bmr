#Se importan las librerias 

require 'active_record'
require 'odbc_utf8'

#Se conecta a la base de Postgre

@@ar_connection['monitor_data']

#Se crea la tabla en Postgre que se va a importar de Sybase (se asumen que la definicion del tipo de dato es igual en SQLServer que en Postgre)
#A confirmar con el manual tecnico que nos tienen que pasar

crear = "CREATE TABLE inventario_CA 
   (
	 fecproc   datetime  null,
   sistcod   smallint  not null,
   succod   smallint  not null,
   moncod   smallint  not null,
   tipopercod   numeric(14,0)  not null,
   descripcion   varchar(50)  not null,
   cuecod   numeric(17,0)  not null,
   sdodisponible   numeric(18,3)  not null,
   intdevadeu   int  not null,
   intdevacre   numeric(18,3)  null,
   fecultmov   datetime  null,
   estctacod   smallint  not null,
   cueestdesc   varchar(30)  not null,
   prodcod   smallint  not null,
   prodnom   varchar(150)  null,
   tipbloqcod   smallint  null
	)"

ActiveRecord::Base.connection.exec_query(crear)

#Nos conectamos a la base de datos de Sybase

client = ODBC.connect 'SYBASETESTING'

#Levantamos la tabla inventario_CA de Sybase
columns = %w(fecproc sistcod succod moncod tipopercod descripcion cuecod sdodisponible intdevadeu intdevacre fecultmov estctacod cueestdesc prodcod prodnom tipbloqcod)

query = <<-SQL 
	SELECT #{columns.join ','} FROM inventario_CA;
SQL
	#WHERE fecproc = 'Nov  7 2018 12:00:00:000AM';esto lo deberiamos pasar a una variable que tenga el mismo formato que el campo

class Inventario_CAS < ActiveRecord::Base
  self.table_name = 'inventario_CA'
end

stat = client.prepare query

stat.execute

while row = stat.fetch
	Inventario_CAS.create(Hash[columns.zip row])
end  
  
#Se corta la conexion

stat.drop  
