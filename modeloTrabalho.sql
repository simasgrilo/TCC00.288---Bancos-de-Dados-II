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

DROP TABLE IF EXISTS ALUNOS_INSCRITOS CASCADE;

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
    id          serial,
    numero      int not null,           -- 217
    bloco       character(3) not null,  -- IC2
    capacidade  integer default 40,     -- 30
    UNIQUE (numero, bloco),
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
    id              serial,
    codigo_turma    character(2) not null,  -- A1
    professor       integer not null,       -- Luiz André
    oferta          integer not null,       -- 12312 
    UNIQUE (codigo_turma, professor, oferta),
    CONSTRAINT fk_professor FOREIGN KEY (professor) REFERENCES PROFESSORES(id),
    CONSTRAINT fk_oferta FOREIGN KEY (oferta) REFERENCES OFERTAS(id),
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
    turma   integer not null,
    UNIQUE (aluno, turma),
    CONSTRAINT fk_aluno FOREIGN KEY (aluno) REFERENCES ALUNOS (id),
    CONSTRAINT fk_turma FOREIGN KEY (turma) REFERENCES TURMAS (id),
    CONSTRAINT pk_inscricao PRIMARY KEY (id)
);


CREATE TABLE AULAS (
    id          serial,
    turma       integer not null,       -- 123
    sala        integer not null,       -- 567
    dia         character(3) not null,  -- SEG
    hora_inicio int not null,           -- 9
    hora_fim    int not null,           -- 11
    UNIQUE (turma, sala, dia, hora_inicio),
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
    disciplinaOfe integer;
BEGIN
    FOR i IN 1..maxValueCursos LOOP
        FOR j IN 1..round(random()*9 + 1) LOOP -- Cada curso pode oferecer até 10 disciplinas
            disciplinaOfe = round(random()*(maxValueDisciplinas + 1) + 1);
            IF EXISTS (SELECT * FROM DISCIPLINAS_OFERECIDAS AS DIO WHERE curso = i AND disciplina = disciplinaOfe) THEN
                RAISE NOTICE 'Esse curso já oferece essa disciplina';
            ELSE
                INSERT INTO DISCIPLINAS_OFERECIDAS(curso, disciplina) VALUES (i, disciplinaOfe);
            END IF;
        END LOOP;
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
            INSERT INTO SALAS(numero, bloco, capacidade) VALUES (numero, 'IC1', ((numero % 3) + 1) * 20);
            INSERT INTO SALAS(numero, bloco, capacidade) VALUES (numero, 'IC2', ((numero % 3) + 1) * 15);
        END LOOP;
    END LOOP;
END;$$ LANGUAGE plpgsql;

SELECT gera_salas();
SELECT * FROM SALAS;


-- OFERTAS
DROP FUNCTION IF EXISTS gera_ofertas();
CREATE OR REPLACE FUNCTION gera_ofertas() RETURNS void AS $$
DECLARE
    maxValueDisciplinasOferecidas integer = (SELECT COUNT(*) FROM DISCIPLINAS_OFERECIDAS); 
    anos integer[] = array[150, 160, 170, 180];
    semestre char(5);
    vagas integer;
BEGIN
    FOR ano IN 1..array_length(anos, 1) LOOP
        FOR sem IN 1..2 LOOP
            semestre = 20000 + anos[ano] + sem;
            FOR oferta IN 1..round(random()*(maxValueDisciplinasOferecidas - 1)+1) LOOP -- qtd de ofertas aleatórias para cada semestre
                vagas = ((oferta % 3) + 1) * 15;
                INSERT INTO OFERTAS(semestre, disciplina_oferecida, vagas) VALUES (semestre, oferta, vagas);
            END LOOP;
        END LOOP;
    END LOOP;
END;$$ LANGUAGE plpgsql;

SELECT gera_ofertas();
SELECT * FROM OFERTAS;


-- TURMAS
DROP FUNCTION IF EXISTS gera_turmas();
CREATE OR REPLACE FUNCTION gera_turmas() RETURNS void AS $$
DECLARE
    prof integer;
    oferta record;
    codigos char[] = array['A', 'B', 'C', 'D', 'E'];
    codigo char(2);
BEGIN
    FOR oferta IN SELECT * FROM OFERTAS LOOP
        FOR turma IN 1..round(random()*2 + 1) LOOP  -- De 1 à 3 turmas por OFERTA
            -- professor aleatório que possa lecionar a disciplina da oferta
            prof = (SELECT professor FROM DISCIPLINAS_LECIONAVEIS 
                    INNER JOIN DISCIPLINAS_OFERECIDAS AS DIO ON DIO.id = oferta.disciplina_oferecida
                    ORDER BY random() LIMIT 1);
            
            codigo = (codigos[turma]) || turma;     
            INSERT INTO TURMAS(codigo_turma, professor, oferta) VALUES (codigo, prof, oferta.id);
        END LOOP;
    END LOOP;
END;$$ LANGUAGE plpgsql;

SELECT gera_turmas();
SELECT * FROM TURMAS;


-- ALUNOS
DROP FUNCTION IF EXISTS gera_alunos();
CREATE OR REPLACE FUNCTION gera_alunos() RETURNS void AS $$
DECLARE
    maxValue integer = round(random()*(99 - 1)+1); -- de 1 à 100
    maxValueCursos integer = (SELECT COUNT(*) FROM CURSOS); 
    nome text;
    matricula bigint;
    curso integer;
    email text;
    telefone bigint;
BEGIN
    FOR i IN 1..maxValue LOOP
        nome = 'aluno-' || i;
        matricula = 214031000 + i;
        curso = round(random()*(maxValueCursos - 1)+1);
        email = 'aluno' || i || '@id.uff.br';
        telefone = 997880000 + i;
        INSERT INTO ALUNOS(matricula, curso, nome, email, telefone) VALUES (matricula, curso, nome, email, telefone);
    END LOOP;
END;$$ LANGUAGE plpgsql;

SELECT gera_alunos();
SELECT * FROM ALUNOS;


-- ALUNOS_INSCRITOS
DROP FUNCTION IF EXISTS gera_alunos_inscritos();
CREATE OR REPLACE FUNCTION gera_alunos_inscritos() RETURNS void AS $$
DECLARE
    maxValueAlunos integer = (SELECT COUNT(*) FROM ALUNOS);
    maxValueTurmas integer = (SELECT COUNT(*) FROM TURMAS);
    cursoAluno integer;
    tur integer;
BEGIN
    FOR alu IN 1..maxValueAlunos LOOP
        FOR i IN 1..round(random()*24+1) LOOP -- Se increve em até 6 turmas de diversos semestres (x 4 anos)
            cursoAluno = (SELECT curso FROM ALUNOS WHERE id=alu);

            -- Turma aleatória que o aluno possa se inscrever
            tur = (SELECT TURMAS.id FROM TURMAS
                    INNER JOIN OFERTAS AS OFE ON OFE.id = TURMAS.oferta
                    INNER JOIN DISCIPLINAS_OFERECIDAS AS DIO ON OFE.disciplina_oferecida = DIO.id
                    WHERE curso=cursoAluno
                    ORDER BY random() LIMIT 1);
                    
            IF tur IS NOT NULL THEN
                IF EXISTS (SELECT * FROM ALUNOS_INSCRITOS AS AI 
                           INNER JOIN TURMAS AS TU 
                           ON TU.id = AI.turma AND AI.aluno = alu AND AI.turma = tur) THEN
                    RAISE NOTICE 'Esse aluno já se inscreveu nessa turma nesse mesmo período';
                ELSE
                    INSERT INTO ALUNOS_INSCRITOS(aluno, turma) VALUES (alu, tur);
                END IF;
            ELSE
                RAISE NOTICE 'O curso do aluno não possui turmas';
            END IF;
        END LOOP;
    END LOOP;
END;$$ LANGUAGE plpgsql;

SELECT gera_alunos_inscritos();
SELECT * FROM ALUNOS_INSCRITOS;


-- Todas as turmas de um semestre
-- SELECT * FROM TURMAS INNER JOIN OFERTAS ON OFERTAS.id = TURMAS.oferta WHERE OFERTAS.semestre='20151';

-- AULAS
DROP FUNCTION IF EXISTS gera_aulas();
CREATE OR REPLACE FUNCTION gera_aulas() RETURNS void AS $$
DECLARE
    tur record;
    dias char(3)[] = array['SEG', 'TER', 'QUA', 'QUI', 'SEX'];
    di char(3);
    hi integer;
    hf integer;
    sal integer;
BEGIN
    FOR tur IN (SELECT * FROM TURMAS) LOOP
        FOR aulas IN 1..round(random()*1 + 1) LOOP  -- De 1 à 2 aulas por TURMA     
            di = dias[round(random()*4 + 1)];       -- de SEG à SEX
            hi = random()*13 + 7;                   -- valor aleatorio de 7h à 20h
            hf = hi + 2;                            -- Hora de início + 2h
            
            IF EXISTS (SELECT * FROM AULAS
                       INNER JOIN TURMAS ON TURMAS.id = AULAS.turma
                       WHERE turma = tur.id AND dia = di AND @(hora_inicio - hi) < 2) THEN
                RAISE NOTICE 'Esse professor já leciona nesse dia e horário';
            ELSE
                sal = (SELECT SALAS.id FROM SALAS
                        FULL JOIN AULAS ON SALAS.id = AULAS.sala
                        INNER JOIN OFERTAS ON OFERTAS.id = tur.oferta
                        WHERE capacidade >= alunos_inscritos AND hora_inicio IS NULL OR @(hora_inicio - hi) > 1
                        ORDER BY random() LIMIT 1);
                
                IF sal IS NOT NULL THEN
                    INSERT INTO AULAS (turma, sala, dia, hora_inicio, hora_fim) VALUES (tur.id, sal, di, hi, hf);
                ELSE
                    RAISE NOTICE 'Não há sala disponível nesse horário que comporte essa aula'; 
                END IF;
            END IF;
        END LOOP;   
    END LOOP;
END;$$ LANGUAGE plpgsql;

SELECT gera_aulas();
SELECT * FROM AULAS;


-------------------------------------- TRIGGERS --------------------------------------------------------------

--Um professor não pode ser coordenador e vice_coordenador ao mesmo tempo. Além disso, um professor não pode coordenar mais de um curso ou nem ser vice de mais de um curso ao mesmo tempo.                      
create or replace function professor_coordenador_nao_pode_ser_vice() returns trigger as $$
begin
  if (new.professor_coordenador = new.vice_coordenador) then
            raise exception 'O professor coordenador não pode ser o mesmo que o vice!';
            return null;
  elseif exists (select professor_coordenador from cursos
             where professor_coordenador = new.professor_coordenador)
             or 
     exists (select vice_coordenador from cursos
             where vice_coordenador = new.vice_coordenador)
             or
     exists (select vice_coordenador from cursos
             where professor_coordenador = new.professor_coordenador)
            or
     exists (select professor_coordenador from cursos
             where professor_coordenador = new.vice_coordenador) then
            raise exception 'Este professor já coordena um curso ou é vice coordenador de um curso';
            return null;
  end if;
  return new;
end;
$$ language plpgsql; 


create trigger prof_coordenador_nao_pode_ser_vice before insert or update
       on cursos
       for each row
       execute procedure professor_coordenador_nao_pode_ser_vice(); --ok

--Uma sala não pode ter duas aulas no mesmo horário:       
create or replace function sala_duas_aulas_simultaneamente() returns trigger as $$
begin
    if exists (select * from aulas
               where dia = new.dia 
                     and hora_inicio = new.hora_inicio
                     and hora_fim    = new.hora_fim
                     and sala        = new.sala) then
               raise exception 'A sala em questão já está sendo usada para outra disciplina no mesmo horário';
               return NULL;
     end if;
     return new;
end;
$$ language plpgsql;

create trigger sala_duas_aulas_mesmo_horario before insert or update
       on aulas
       for each row
       execute procedure sala_duas_aulas_simultaneamente();--ok


-- Um professor não pode ter duas turmas no mesmo horário
create or replace function prof_nao_tem_duas_turmas_mesmo_horario() returns trigger as $$
begin
  if (select count(*) from aulas left outer join turmas
                           on aulas.turma = turmas.id
                           inner join professores
                           on turma.professor = professores.id
             group by hora_inicio,hora_fim,dia) > 1 then
             raise exception 'O professor já possui uma aula neste mesmo horário';
   end if;
   return NULL;
end;
$$ language plpgsql;

--Um professor não pode ter duas turmas no mesmo horário:
--create trigger prof_duas_turmas_mesmo_horario before insert or update
--      on cursos
--       for each row
--       execute procedure prof_nao_tem_duas_turmas_mesmo_horario()

--Um aluno não pode ter duas disciplinas iguais no mesmo semestre (não pode estar cursando a mesma oferta da disciplina duas vezes no mesmo semestre)
-- tá escaralhado
create or replace function aluno_nao_duas_disc_mesmo_sem() returns trigger as $$
begin
    IF EXISTS (SELECT * FROM ALUNOS_INSCRITOS AS AI 
                       INNER JOIN TURMAS AS TU 
                       ON TU.id = AI.turma AND AI.aluno = new.aluno AND AI.turma = new.turma) THEN
              raise exception 'Um aluno não pode cursar a mesma disciplina duas vezes no mesmo semestre!';
              return NULL;
    end if;
    return new;
end;
$$ language plpgsql;

create trigger aluno_sem_disc_iguais_mesmo_sem before insert or update
       on alunos_inscritos
       for each row
       execute procedure aluno_nao_duas_disc_mesmo_sem(); --ok
       
--Uma oferta de disciplina não pode conter mais do que o número máximo permitido de alunos inscritos.
create or replace function alunos_inscritos_na_turma() returns trigger as $$
begin
     if ((select vagas from ofertas where id = new.id) < (select alunos_inscritos from ofertas where id = new.id))
        or (select vagas from ofertas where id = new.id) < new.alunos_inscritos or
            (select alunos_inscritos from ofertas where id = new.id) > new.vagas 
                then
         raise exception 'A quantidade de alunos inscritos ultrapassa a quantidade de vagas na turma';
         return NULL; 
     end if;
    return new;
end;
$$ language plpgsql; --PROCEDURE ok

create trigger qte_alunos_inscritos_turma before insert or update
       on ofertas
       for each row
       execute procedure alunos_inscritos_na_turma(); --ok

--PROCEDURE 1: ao inserir um aluno em uma oferta de uma disciplina, adicionar em um o número de alunos inscritos naquela oferta. 
DROP FUNCTION inscreve_aluno(integer,integer);
create or replace function inscreve_aluno(alunoIn integer, turmaIn integer) returns void as $$
begin
  insert into alunos_inscritos(aluno, turma)
  values (alunoIn,turmaIn);
  update ofertas 
  set alunos_inscritos = alunos_inscritos + 1
  where ofertas.id = (select ofertas.id from ofertas where ofertas.id = (select turmas.oferta from turmas where id = turmaIn));
end;
$$ language plpgsql;

--Um professor só pode lecionar uma turma à qual ele tenha licença para lecionar:
create or replace function professor_da_aula_de() returns trigger as $$
begin
   if not exists (select disciplinas_lecionaveis.professor,disciplinas_lecionaveis.disciplina --acho que nem precisa desse join todo.
                        from (disciplinas_lecionaveis full outer join
                        ofertas on (ofertas.disciplina_oferecida = disciplinas_lecionaveis.disciplina)
                        full outer join turmas on (ofertas.id = new.oferta))   
                        where disciplinas_lecionaveis.professor = new.professor and disciplinas_lecionaveis.disciplina = 
                                             (select disciplina_oferecida from ofertas where ofertas.id = new.oferta)) then
                        raise exception 'O professor não pode lecionar a disciplina em questão!';
                        return null;
    end if;
    return new;           
end;
$$ language plpgsql;

create trigger professor_so_pode_dar_aula_do_que_ele_pode_dar_aula before insert or update --esse nome foi de zoas mesmo
       on turmas
       for each row
       execute procedure professor_da_aula_de(); --ok

