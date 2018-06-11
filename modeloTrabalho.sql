-------------------------------------- DROPS --------------------------------------------------------------

DROP TABLE IF EXISTS professor CASCADE;

DROP TABLE IF EXISTS sala CASCADE;

DROP TABLE IF EXISTS disciplina CASCADE;

DROP TABLE IF EXISTS turma CASCADE;

DROP TABLE IF EXISTS aula CASCADE;

DROP TABLE IF EXISTS curso cascade;

DROP TABLE IF EXISTS aluno cascade;

DROP TABLE IF EXISTS inscricoes cascade;

DROP TABLE IF EXISTS leciona_em cascade;

-------------------------------------- RELACIONAMENTOS --------------------------------------------------------------

CREATE TABLE professor (
	id 			SERIAL,
    matricula 	bigint not null, 		-- 1231312312
    nome 		varchar(100) not null, 	-- Luiz André
    email 		varchar(100) not null, 	-- luiz@andre
    CONSTRAINT pk_professor PRIMARY KEY(id)
);

CREATE TABLE curso (
	id 						SERIAL, 					-- 1
    nome  					character varying not null, -- Ciência da Computação
    professor_coordenador 	bigint not null unique, 	-- Ro7
    vice_coordenador  		bigint not null unique, 	-- Aline
    constraint pk_curso PRIMARY KEY(id),
    constraint fk_coordenador foreign key (professor_coordenador) references professor(id),
    constraint fk_vice foreign key (vice_coordenador) references professor(id)
);

CREATE TABLE sala(
	id		SERIAL,
    numero 	int not null, 			-- 217
    bloco 	character(3) not null, 	-- IC2
	UNIQUE (numero, bloco), 		-- Não pode ter igual
    constraint pk_sala PRIMARY KEY(id)
);
-- Ver função CHECK com Mc Sapão


CREATE TABLE disciplina (
	id 				SERIAL, 					-- 1
    cod_disciplina 	character varying not null, -- TCC00286
    nome 			character varying, 			-- Banco de Dados 2
    ementa 			character varying not null, -- Aprende a criar triggers e procedures
    cargaHoraria 	integer not null, 			-- 40
    constraint pk_disciplina PRIMARY KEY (id)
);

CREATE TABLE turma (
	id 				SERIAL, 				-- 1
    codigo_turma 	character(2) not null, 	-- A1
    professor		integer not null, 		-- Luiz André
    disciplina 		integer not null, 		-- 12312 
    UNIQUE (codigo_turma, professor, disciplina),
	constraint fk_professor foreign key (professor) references professor(id),
	constraint fk_disciplina foreign key (disciplina) references disciplina(id),
	constraint pk_turma PRIMARY KEY (id)
);

-- Guardar histórico entre TURMA-OFERECE - Ver com Mc Sapão
CREATE TABLE oferece (
	id 					SERIAL,
	semestre 			character(5) not null,
	turma 				integer not null,
	disciplina 			integer not null,
	vagas 				integer not null default 10,
	alunos_inscritos 	integer not null default 0,
	constraint fk_turma foreign key (turma) references turma(id),
	constraint fk_disciplina foreign key (disciplina) references disciplina(id),
	constraint pk_oferece PRIMARY KEY (id)
);
-- add trigger para atualizar alunos_inscritos automaticamente


CREATE TABLE aula (
	id			SERIAL,
    turma 		integer not null,
	dia			character(3) not null,
    hora_inicio timestamp not null, 	-- Integer é vida!
    hora_fim 	timestamp not null,
    sala 		integer not null,
    constraint pk_aula primary key (id),
    constraint fk_turma foreign key (turma) references turma(id),
    constraint fk_sala foreign key (sala) references sala(id)
);
-- INSERT INTO AULA VALUES(turma,......)

CREATE TABLE aluno (
    matricula 	bigint not null unique, 	-- 214031126
    nome 		varchar(50) not null, 		-- Batman
    email 		varchar(50) not null, 		-- batman@id.uff.br
    telefone 	varchar(9) not null, 		-- 99999999
    constraint pk_aluno primary key (matricula)
    
);

-- Semestre nas duas tabelas?
-- Como garantir a inscrição de um aluno ou não de outro?
-- Talvez remover INSCRIÇÕES e SOLICITAÇÕES por conta do histórico do aluno e CR. Como calcular?
CREATE TABLE inscricoes (
	id					SERIAL,
	semestre 			character(5) not null, 	-- 2018.1
    matricula_aluno 	bigint not null, 		-- 2140131126
    codigo_turma 		integer not null, 		-- 1 
    unique (semestre, matricula_aluno, codigo_turma),
	constraint fk_aluno foreign key (matricula_aluno) references aluno(matricula),
    constraint fk_turma foreign key (codigo_turma) references turma(id),
    constraint pk_inscricoes primary key (id)
);

CREATE TABLE leciona_em(
	id 			SERIAL,
    professor 	integer not null,		-- 1
    turma 		integer not null, 		-- 1
	semestre 	character(5) not null, 	-- 2018.1
	unique (professor, turma, semestre),
    constraint fk_professor foreign key (professor) references professor(id),
    constraint fk_professor_turma foreign key (turma) references turma(id), 
    constraint pk_leciona_em primary key (id)
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