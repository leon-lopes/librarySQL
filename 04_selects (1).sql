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


--06 Exibir o valor total das vendas da livraria nos anos de 2019 e 2020
select extract(year from ven_data), 'R$ ' || sum(exe_valor)
from ven_venda join exe_exemplar using (ven_id)
where ven_data like '%/19' or ven_data like '%/20'
group by extract(year from ven_data);


--07 Mostrar os nomes dos livros com exemplares disponíveis, a soma dos valores de cada exemplar cadastrado e também
-- o valor total de todos os exemplares existentes na livraria
select liv_nome, 'R$ '|| sum(exe_valor)
from liv_livro join exe_exemplar using (liv_isbn)
group by rollup(liv_nome);


--08 Exibir quantos generos diferentes cada fornecedor disponibiliza mostrando também a quantidade total de exemplares por
-- gênero e por fim, a quantidade total de exmplares cadastrados
select for_nome, liv_genero, count(exe_id)
from liv_livro join exe_exemplar using (liv_isbn) join for_fornecedor using (for_id)
group by cube(for_nome, liv_genero)
order by for_nome, liv_genero;


--09 Mostrar o nome dos clientes e o valor que eles já compraram algo na livraria,
-- mas exibir apenas os que gastaram mais de R$100 no total
select pes_nome, 'R$ ' || sum(exe_valor)
from pes_pessoa join cli_cliente on (pes_cpf=cli_cpf)
    join ven_venda using (cli_cpf)
        join exe_exemplar using (ven_id)
group by pes_nome
having sum(exe_valor)>100.0;


--10 Exibir o nome do livro, o valor do exemplar e a data que ele ficou com o preço mais barato em todo o histórico da livraria
select liv_nome, exe_valor, ofe_data
from liv_livro join exe_exemplar using (liv_isbn) join ofe_oferta using (exe_id)
where exe_valor = (select min(ofe_valor) from ofe_oferta join exe_exemplar using (exe_id));


--11 Mostrar o nome e o valor do livro mais caro que já foi vendido
select liv_nome, exe_valor
from liv_livro join exe_exemplar using (liv_isbn)
where exe_valor = (select max(exe_valor) from exe_exemplar where ven_id is not null);


--12 Supondo que cada vendedor receba uma comissão de 9% por venda, mostre quanto cada vendedor ganhou de comissão.
-- Também exibir os que não ganharam nada
select pes_nome, 'R$ ' || nvl(sum(exe_valor)*0.09, 0.00)
from pes_pessoa join fun_funcionario on (pes_cpf=fun_cpf)
    left join ven_venda using (fun_cpf)
        left join exe_exemplar using (ven_id)
where upper(fun_cargo)='VENDEDOR'
group by pes_nome;


--13 Exibir o nome e nacionalidade dos autores que possuem a mesma nacionalidade
select aut_nome, aut_nacionalidade
from aut_autor
where aut_nacionalidade = any (select aut_nacionalidade
                                from aut_autor
                                group by aut_nacionalidade
                                having count(aut_nacionalidade)>1);


--14 Exibir o país e idioma de cada exemplar mostrando também a quantidade de exemplares por países.
select exe_pais, exe_idioma, count(*), grouping(exe_pais), grouping(exe_idioma)
from exe_exemplar
group by rollup(exe_pais, exe_idioma);


--15 Exibir todos os livros que já tiveram algum desconto pelo menos uma vez
select exe_id, liv_nome
from exe_exemplar e, liv_livro l
where l.liv_isbn=e.liv_isbn and exe_valor > any (select ofe_valor from ofe_oferta o where o.exe_id=e.exe_id);
