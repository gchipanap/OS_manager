DROP DATABASE IF EXISTS task;
CREATE DATABASE task;
USE task; 

CREATE TABLE person (
    dni INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20)
);

CREATE TABLE client (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_person INT NOT NULL,
    FOREIGN KEY (id_person) REFERENCES person(dni)
);

CREATE TABLE workshop (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255)
);

CREATE TABLE workshop_machines (
	id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    keyword VARCHAR(50) NOT NULL,
    description TEXT,
	id_workshop INT,
	FOREIGN KEY (id_workshop) REFERENCES workshop(id)
);

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
	email VARCHAR(100) NOT NULL,
    id_person INT NOT NULL,
    role ENUM('Administrativo', 'Tecnico') NOT NULL,
    id_workshop INT NOT NULL,
    FOREIGN KEY (id_workshop) REFERENCES workshop(id),
    FOREIGN KEY (id_person) REFERENCES person(dni)
);

CREATE TABLE tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo ENUM('D', 'A') NOT NULL,
    state ENUM('To-do', 'Finished') NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_finalizacion DATETIME
);

CREATE TABLE task_test (
    id INT AUTO_INCREMENT,
    id_task INT,
    fecha DATE NOT NULL,
    description VARCHAR(255),
    PRIMARY KEY (id, id_task),
    FOREIGN KEY (id_task) REFERENCES tasks(id)
);

CREATE TABLE task_resources (
    id INT AUTO_INCREMENT,
    id_task INT,
    id_machine INT,
    id_user INT,
    PRIMARY KEY (id, id_task),
    FOREIGN KEY (id_task) REFERENCES tasks(id),
    FOREIGN KEY (id_machine) REFERENCES workshop_machines(id),
    FOREIGN KEY (id_user) REFERENCES users(id)
);

CREATE TABLE AST (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_os INT NOT NULL, 
    id_user_tecnico INT,
    state BOOLEAN NOT NULL,  -- 1 = aprobado ,0 = no aprobado
    FOREIGN KEY (id_user_tecnico) REFERENCES users(id)
);

CREATE TABLE os (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_AST INT,
    state ENUM('To-do', 'In-process', 'finished') NOT NULL, -- To do, in process, finished
    id_task_desarme INT,
    id_task_armado INT,
    fecha_inicio DATETIME NOT NULL,
    fecha_finalizacion DATETIME,
    FOREIGN KEY (id_AST) REFERENCES AST(id),
    FOREIGN KEY (id_task_desarme) REFERENCES tasks(id),
    FOREIGN KEY (id_task_armado) REFERENCES tasks(id)
);

CREATE TABLE component (
    id INT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(255) NOT NULL
);

CREATE TABLE workshop_jobs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_workshop INT NOT NULL,
    id_client INT NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME,
    id_user_admin INT NOT NULL,    
    id_component INT,
    id_os INT,
    id_price INT,
    FOREIGN KEY (id_workshop) REFERENCES workshop(id),
    FOREIGN KEY (id_client) REFERENCES client(id),
    FOREIGN KEY (id_user_admin) REFERENCES users(id),
    FOREIGN KEY (id_os) REFERENCES os(id), 
    FOREIGN KEY (id_component) REFERENCES component(id)
);

CREATE TABLE lista_motivos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    planificada BOOLEAN, -- 1 planificada, 0 no planificada
    motivo VARCHAR(255) UNIQUE NOT NULL
);

CREATE TABLE paradas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_os INT NOT NULL,
    fecha_inicio_parada DATETIME NOT NULL,
    fecha_fin_parada DATETIME,
    motivo_id INT,
    FOREIGN KEY (id_os) REFERENCES os(id),
    FOREIGN KEY (motivo_id) REFERENCES lista_motivos(id)
);


-- Insertar cliente
INSERT INTO person (dni, name, phone) VALUES (12345678, 'Nombre Cliente', '123456789');
INSERT INTO client (id_person) VALUES (12345678);

-- Insertar taller
INSERT INTO workshop (name, location) VALUES ('Taller 1', 'Ubicación Taller 1');

-- Insertar técnicos (usuarios)
INSERT INTO person (dni, name, phone) VALUES (23456789, 'Nombre Técnico', '987654321');
INSERT INTO users (email, id_person, role, id_workshop) VALUES ('tecnico@example.com', 23456789, 'Tecnico', 1);

-- Insertar administrativo (usuario)
INSERT INTO person (dni, name, phone) VALUES (34567890, 'Nombre Administrativo', '567891234');
INSERT INTO users (email, id_person, role, id_workshop) VALUES ('admin@example.com', 34567890, 'Administrativo', 1);

-- Insertar máquinas para el taller
INSERT INTO workshop_machines (name, keyword, description, id_workshop) VALUES 
('Máquina 1', 'Keyword 1', 'Descripción Máquina 1', 1),
('Máquina 2', 'Keyword 2', 'Descripción Máquina 2', 1);


-- Insertar workshop job
INSERT INTO workshop_jobs (id_workshop, id_client, fecha_inicio, id_user_admin) VALUES (1, 1, NOW(), 2);

-- Insertar AST con estado aprobado
INSERT INTO AST (id_os, id_user_tecnico, state) VALUES (1, 2, 1);

-- Insertar OS para el workshop job
INSERT INTO os (id_AST, state, fecha_inicio) VALUES (1, 'To-do', NOW());
INSERT INTO os (id_AST, state, fecha_inicio) VALUES (1, 'To-do', NOW());

-- Insertar tareas D y A para las OS
INSERT INTO tasks (tipo, state, fecha_inicio) VALUES ('D', 'To-do', NOW());
INSERT INTO tasks (tipo, state, fecha_inicio) VALUES ('A', 'To-do', NOW());

-- Insertar pruebas para la tarea D
INSERT INTO task_test (id_task, fecha, description) VALUES (1, NOW(), 'Descripción Prueba 1');
INSERT INTO task_test (id_task, fecha, description) VALUES (1, NOW(), 'Descripción Prueba 2');



-- Insertar motivos de parada no planeados
INSERT INTO lista_motivos (planificada, motivo) VALUES (0, 'Por Priorización');
INSERT INTO lista_motivos (planificada, motivo) VALUES (0, 'Falta de Base');
INSERT INTO lista_motivos (planificada, motivo) VALUES (0, 'Máquina no Disponible');

-- Insertar motivos de parada planeados
INSERT INTO lista_motivos (planificada, motivo) VALUES (1, 'Inspección Ultrasonido');
INSERT INTO lista_motivos (planificada, motivo) VALUES (1, 'Prueba de Flexión MS');
INSERT INTO lista_motivos (planificada, motivo) VALUES (1, 'Extracción de Machón');


