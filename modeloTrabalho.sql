------------------------------------------------ DROPS --------------------------------------------------------------
DROP TABLE IF EXISTS CURSOS CASCADE;

DROP TABLE IF EXISTS DISCIPLINAS CASCADE;

DROP TABLE IF EXISTS DISCIPLINAS_OFERECIDAS CASCADE;

DROP TABLE IF EXISTS PROFESSORES CASCADE;

DROP TABLE IF EXISTS DISCIPLINAS_LECIONAVEIS CASCADE;

DROP TABLE IF EXISTS ALUNOS cascade;

DROP TABLE IF EXISTS ALUNOS_INSCRITOS cascade;

DROP TABLE IF EXISTS TURMAS CASCADE;

DROP TABLE IF EXISTS AULAS CASCADE;

DROP TABLE IF EXISTS OFERTAS CASCADE;

DROP TABLE IF EXISTS SALAS CASCADE;

-------------------------------------- RELACIONAMENTOS --------------------------------------------------------------
CREATE TABLE DISCIPLINAS (
    id              serial,                             -- 1
    cod_disciplina  char(8) not null unique,            -- TCC00286
    nome            varchar(100) not null,              -- Banco de Dados 2
    ementa          varchar(100) not null,              -- Aprende a criar triggers e procedures
    carga_horaria   integer not null,                   -- 40
    CONSTRAINT pk_disciplina PRIMARY KEY (id)
);


CREATE TABLE PROFESSORES (
    id          serial,
    matricula   bigint not null unique,         -- 1231312312
    nome        varchar(100) not null,          -- Luiz André
    email       varchar(100) not null unique,   -- luiz@andre
    CONSTRAINT pk_professor PRIMARY KEY(id)
);


CREATE TABLE DISCIPLINAS_LECIONAVEIS (
    id          serial,
    professor   integer not null,
    disciplina  integer not null,
    UNIQUE (professor, disciplina),
    CONSTRAINT pk_lecionavel PRIMARY KEY (id)
);


CREATE TABLE CURSOS (
    id                      serial,                     -- 1
    nome                    varchar(100) not null,      -- Ciência da Computação
    professor_coordenador   bigint not null unique,     -- Ro7
    vice_coordenador        bigint not null unique,     -- Aline
    CONSTRAINT pk_curso PRIMARY KEY(id),
    CONSTRAINT fk_coordenador FOREIGN KEY (professor_coordenador) REFERENCES PROFESSORES(id),
    CONSTRAINT fk_vice FOREIGN KEY (vice_coordenador) REFERENCES PROFESSORES(id)
);


CREATE TABLE DISCIPLINAS_OFERECIDAS (
    id          serial,
    curso       integer not null,   -- 214
    disciplina  integer not null,   -- 123
    UNIQUE (curso, disciplina),
    CONSTRAINT pk_discip_oferecida PRIMARY KEY (id)
);


CREATE TABLE SALAS (
    id      serial,
    numero  int not null,           -- 217
    bloco   character(3) not null,  -- IC2
    UNIQUE (numero, bloco),         -- Não pode ter igual
    CONSTRAINT pk_sala PRIMARY KEY(id)
);


CREATE TABLE OFERTAS (
    id                      serial,
    semestre                character(5) not null,          -- 2018.1
    disciplina_oferecida    integer not null,               -- 123
    vagas                   integer not null default 30,    -- 30
    alunos_inscritos        integer not null default 0,     -- 20
    UNIQUE(semestre, disciplina_oferecida),
    CONSTRAINT fk_disciplina_oferecida FOREIGN KEY (disciplina_oferecida) REFERENCES DISCIPLINAS_OFERECIDAS(id),
    CONSTRAINT pk_oferta PRIMARY KEY (id)
);


CREATE TABLE TURMAS (
    id              serial,                 -- 1
    codigo_turma    character(2) not null,  -- A1
    professor       integer not null,       -- Luiz André
    oferta          integer not null,       -- 12312 
    UNIQUE (codigo_turma, professor, oferta),
    CONSTRAINT fk_professor foreign key (professor) references PROFESSORES(id),
    CONSTRAINT fk_oferta foreign key (oferta) references OFERTAS(id),
    CONSTRAINT pk_turma PRIMARY KEY (id)
);


CREATE TABLE ALUNOS (
    id          serial,
    matricula   bigint not null unique,     -- 214031126
    curso       integer not null,           -- 214
    nome        varchar(50) not null,       -- Batman
    email       varchar(50) not null,       -- batman@id.uff.br
    telefone    varchar(9) not null,        -- 99999999
    CONSTRAINT pk_aluno PRIMARY KEY (id)
);


CREATE TABLE ALUNOS_INSCRITOS (
    id      serial,
    aluno   integer not null,
    oferta  integer not null,
    UNIQUE (aluno, oferta),
    CONSTRAINT fk_aluno FOREIGN KEY (aluno) REFERENCES ALUNOS (id),
    CONSTRAINT fk_oferta FOREIGN KEY (oferta) REFERENCES OFERTAS (id),
    CONSTRAINT pk_inscricao PRIMARY KEY (id)
);


CREATE TABLE AULAS (
    id          serial,
    turma       integer not null,       -- 123
    dia         character(3) not null,  -- SEG
    hora_inicio timestamp not null,     -- 9:00
    hora_fim    timestamp not null,     -- 11:00
    sala        integer not null,
    CONSTRAINT fk_turma FOREIGN KEY (turma) REFERENCES TURMAS(id),
    CONSTRAINT fk_sala FOREIGN KEY (sala) REFERENCES SALAS(id),
    CONSTRAINT pk_aula PRIMARY KEY (id)
);



--------------------------------------- DUMMY DATA INSERTS ---------------------------------------------------------
-- DISCIPLINAS
DROP FUNCTION IF EXISTS gera_disciplinas();
CREATE OR REPLACE FUNCTION gera_disciplinas() RETURNS void AS $$
DECLARE
    maxValue integer = round(random()*(100 + 5)); -- Entre 5 e 100
    codigo text;
    nome text;
    ementa text;
    cargaHoraria integer;
BEGIN
    FOR i IN 1..maxValue LOOP
        codigo = 'TCC00' || i;
        nome = 'disciplina-' || i;
        ementa = 'Aprendizado em ' || i || ' e ' || i * 2;
        cargaHoraria = ((i % 2) + 1) * 32;
        INSERT INTO DISCIPLINAS(cod_disciplina, nome, ementa, carga_horaria) VALUES (codigo, nome, ementa, cargaHoraria);
    END LOOP;
END;$$ LANGUAGE plpgsql;

SELECT gera_disciplinas();
SELECT * FROM DISCIPLINAS;


-- PROFESSORES
DROP FUNCTION IF EXISTS gera_professores();
CREATE OR REPLACE FUNCTION gera_professores() RETURNS void AS $$
DECLARE
    maxValue integer = round(random()*(100 + 5)); -- Entre 5 e 100
    nmProfessor text;
    emailProfessor text;
BEGIN
    FOR i IN 1..maxValue LOOP
        nmProfessor = 'professor-' || i;
        emailProfessor = 'professor-' || i || '@id.uff.br';
        INSERT INTO PROFESSORES(matricula, nome, email) VALUES (2018000 + i, nmProfessor, emailProfessor);
    END LOOP;
END;$$ LANGUAGE plpgsql;

SELECT gera_professores();
SELECT * FROM PROFESSORES;


-- DISCIPLINAS_LECIONAVEIS
DROP FUNCTION IF EXISTS gera_disciplinas_lecionaveis();
CREATE OR REPLACE FUNCTION gera_disciplinas_lecionaveis() RETURNS void AS $$
DECLARE
    maxValueProfessores integer = (SELECT COUNT(*) FROM PROFESSORES);
    maxValueDisciplinas integer = (SELECT COUNT(*) FROM DISCIPLINAS);
BEGIN
    FOR i IN 1..maxValueProfessores LOOP
        INSERT INTO DISCIPLINAS_LECIONAVEIS(professor, disciplina) VALUES (i, round(random()*(maxValueDisciplinas + 1) + 1));
    END LOOP;
END;$$ LANGUAGE plpgsql;
SELECT gera_disciplinas_lecionaveis();
SELECT * FROM DISCIPLINAS_LECIONAVEIS;


-- CURSOS                            
DROP FUNCTION IF EXISTS gera_cursos();
CREATE OR REPLACE FUNCTION gera_cursos() RETURNS void AS $$
DECLARE
    maxValue integer = (SELECT COUNT(*) FROM PROFESSORES) / 2;
    curso text;
BEGIN
    FOR i IN 1..maxValue LOOP
        curso = 'curso-' || i;
        INSERT INTO CURSOS(nome, professor_coordenador, vice_coordenador) VALUES (curso, i, (maxValue * 2) - i);
    END LOOP;
END;$$ LANGUAGE plpgsql;

SELECT gera_cursos();
SELECT * FROM CURSOS;


-- DISCIPLINAS_OFERECIDAS
DROP FUNCTION IF EXISTS gera_disciplinas_oferecidas();
CREATE OR REPLACE FUNCTION gera_disciplinas_oferecidas() RETURNS void AS $$
DECLARE
    maxValueCursos integer = (SELECT COUNT(*) FROM CURSOS);
    maxValueDisciplinas integer = (SELECT COUNT(*) FROM DISCIPLINAS);
BEGIN
    FOR i IN 1..maxValueCursos LOOP
        INSERT INTO DISCIPLINAS_OFERECIDAS(curso, disciplina) VALUES (i, round(random()*(maxValueDisciplinas + 1) + 1));
    END LOOP;
END;$$ LANGUAGE plpgsql;
SELECT gera_disciplinas_oferecidas();
SELECT * FROM DISCIPLINAS_OFERECIDAS;


-- SALAS                             
DROP FUNCTION IF EXISTS gera_salas();
CREATE OR REPLACE FUNCTION gera_salas() RETURNS void AS $$
DECLARE
    numero integer;
    salas integer[] = array[0, 2, 4, 6, 8, 10, 11, 13, 15, 17, 19];
BEGIN
    FOR andar IN 2..3 LOOP
        FOR num IN 1..array_length(salas, 1) LOOP
            numero = (100 * andar) + salas[num];
            INSERT INTO SALAS(numero, bloco) VALUES (numero, 'IC1');
            INSERT INTO SALAS(numero, bloco) VALUES (numero, 'IC2');
        END LOOP;
    END LOOP;
END;$$ LANGUAGE plpgsql;

SELECT gera_salas();
SELECT * FROM SALAS;

/*
-- TURMAS
DROP FUNCTION IF EXISTS gera_turmas();
CREATE OR REPLACE FUNCTION gera_turmas() RETURNS void AS $$
DECLARE
    maxValueProfessores integer = (SELECT COUNT(*) FROM PROFESSORES); 
    professor integer;
    codigos char[] = '{A, B, C, D, E}';
    d record;
    codigo char(2);
BEGIN
    FOR d IN SELECT * FROM DISCIPLINAS_OFERECIDAS LOOP
        FOR i IN 1..round(random()*4 + 1) LOOP -- De 1 à 5 turmas por disciplina
            professor = round(random()*(maxValueProfessores - 1)+1);
            codigo = (codigos[i]) || i;
            INSERT INTO TURMAS(codigo_turma, professor, oferta) VALUES (codigo, professor, oferta);
        END LOOP;
    END LOOP;
END;$$ LANGUAGE plpgsql;

SELECT gera_turmas();
SELECT * FROM TURMAS;

-- OFERTAS
semestre        
disciplina      
turma           
vagas           
alunos_inscritos
DROP FUNCTION IF EXISTS gera_ofertas();
CREATE OR REPLACE FUNCTION gera_ofertas() RETURNS void AS $$
DECLARE
    maxValueProfessores integer = (SELECT COUNT(*) FROM PROFESSORES); 
    professor integer;
    codigos char[] = '{A, B, C, D, E}';
    d record;
    codigo char(2);
BEGIN
    FOR d IN SELECT * FROM DISCIPLINAS_OFERECIDAS LOOP
        FOR i IN 1..round(random()*4 + 1) LOOP -- De 1 à 5 turmas por disciplina
            professor = round(random()*(maxValueProfessores - 1)+1);
            codigo = (codigos[i]) || i;
            INSERT INTO TURMAS(codigo_turma, professor, disciplina) VALUES (codigo, professor, d.disciplina);
        END LOOP;
    END LOOP;
END;$$ LANGUAGE plpgsql;

SELECT gera_ofertas();
SELECT * FROM OFERTAS;

*/
-------------------------------------- TRIGGERS --------------------------------------------------------------

--A ideia do trigger abaixo é catar se o professor possui mais de duas turmas em um mesmo horário
--create or replace function professor_possui_duas_aulas_mesmo_horário returns trigger as $$
--begin
--  IF (select count(*) from professor 
--                      ( inner join leciona_em where professor.matricula = leciona_em.matricula_professor
--                      inner join turma where turma.codigo_turma = leciona_em.codigo_turma
--                      inner join aula  where aula.turma = leciona_em.codigo_turma )
--                      group by  
                      
create or replace function professor_coordenador_nao_pode_ser_vice() returns trigger as $$
begin
  if (select professor_coordenador from professor 
       inner join curso on professor.matricula = curso.coordenador) == 
     (select vice_coordenador from professor 
        inner join curso on professor.matricula = curso.vice_coordenador) then
      raise exception 'O professor coordenador não pode ser vice coordenador de um curso!';
  end if;
  return old;
end;
$$ language plpgsql; --falta criar o trigger correspondente