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
    semestre            character(5) not null,
    disciplina          integer not null,
    turma               integer not null,
    vagas               integer not null default 30,
    alunos_inscritos    integer not null default 0,
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


-- Semestre nas duas tabelas?
-- Como garantir a inscrição de um aluno ou não de outro?
-- Talvez remover INSCRIÇÕES e SOLICITAÇÕES por conta do histórico do aluno e CR. Como calcular?
/* 
CREATE TABLE inscricoes (
    id                  SERIAL,
    semestre            character(5) not null,  -- 2018.1
    matricula_aluno     bigint not null,        -- 2140131126
    codigo_turma        integer not null,       -- 1 
    unique (semestre, matricula_aluno, codigo_turma),
    constraint fk_aluno foreign key (matricula_aluno) references aluno(matricula),
    constraint fk_turma foreign key (codigo_turma) references turma(id),
    constraint pk_inscricoes primary key (id)
);

CREATE TABLE leciona_em(
    id          SERIAL,
    professor   integer not null,       -- 1
    turma       integer not null,       -- 1
    semestre    character(5) not null,  -- 2018.1
    unique (professor, turma, semestre),
    constraint fk_professor foreign key (professor) references professor(id),
    constraint fk_professor_turma foreign key (turma) references turma(id), 
    constraint pk_leciona_em primary key (id)
);
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