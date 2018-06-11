
DROP TABLE IF EXISTS professor CASCADE;

DROP TABLE IF EXISTS sala CASCADE;

DROP TABLE IF EXISTS disciplina CASCADE;

DROP TABLE IF EXISTS turma CASCADE;

DROP TABLE IF EXISTS aula CASCADE;

DROP TABLE IF EXISTS curso cascade;

DROP TABLE IF EXISTS aluno cascade;

DROP TABLE IF EXISTS inscricoes cascade;

DROP TABLE IF EXISTS leciona_em cascade;

CREATE TABLE professor (
    matricula bigint not null,
    nome character varying not null,
    email character varying not null,
    CONSTRAINT pk_professor PRIMARY KEY(matricula)
);

CREATE TABLE curso (
    nome  character varying not null,
    professor_coordenador bigint not null unique,
    vice_coordenador  bigint not null unique,
    constraint pk_curso primary key (nome,professor_coordenador),
    constraint fk_coordenador foreign key (professor_coordenador) references professor(matricula),
    constraint fk_vice foreign key (vice_coordenador) references professor(matricula)
);
--com essa tabela, é possivel colocar umas constraints extras como: um coordenador não pode lecionar mais de duas disciplinas, um coordenador não pode ser o vice (e vice versa). Ganhamos mais algumas constraints (opcional).


CREATE TABLE sala(
    numero int not null,
    bloco character varying not null,
    constraint pk_sala primary key (numero)
);

CREATE TABLE disciplina (
    cod_disciplina character varying not null,
    descricao character varying,
    ementa character varying not null,
    cargaHoraria integer not null,
    constraint pk_disciplina primary key (cod_disciplina)
);

CREATE TABLE turma (
    codigo_turma character varying not null,
    professor  bigint not null,
    disciplina character varying not null, --isso aqui na verdade vai apontar pro relacionamento entre disciplina e curso. disciplna que tem turma ou turma que tem disciplina?
    alunos_inscritos integer,
    constraint fk_professor foreign key (professor) references professor(matricula),
    constraint pk_turma primary key (codigo_turma) --tá errado isso aqui
    --xabuzão aqui; o horário da aula (agendamento) é armazenado em aula, como fazer uma turma única então
);


CREATE TABLE aula (
    turma character varying not null,
	--dias character varying, --a gente pode também representar hora_inicio e hora_fim por varchar, ex. segunda e sexta 9-11 
    hora_inicio timestamp not null,
    hora_fim timestamp not null,
    sala int not null,
    constraint pk_aula primary key (turma,hora_inicio,hora_fim),
    constraint fk_turma foreign key (turma) references turma(codigo_turma),
    constraint fk_sala foreign key (sala) references sala(numero)
);

CREATE TABLE aluno (
    matricula bigint not null,
    nome character varying not null,
    email character varying not null,
    telefone varchar(9) not null,
    constraint pk_aluno primary key (matricula)
    
);
--relacionamentos

CREATE TABLE inscricoes(
    matricula_aluno bigint not null,
    codigo_turma character varying not null,
    constraint fk_aluno foreign key (matricula_aluno) references aluno(matricula),
    constraint fk_turma foreign key (codigo_turma) references turma(codigo_turma), --pelo modelo desenhado com o professor, um aluno se inscreve em uma turma, e não em uma disciplina (eu acho estranho mas vamo ver).
    constraint pk_inscricoes primary key (matricula_aluno,codigo_turma)
);

CREATE TABLE leciona_em(
    professor integer not null,
    turma character varying not null,
    constraint fk_professor foreign key (professor) references professor(matricula),
    constraint fk_professor_turma foreign key (turma) references turma(codigo_turma), 
    constraint pk_leciona_em primary key (professor,turma)
);

--falta o relacionamento "inscrito", "oferece" e a tabela "solicitações" que segura o aluno que se inscreve na turma antes dele ser cadastrado lá. 
--Tem que ver também atributos como "dia e hora na qual uma aula acontece", dentre outros.

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
