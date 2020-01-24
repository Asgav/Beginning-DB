CREATE DATABASE IF NOT EXIST platzi_operation;
USE platzi_operation;

CREATE TABLE books (
    book_id INTEGER UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    author_id INTEGER UNSIGNED,
    title VARCHAR(100) NOT NULL,
    year_book INTEGER UNSIGNED NOT NULL DEFAULT 0000,
    language VARCHAR(2) NOT NULL DEFAULT 'ES' COMMENT 'ISO 639-1 Language',
    cover_url VARCHAR(500),
    price DOUBLE(6,2),
    sellable TINYINT(1) DEFAULT 1,
    copies INTEGER NOT NULL DEFAULT 1,
    description_book TEXT
);

CREATE TABLE IF NOT EXISTS authors (
    author_id INTEGER UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name_author VARCHAR(100) NOT NULL,
    nationality VARCHAR(3)
);

CREATE TABLE clients (
    client_id INTEGER UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name_client VARCHAR(60) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    birthdate DATETIME,
    gender ENUM('M', 'F', 'ND') NOT NULL,
    activ TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS operations (
    operation_id INTEGER UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    book_id INTEGER UNSIGNED,
    client_id INTEGER UNSIGNED,
    type ENUM('sold', 'lended', 'returned') NOT NULL, 
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,
    finished TINYINT(1) NOT NULL DEFAULT 0
);

-- para referenciar clave foránea en la tabla compra
CREATE TABLE compra
(
    id_compra INTEGER NOT NULL PRIMARY KEY AUTO_INCREMENT,
    productos_id INTEGER NOT NULL, 
    cantidad_client_id INTEGER UNSIGNED,
    CONSTRAINT fk_compra_clients
    FOREIGN KEY (cantidad_client_id)
      REFERENCES clients(client_id)
      ON DELETE CASCADE
)

INSERT INTO authors(author_id, name_author,nationality)
VALUES('', 'Juan Rulfo', 'MEX');
INSERT INTO authors 
VALUES ('', 'Mario Mendoza', 'COL');
-- estas me gustaron mas
INSERT INTO authors(name_author, nationality)
VALUES('Gabriel García Márquez', 'COL'); 
INSERT INTO authors 
VALUES('Gabriel García Márquez', 'COL');
-- Si no se mencionaran algunas columnas que quedaran en defaul debe sentenciar la función
INSERT INTO clients (name_client, email, birthdate, gender)
    VALUES ('Maria Dolores Gomez','Maria Dolores.95983222J@random.names',
    '1971-06-06','F',);


INSERT INTO clients 
VALUES (1,'Maria Dolores Gomez','Maria Dolores.95983222J@random.names',
    '1971-06-06','F',1,'2018-04-09 16:51:30');
INSERT INTO clients 
VALUES (1,'Maria Dolores Gomez','Maria Dolores.95983222J@random.names',
    '1971-06-06','F',0,'2018-04-09 16:51:30'), 
    -- ON DUPLICATE KEY IGNORE ALL ejecuta pero no muestra errores NO USAR;
    -- ON DUPLICATE KEY UPDATE active = VALUES(active); actualiza el registro con el valor que ponga en este caso el valor del campo activ

-- Este es un INSERT con queries anidados permite obtener el ID apartir de la tabla authors y la columna del nombre del autor.

INSERT INTO books(title, author_id, year_books) 
VALUES ('el libro secreto',
    (select author_id from authors
     WHERE name_author = 'Octavio Perez'
     LIMIT 1
    ), 1987
);

SELECT name_client, email FROM clients LIMIT 10;
SELECT name_client, email FROM clients WHERE gender = 'M';
SELECT year(birthdate) FROM clients WHERE gender = 'F';
SELECT name_client, year(NOW())- year(birthdate) FROM clients;
SELECT * FROM clients WHERE month(birthdate)= 05;
SELECT * FROM clients WHERE name_client LIKE '%Gomez%';
SELECT name_client, email, year(NOW()) - year(birthdate) AS edad, gender
    FROM clients WHERE gender = 'F'
    AND name_client LIKE '%Lop%';
SELECT count(*) from books; 
SELECT * FROM books WHERE author_id BETWEEN 1 and 5;

SELECT b.book_id, a.name, a.author_id, b.title
FROM books AS b   
    INNER JOIN authors AS a  
    ON a.author_id = b.author_id; 

SELECT C.name, B.title, T.type, T.finished
FROM transactions as T 
    JOIN books as B ON T.book_id = B.book_id
    JOIN clients as C ON T.client_id = C.client_id 
    WHERE C.gender = 'F' AND T.type = 'sell';

SELECT C.name, B.title, A.name, T.type,T.finished
FROM transactions as T 
    JOIN books as B ON T.book_id = B.book_id
    JOIN clients as C ON T.client_id = C.client_id 
    JOIN authors as A ON B.author_id = A.author_id 
    WHERE C.gender = 'M' AND T.type IN ('sell', 'lend');

SELECT C.name, C.birthdate, B.title, A.name,T.finished
FROM transactions as T 
    JOIN books as B ON T.book_id = B.book_id
    JOIN clients as C ON T.client_id = C.client_id 
    JOIN authors as A ON B.author_id = A.author_id 
    WHERE C.gender = 'M' AND C.birthdate > 2000-01-01;

SELECT C.name, month(C.birthdate) , B.title, A.name,T.type
FROM transactions as T 
    JOIN books as B ON T.book_id = B.book_id
    JOIN clients as C ON T.client_id = C.client_id 
    JOIN authors as A ON B.author_id = A.author_id 
    WHERE C.gender = 'M' AND month(C.birthdate) IN (03, 05 , 10);

-- se utiliza la tabla de autores como pivote y la libros como secundaria
SELECT a.author_id, a.name, a.nationality, b.title
FROM authors AS a
    JOIN books AS b 
    ON a.author_id = b.author_id
    WHERE a.author_id BETWEEN 1 and 5
    ORDER BY a.name desc;

-- Trae la tabla autores como pivote y la cruza con toda la tabla de libros o N numero de tablas dadas
SELECT a.author_id, a.name, a.nationality, b.title
FROM authors AS a
    LEFT JOIN books AS b 
    ON a.author_id = b.author_id
    WHERE a.author_id BETWEEN 1 and 5 
    ORDER BY a.author_id desc;

SELECT a.author_id, a.name, a.nationality, count(b.book_id)
FROM authors AS a
    LEFT JOIN books AS b 
    ON a.author_id = b.author_id
    WHERE a.author_id BETWEEN 1 and 5 
    GROUP BY a.author_id
    ORDER BY a.author_id;

SELECT a.author_id, a.name, a.nationality, count(b.book_id)
FROM authors AS a
    LEFT JOIN books AS b 
    ON a.author_id = b.author_id
    WHERE a.author_id BETWEEN 1 and 10 
    GROUP BY a.author_id
UNION
SELECT a.author_id, a.name, a.nationality, count(b.book_id)
FROM authors AS a
    RIGHT JOIN books AS b 
    ON a.author_id = b.author_id
    WHERE a.author_id BETWEEN 1 and 10 
    GROUP BY a.author_id
   

    
SELECT a.author_id, a.name, a.nationality,b.title 
FROM authors AS a
    LEFT JOIN books AS b 
    ON a.author_id = b.author_id
    WHERE a.author_id BETWEEN 1 and 5 
UNION 
SELECT a.author_id, a.name, a.nationality,b.title 
FROM authors AS a
    RIGHT JOIN books AS b
    ON a.author_id = b.author_id
    WHERE a.author_id BETWEEN 1 and 5;

-- ¿Que nacionalidades hay?
  SELECT nationality, count(*) FROM authors GROUP BY nationality ORDER BY count(*);
  SELECT DISTINCT nationality FROM authors;
-- ¿Cuántos escritores hay de cada nacionalidad?
    SELECT nationality, count(*) FROM authors GROUP BY nationality ORDER BY count(*);
   
    SELECT nationality, count(author_id) FROM authors 
    WHERE nationality IS NOT NULL AND nationality <> 'USA' --AND nationality NOT IN('USA') es otra forma
    GROUP BY nationality ORDER BY count(author_id) DESC, nationality ASC;
--¿Cuántos libros hay en cada nacionalidad?
    SELECT A.nationality, count(b.book_id) AS N_books
    FROM authors AS A
    LEFT JOIN books AS b ON A.author_id = b.author_id
    GROUP BY nationality ORDER BY N_books DESC;

-- ACTUALIZAR LOS PRECIOS NULL
    UPDATE books SET price = FLOOR(RAND()*(35-5+1)+5) WHERE price IS NULL;

-- ¿Cuál es el prom y desv estandar del precio de libros?
    SELECT AVG(price) AS PROM, STDDEV(price) AS DESVST
    FROM books;
-- ¿Cuál es el promedio y desviacion estandar del precio de libros segun la nacionalidad de los autores?
    SELECT nationality, 
    count(book_id) AS libros, AVG(price) AS PROM, STDDEV(price) AS DESVST
    FROM books
    JOIN authors ON books.author_id = authors.author_id
    GROUP BY nationality
    ORDER BY Libros DESC; 
-- ¿Cual es el precio maximo y mínimo de un libro?
    SELECT MAX(price), MIN(price)
    FROM books;

    SELECT nationality, MAX(price), MIN(price)
    FROM books
    JOIN authors ON books.author_id = authors.author_id
    GROUP BY nationality
    ORDER BY MAX(price) DESC, MIN(price) DESC; 

-- Reporte final de transacciones
SELECT C.name, b.title, A.name, T.type, T.created_at
FROM transactions AS T 
LEFT JOIN clients AS C ON C.client_id = T.client_id
LEFT JOIN books as b ON T.book_id = b.book_id
lEFT JOIN authors as A ON b.author_id = A.author_id;

SELECT C.name, T.type, b.title, 
CONCAT(A.name, '(', A.nationality,')') AS author, 
TO_DAYS(NOW()) - TO_DAYS(T.created_at()) AS ago
FROM transactions AS T 
LEFT JOIN clients AS C ON C.client_id = T.client_id
LEFT JOIN books as b ON T.book_id = b.book_id
lEFT JOIN authors as A ON b.author_id = A.author_id;

SELECT client_id, name FROM clients WHERE active <> 1; 
-- <> diferente
UPDATE clients SET active = 0
 WHERE client_id = 80 
  OR client_id = 8 LIMIT 2;

UPDATE clients SET active = 0 
 WHERE client_id IN(2, 5, 8, 28, 48) 
  OR name LIKE '%Lopez%';

UPDATE authors SET nationality = 'GBR'
WHERE nationality = 'ENG';

SELECT sum(price*copies) FROM books WHERE sellable =1;
SELECT sellable, sum(price*copies) FROM books GROUP BY sellable;

SELECT count(book_id), sum(if(cond, 1, false));
-- ¿Cuántos libros hay antes de 1950 y cuántos después?
SELECT count(book_id), 
sum(if(year < 1950, 1, 0)) AS '<1950', 
sum(if(year < 1950, 0, 1)) AS '>1950'  
FROM books;

SELECT count(book_id), 
sum(if(year < 1950, 1, 0)) AS '< 1950', 
sum(if(year >= 1950 and year < 1990, 1, 0)) AS '< 1990',
sum(if(year >= 1990 and year < 2000, 1, 0)) AS '< 2000',
sum(if(year >= 2000, 1, 0)) AS '< 2020'
FROM books;

-- Matrices y super querys
SELECT nationality, count(book_id), 
sum(if(year < 1950, 1, 0)) AS '< 1950', 
sum(if(year >= 1950 and year < 1990, 1, 0)) AS '< 1990',
sum(if(year >= 1990 and year < 2000, 1, 0)) AS '< 2000',
sum(if(year >= 2000, 1, 0)) AS '< 2020'
FROM books AS B 
JOIN authors AS A ON B.author_id = A.author_id
WHERE A.nationality IS NOT NULL
GROUP BY nationality
ORDER BY nationality ASC;

SELECT nationality, count(book_id), 
sum(if(language = 'es', 1, 0)) AS 'ES', 
sum(if(language = 'en', 1, 0)) AS 'EN',
sum(if(language <> 'en' and language <> 'es', 1, 0)) AS 'OTHER'
FROM books AS B 
JOIN authors AS A ON B.author_id = A.author_id
WHERE A.nationality IS NOT NULL
GROUP BY nationality
ORDER BY nationality ASC;


    
    
    

