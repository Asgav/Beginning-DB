sudo -u postgres psql 
psql --help
-- \h create rol
CREATE ROLE u_consulta WITH password 'una contraseña';--creando el usuario_consulta
psql -h localhost -p 5432 -d postgres -U u_consulta--ingresar con el Usuario u_consulta
GRANT INSERT, SELECT, UPDATE ON TABLE public.stations TO usuario;--dando privilegios a los ususarios de la edicion de las tablas

\l --para ver las DB
\d --muestra las relaciones de la DB 
\dn--Listar los esquemas de la DB actual
\df--Listar las funciones disponibles de la DB actual
\dt--muestra las tablas
\du-- Listar los usuarios y sus roles de la DB actual
\d [nombre de la tabla]--para la descripcion de la tabla
\c [nombre de la DB]--para conectar con otra DB
\s --Ver el historial de comandos ejecutados
\s [nombre_archivo]--guardar la lista de comandos ejecutados en un archivo de texto plano
\i [nombre_archivo]-- Ejecutar los comandos desde un archivo
\e --Permite abrir un editor de texto plano

--Postgresql.conf: Configuración general de postgres, múltiples opciones referentes a direcciones de conexión de entrada, memoria, cantidad de hilos de pocesamiento, replica, etc.
--pg_hba.conf: Muestra los roles así como los tipos de acceso a la base de datos.
  --METHOD trust en pg_hba no pida constraseña a los usuarios conectados
--pg_ident.conf: Permite realizar el mapeo de usuarios. Permite definir roles en la BD a usuarios del sistema operativo donde se ejecuta postgres
--Para saber cuando crear índices usarlos en columnas q uses para cruzar 2 tablas y en columnas que aparezcan en la mayoría de las consultas.
CREATE TABLE trains (
  id serial NOT NULL,
  model character varying,
  capacity INTEGER,
  CONSTRAINT trains_pkey PRIMARY KEY (id)
);
CREATE TABLE stations (
  id SERIAL NOT NULL,
  station_name VARCHAR(100),
  address_station VARCHAR,
  CONSTRAINT stations_pkey PRIMARY KEY (id)
);
CREATE TABLE passengers (
  id SERIAL NOT NULL,
  name VARCHAR(255),
  address VARCHAR,
  birthdate DATE,
  CONSTRAINT passengers_pkey PRIMARY KEY (id)
);
CREATE TABLE routs (
  id SERIAL NOT NULL,
  train_id INTEGER,
  station_id INTEGER,
  rout_name VARCHAR(255),
  CONSTRAINT routs_pkey PRIMARY KEY (id),
  CONSTRAINT routs_train_fk FOREIGN KEY (train_id)
      REFERENCES trains(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT routs_station_fk FOREIGN KEY (station_id)
      REFERENCES stations(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE TABLE voyages (
  id SERIAL NOT NULL,
  passenger_id integer NOT NULL,
  rout_id INTEGER NOT NULL,
  start_voyage TIMESTAMPTZ,
  end_voyage TIMESTAMPTZ,
  CONSTRAINT voyages_pkey PRIMARY KEY (id),
  CONSTRAINT voyages_rout_fk FOREIGN KEY (rout_id)
      REFERENCES routs(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT voyages_passenger_fk FOREIGN KEY (passenger_id)
      REFERENCES passengers(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE routs_voyage (
  id SERIAL NOT NULL,
  rout_id INTEGER NOT NULL,
  voyage_id INTEGER NOT NULL,
  CONSTRAINT routs_voyage_pkey PRIMARY KEY (id),
  CONSTRAINT routs_voyage_fk1 FOREIGN KEY (rout_id)
      REFERENCES routs(id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT routs_voyage_fk2 FOREIGN KEY (voyage_id)
      REFERENCES voyages(id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
-------------------------------------------------
-- Agregar llaves foráneas despues a las tablas
-------------------------------------------------
ALTER TABLE public.routs ADD CONSTRAINT routs_station_fk FOREIGN KEY (station_id)
      REFERENCES stations (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE NO ACTION, NOT VALID;

----------------------------------------
-- Particion de la tabla por trimestres
-----------------------------------------
CREATE TABLE binnacle_voyages (
  id SERIAL NOT NULL,
  voyage_id INTEGER NOT NULL,
  date DATE NOT NULL
) PARTITION BY RANGE (date);

CREATE TABLE binnacle_voyages20201 PARTITION OF binnacle_voyages
FOR VALUES FROM ('2020-01-01') TO ('2020-03-31'),
CONSTRAINT binnacle_voyages20201_pk PRIMARY KEY (id),;
CREATE TABLE binnacle_voyages20202 PARTITION OF binnacle_voyages
FOR VALUES FROM ('2020-04-01') TO ('2020-06-30');
CREATE TABLE binnacle_voyages202001 PARTITION OF binnacle_voyages
FOR VALUES FROM ('2020-07-01') TO ('2020-09-30');
CREATE TABLE binnacle_voyages202001 PARTITION OF binnacle_voyages
FOR VALUES FROM ('2020-10-01') TO ('2020-12-31');
-----------------------------------------
  INSERT INTO stations(
            id, station_name, address_station)
    VALUES (1, 'nombre', 'direc')
    ON CONFLICT (id) DO UPDATE SET station_name = EXCLUDED.station_name,
     address_station = VALUES(address_station);
  -- ON CONFLICT DO (id) DO NOTING --no hace la insersión del valor

  INSERT INTO stations(
            station_name, address_station)
    VALUES ( 'ret', 'returnin') 
    RETURNING *; --devuelve los datos ejecutados
  
  SELECT * FROM passengers 
    WHERE name LIKE '%G%'; --ILIKE es para que distinga MAYUSCULAS y minusculas

    IS / IS NOT compara datos de tipo objeto 
----------------------------------------------------
   --COALESCE compara el campo con valores NULL y en este caso pone 'No aplica' si son nulos 
   SELECT id, COALESCE(station name, 'No aplica') AS station_name, address_station
    FROM station WHERE id = 1; 
    -- NULLIF compara si dos campos son iguales y retorna NULL si es así
    SELECT NULLIF (0,0)
  --GREATEST de un conjunto datos retorna el mayor
  --LEAST retorna el menor
  SELECT GREATEST (0,8,9,13,90)
  SELECT LEAST (0,8,9,13,90)
-----------------------------------------------------------
--EXPRESION DE CONDICIONES

  SELECT id, name, address, birthdate, 
      CASE 
        WHEN birthdate > '2003-01-01' THEN 'niño' 
        WHEN birthdate <= '2002-12-31' and birthdate >'1994-12-31' THEN 'Joven'
        ELSE 'mayor' 
      END AS Categoria,
      CASE
        WHEN birthdate > '2002-12-31' THEN 'menor de edad' 
        ELSE 'Mayor de edad' 
      END AS Edad,
      CASE
        WHEN name ILIKE 'A%' THEN 'su nombre empieza por A' 
        ELSE 'No aplica'
       END 
  FROM passengers;
  --------------------------------------------------------------
--Vista Volatil muestra resultados actuales de la DB

CREATE OR REPLACE VIEW rango_view
  AS
  SELECT id, name, address, birthdate, 
      CASE 
        WHEN birthdate > '2003-01-01' THEN 'niño' 
        WHEN birthdate <= '2002-12-31' and birthdate >'1994-12-31' THEN 'Joven'
        ELSE 'mayor' 
      END AS Categoria FROM passengers ORDER BY Categoria;

SELECT * FROM rango_view;

--Vista Materializada muestra resultados guardado en memoria NO es util para ver ultimas modificaciones
CREATE MATERIALIZED VIEW name_rout_mview
AS
SELECT * FROM routs WHERE rout_name LIKE 'Zoo%';

REFRESH MATERIALIZED VIEW Zoo_name_rout; --actualiza la vista materializada ya creada
DROP MATERIALIZED VIEW Zoo_name_rout-- eliminar

----------------------------------------------
--PL/PSQL
  -- para asignacion de variables := 
  --para consultas =
  -- la variable a la izquierda de record que es el tipo de dato que almacena info de las filas
DO $$
BEGIN
  RAISE NOTICE 'Algo esta pasando';
END
$$

DO $$
DECLARE
rec record --la variable rec va a almacenar los datos de la consulta
BEGIN
  FOR rec IN SELECT *FROM passengers LOOP
    RAISE NOTICE 'A passenger called %' , rec.name;
  END LOOP;
END
$$
--modificar variables internamente en un procedimiento almacenado
DO $$
DECLARE
rec record;
contador INTEGER := 0;
BEGIN
  FOR rec IN SELECT *FROM passengers LOOP
    RAISE NOTICE 'A passenger called %' , rec.name;
    contador := contador + 1;
END LOOP;
RAISE NOTICE 'Conteo es %' , contador;
END
$$
--encapsulando todo el bloque de código en una función 
CREATE FUNCTION importantPL()
RETURNS void 
AS $$
DECLARE
rec record;
contador INTEGER := 0;
BEGIN
  FOR rec IN SELECT *FROM passengers LOOP
    RAISE NOTICE 'A passenger called %' , rec.name;
END LOOP;
RAISE NOTICE 'Conteo es %' , contador;
END
$$
LANGUAGE PLPGSQL;

CREATE FUNCTION add_number(a integer,b integer)
RETURNS integer 
  AS $$
    BEGIN
      RETURN a + b;
    END;$$
LANGUAGE PLPGSQL;


SELECT importantPL();
--actualizando funcion PL
CREATE OR REPLACE FUNCTION importantPL()
RETURNS INTEGER
AS $$
DECLARE
rec record;
contador INTEGER := 0;
BEGIN
  FOR rec IN SELECT *FROM passengers LOOP
    RAISE NOTICE 'A passenger called %' , rec.name;
    contador := contador + 1;
END LOOP;
RAISE NOTICE 'Conteo es %' , contador;
RETURN contador;
END
$$
LANGUAGE PLPGSQL;

----------------------------------------------------
--TRIGGERS
CREATE TABLE count_passenger(
  id SERIAL,
  total INTEGER,
  tiempo TIME WITH TIME ZONE,
  CONSTRAINT count_passenger_pkey PRIMARY KEY (id)
);

--creamos la PL para que función cuente los pasajeros
CREATE OR REPLACE FUNCTION passengerPL()
RETURNS INTEGER
AS $$
DECLARE
rec record;
contador INTEGER := 0;
BEGIN
  FOR rec IN SELECT *FROM passengers LOOP
    RAISE NOTICE 'A passenger called %' , rec.name;
    contador := contador + 1;
END LOOP;
INSERT INTO count_passenger (total, tiempo)
VALUES (contador, now());
RETURN contador;
END
$$
LANGUAGE PLPGSQL;

-- modificamos la función para retorne no un valor sino un trigger
CREATE OR REPLACE FUNCTION passengerPL()
RETURNS TRIGGER
AS $$
DECLARE
rec record;
contador INTEGER := 0;
BEGIN
  FOR rec IN SELECT *FROM passengers LOOP
    contador := contador + 1;
END LOOP;
INSERT INTO count_passenger (total, tiempo)
VALUES (contador, now());
RETURN NEW; --puede ser OLD tambien para acciones UPDATE
END
$$
LANGUAGE PLPGSQL;

--crear el trigger para integralo en una DB a la acciones de una tabla [update, truncate, insert, delete] 


CREATE TRIGGER mitrigger
AFTER INSERT--INSTEAD OF, BEFORE
ON passengers
FOR EACH ROW 
EXECUTE PROCEDURE passengerPL();

-----------------------------------------------------------
-- conectarse a otras DB de servidores remotos dentro de una query
SELECT * FROM 
dblink ('dbname = remota
         port = 5432
         host = 127.0.0.1
         user = u_consulta
         password = a123',
         'SELECT id, fecha FROM vip'
         )
         AS datos_remotos (id INTEGER, fecha DATE);

SELECT * FROM passengers
  JOIN
    dblink ('dbname = remota
         port = 5432
         host = 127.0.0.1
         user = u_consulta
         password = a123',
         'SELECT id, fecha FROM vip'
         )
         AS datos_remotos (id INTEGER, fecha DATE)
  ON passengers.id = datos_remotos.id;

  SELECT * FROM vip
  JOIN
    dblink ('dbname = transporte
         port = 5432
         host = 127.0.0.1
         user = u_consulta
         password = a123',
         'SELECT id, name, birthdate FROM passengers'
         )
         AS datos_transporte (id INTEGER, name VARCHAR, birthdate DATE)
  ON vip.id = datos_transporte.id;
---------------------------------------------------------------
--TRANSACCIONES
 --rollback, begin and commit
BEGIN;
SELECT now();
COMMIT;

BEGIN;	
INSERT INTO trains ( 
	 model, capacity)
	VALUES ( 'Model Tran', 666);--no lo inserta porque las dos acciones estan en una misma transaccion y hay un fallo en la insersion de la tabla station
	
INSERT INTO stations (
	 id, nombre, direccion)
	VALUES ( 2,'transac', 'direcTran'); --no lo inserta porque ya existe ese id en station
COMMIT;
-----------------------------------------------------------------
--OTRAS EXTENSIONES
-- Levenshtein compara palabras por diferencia de caracteres
--difference compara similaridad por prununciación en ingles de las palabras siendo 0 <> y 4 =
------------------------------------------------------------------
--  **BACKUP** AND **RESTORE**
-----------------------------------------------------------------
pg_dump [connection-option...] [option...] [dbname]
pg_restore [connection-option...] [option...] [filename]
--Custom formato unico de postgress varia con la version de PostgeQL
-- Tar arcgivo comprimido de la estructura de DB
-- Plain formato sql recomendado para cuando se hace una restauracion en version <>
-- Directory estructura de la DB sin comprimir
--**No es recomendable guardar archivos binarios blobs
---------------------------------------------------------
-- MASTER AND REPLICS
---------------------------------------------------------
Configurar el Master y la Replica en servidores diferentes
En Master el archivo postgresql.conf 
buscar wal_level = hot_standby los archivos de bitacora se mantinen hasta que la replicas lean esos achivos y los copien
buscar max_wal_senders = 2
buscar archive_mode = on para que los archivos de bitacora no se borren y se archiven para que las copias de Replica los lean desde alli
buscar archive_command = 'cp %p /tmp/%f'se indica un comando de Linux para copiar archivos y dejarlos en una carpeta temporal 
el archivo pg_hba.conf se configura host - replication - all - IP replica interna (arriba) con /32 - trust
Resetear Master (Restart Node) 

En Replica concetarse por consola en la DB (Web SSH)
~$ sudo service postgresql stop 
  \\hace la copia de seguridad directamente de los archivos de la Master a la Replica

~$ rm - rf /var/lib/pgsql/data
  \\Borrar lo que existe en el archivo local

~$ pg_basebackup -U webadmin -R -D /var/lib/pgsql/data --host = IP Master interna (arriba) --port 5432
T \\trae todo lo de Master y lo incializa como la nueva DB 

Hacer cambio en Replica el archivo postgresql.conf para que comporte como réplica
buscar wal_level = hot_standby
buscar hot_standby = on
Reiniciar Replica con:
~$sudo service postgresql start  
