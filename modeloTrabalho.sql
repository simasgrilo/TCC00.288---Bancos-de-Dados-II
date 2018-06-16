-------------------------------------- DROPS --------------------------------------------------------------
DROP TABLE IF EXISTS CURSOS CASCADE;

DROP TABLE IF EXISTS DISCIPLINAS CASCADE;

DROP TABLE IF EXISTS DISCIPLINAS_OFERECIDAS CASCADE;

DROP TABLE IF EXISTS PROFESSORES CASCADE;

DROP TABLE IF EXISTS DISCIPLINAS_LECIONAVEIS CASCADE;

DROP TABLE IF EXISTS ALUNOS cascade;

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
    id  serial,
    professor integer not null,
    disciplina integer not null,
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


CREATE TABLE TURMAS (
    id              serial,                 -- 1
    codigo_turma    character(2) not null,  -- A1
    professor       integer not null,       -- Luiz André
    disciplina      integer not null,       -- 12312 
    UNIQUE (codigo_turma, professor, disciplina),
    CONSTRAINT fk_professor foreign key (professor) references PROFESSORES(id),
    CONSTRAINT fk_disciplina foreign key (disciplina) references DISCIPLINAS(id),
    CONSTRAINT pk_turma PRIMARY KEY (id)
);


CREATE TABLE OFERTAS (
    id                  serial,
    semestre            character(5) not null,          -- 2018.1
    disciplina          integer not null,               -- 123
    turma               integer not null,               -- 1234
    vagas               integer not null default 30,    -- 30
    alunos_inscritos    integer not null default 0,     -- 20
    UNIQUE(semestre, disciplina, turma),
    CONSTRAINT fk_turma FOREIGN KEY (turma) REFERENCES TURMAS(id),
    CONSTRAINT fk_disciplina FOREIGN KEY (disciplina) REFERENCES DISCIPLINAS(id),
    CONSTRAINT pk_oferta PRIMARY KEY (id)
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
    id  serial,
    aluno   integer not null,
    oferta  integer not null,
    UNIQUE (aluno, oferta),
    CONSTRAINT pk_inscricao PRIMARY KEY (id),
    CONSTRAINT fk_alunos FOREIGN KEY (aluno) REFERENCES ALUNOS(id),
    CONSTRAINT fk_ofertas FOREIGN KEY (oferta) REFERENCES OFERTAS(id)
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


-------------------------------------- TRIGGERS --------------------------------------------------------------

--A ideia do trigger abaixo é catar se o professor possui mais de duas turmas em um mesmo horário
--create or replace function professor_possui_duas_aulas_mesmo_horário returns trigger as $$
--begin
--  IF (select count(*) from professor 
--                      ( inner join leciona_em where professor.matricula = leciona_em.matricula_professor
--                      inner join turma where turma.codigo_turma = leciona_em.codigo_turma
--                      inner join aula  where aula.turma = leciona_em.codigo_turma )
--                      group by  

--Um professor não pode ser coordenador e vice_coordenador ao mesmo tempo                      
create or replace function professor_coordenador_nao_pode_ser_vice() returns trigger as $$
begin
  if ((select professor_coordenador from professores 
       inner join cursos on professores.matricula = cursos.professor_coordenador) == 
     (select vice_coordenador from professores 
        inner join cursos on professores.matricula = cursos.vice_coordenador) 
        or
        (select vice_coordenador from professores 
       inner join cursos on professores.matricula = cursos.vice_coordenador) == 
     (select vice_coordenador from professores 
        inner join cursos on professores.matricula = cursos.professor_coordenador)) then
      raise exception 'O professor coordenador não pode ser o mesmo que o vice!';
  end if;
  return null;
end;
$$ language plpgsql; --falta criar o trigger correspondente

create trigger prof_coordenador_nao_pode_ser_vice before insert or update
       on cursos
       for each row
       execute procedure professor_coordenador_nao_pode_ser_vice();

--Uma sala não pode ter duas aulas ao mesmo tempo de professores diferentes (porém se for o mesmo professor, as disciplinas têm que ser equivalentes).
--create or replace function sala_duas_aulas_simultaneamente() returns trigger as $$
--begin
-- if (select * from aulas (inner join turmas on aulas.turma = turmas.id
--                          (inner join professor on turmas.professor = professor.id)
--                           )

-- Um professor não pode ter duas turmas no mesmo horário

create or replace function prof_nao_tem_duas_turmas_mesmo_horario() returns trigger as $$
begin
  if (select count(*) from aulas inner join turmas
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

create or replace function aluno_nao_duas_disc_mesmo_sem() returns trigger as $$
begin
   if (select count(*) from alunos_inscritos inner join ofertas
                     on alunos_inscritos.oferta == ofertas.id
                     inner join turmas
                     on ofertas.turma == turmas.id
              group by semestre,disciplina) > 1 then
              raise exception 'Um aluno não pode cursar a mesma disciplina duas vezes no mesmo semestre!';
    end if;
    return NULL;
end;
$$ language plpgsql;

create trigger aluno_sem_disc_iguais_mesmo_sem before insert or update
       on alunos_inscritos
       for each row
       execute procedure aluno_nao_duas_disc_mesmo_sem();

 