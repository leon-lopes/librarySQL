--01 Listar os exemplares vendidos mostrando o id da venda, id do exemplar e nome do livro. Ordenar por id da venda e depois por id do exemplar.
-- para esta consulta foi criada uma view
select * from exv_exemplar_vendido
order by "No. pedido", "Cód. Livro";

--02 Exibir todos os livros registrados na livraria, mas que não existem exemplares cadastrados.
select * from liv_livro
where liv_isbn not in (select liv_isbn from liv_livro join exe_exemplar using(liv_isbn));

--03 Mostrar a quantidade de exemplares de cada livro, também exibir os que não possuem exemplares.
select liv_nome, count(exe_id)
from liv_livro left join exe_exemplar using(liv_isbn)
group by liv_nome;

--04 Exibir o nome e o número de vendas de todos os vendedores que efetuaram mais de 1 venda
select pes_nome, count(ven_id)
from pes_pessoa p, fun_funcionario f, ven_venda v
where p.pes_cpf=f.fun_cpf and f.fun_cpf=v.fun_cpf and lower(f.fun_cargo)='vendedor'
group by pes_nome
having count(ven_id)>1;

--05 Mostrar o nome de cada autor em ordem alfabética e exibir quais livros ele escreveu
select aut_nome, liv_nome
from aut_autor join atr_autoria using(aut_id) join liv_livro using(liv_isbn)
order by aut_nome;

