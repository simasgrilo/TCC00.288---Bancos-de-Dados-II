
DROP TABLE IF EXISTS professor CASCADE;

DROP TABLE IF EXISTS sala CASCADE;

DROP TABLE IF EXISTS disciplina CASCADE;

DROP TABLE IF EXISTS turma CASCADE;

DROP TABLE IF EXISTS aula CASCADE;

DROP TABLE IF EXISTS curso cascade;

CREATE TABLE professor (
    matricula bigint not null,
    nome character varying not null,
    email character varying not null,
    CONSTRAINT pk_professor PRIMARY KEY(matricula)
);

CREATE TABLE curso (
    nome  character varying not null,
    professorCoordenador bigint not null,
    viceCoordenador      bigint not null,
    constraint pk_curso primary key (nome,professorCoordenador),
    constraint fk_coordenador foreign key (professorCoordenador) references professor(matricula),
    constraint fk_vice foreign key (viceCoordenador) references professor(matricula)
);
--com essa tabela, é possivel colocar umas constraints extras como: um coordenador não pode lecionar mais de duas disciplinas, um coordenador não pode ser o vice (e vice versa). Ganhamos mais 3 constraints (opcional).


CREATE TABLE sala(
    numero int not null,
    bloco character varying not null,
    constraint pk_sala primary key (numero)
);

CREATE TABLE disciplina (
    codDisciplina character varying not null,
    descricao character varying,
    ementa character varying not null,
    constraint pk_disciplina primary key (codDisciplina)
);

CREATE TABLE turma (
    codigoTurma character varying not null,
    professor  bigint not null,
    disciplina character varying not null, --isso aqui na verdade vai apontar pro relacionamento entre disciplina e curso
    constraint fk_professor foreign key (professor) references professor(matricula),
    constraint pk_turma primary key (codigoTurma) --tá errado isso aqui
    --xabuzão aqui; o horário da aula (agendamento) é armazenado em aula, como fazer uma turma única então
);


CREATE TABLE aula (
    turma character varying not null,
    horaInicio timestamp not null,
    horaFim timestamp not null,
    sala int not null,
    constraint pk_aula primary key (turma,horaInicio,horafim),
    constraint fk_turma foreign key (turma) references turma(codigoTurma),
    constraint fk_sala foreign key (sala) references sala(numero)
);

