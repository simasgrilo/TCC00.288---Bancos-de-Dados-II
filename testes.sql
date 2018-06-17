---TESTES

--select gera_disciplinas();

--select gera_discliplinas();

--select gera_disciplinas_lecionaveis();

--select gera_cursos();

--select gera_disciplinas_oferecidas();

--select gera_salas();

--select * from disciplinas_lecionaveis;

--Um curso não pode ter o coordenador como vice coordenador ou o professor não pode ser coordenador de dois ou mais cursos ao mesmo tempo (o mesmo para vice_coordenador):
select * from cursos;

--update cursos
--set vice_coordenador = 2
--where id = 2;

select * from professores;
select * from cursos;
--INSERT INTO CURSOS(nome, professor_coordenador, vice_coordenador) VALUES ('aaa',54,54);
select * from cursos;



--update cursos
--set professor_coordenador = 45
--where id = 3;

--Um professor não pode duas turmas no mesmo horário:
select * from turmas;
select * from turmas full outer join ofertas on turmas.id = ofertas.id;

--Um professor só pode dar aula do que ele efetivamente deve dar:

--select * from alunos;

--select * from turmas where id = 1;

--select * from ofertas where id = 1;

--select * from disciplinas_lecionaveis where id = 1;
--insert into TURMAS(codigo_turma, professor, oferta) VALUES (4, 1, 1);

--Uma sala de aula não deve ter duas aulas diferentes acontecendo no mesmo dia e horário.
--select * from salas;
--select * from aulas;

--update aulas
--set dia = 'TER'
--where id = 5;
            
--Um aluno não pode estar inscrito na mesma disciplina 2x no mesmo período

