create table pes_pessoa(
    pes_cpf number(11) constraint pes_pk primary key,
    pes_nome varchar2(50) not null,
    pes_tel_res varchar2(15),
    pes_tel_cel varchar2(15),
    pes_tel_com varchar2(15),
    pes_email varchar2(50) constraint pes_uk unique
);


create table cli_cliente(
    cli_cpf number(11) constraint cli_pk primary key,
    cli_endereco varchar2(100),
    constraint cli_pes_fk foreign key(cli_cpf) references pes_pessoa(pes_cpf)
);


create table fun_funcionario(
    fun_cpf number(11) constraint fun_pk primary key,
    fun_cargo varchar2(20),
    fun_re integer,
    constraint fun_pes_fk foreign key(fun_cpf) references pes_pessoa(pes_cpf)
);


create table aut_autor(
    aut_id integer constraint aut_pk primary key,
    aut_nome varchar2(50) not null,
    aut_nacionalidade varchar2(50)
);

--Sequencia para colocar ids nos autores
create sequence aut_id_seq
increment by 1;
--drop sequence aut_id_seq;

create table liv_livro(
    liv_isbn number(15) constraint liv_pk primary key,
    liv_nome varchar2(50) not null,
    liv_genero varchar2(20),
    liv_editora varchar2(50),
    liv_ano_edicao integer,
    liv_num_edicao integer
);

--Relacao n:n entre autor e livro
create table atr_autoria(
    aut_id integer constraint atr_aut_fk references aut_autor(aut_id),
    liv_isbn number(15) constraint atr_liv_fk references liv_livro(liv_isbn),
    constraint atr_pk primary key(aut_id, liv_isbn)
);


create table for_fornecedor(
    for_id integer constraint for_pk primary key,
    for_nome varchar2(50) not null,
    for_empresa varchar2(50)
);

--Sequencia para colocar ids nos fornecedores
create sequence for_id_seq
increment by 1;
--drop sequence for_id_seq;

create table ven_venda(
    ven_id integer constraint ven_pk primary key,
    cli_cpf number(11) constraint ven_cli_fk references cli_cliente(cli_cpf),
    fun_cpf number(11) constraint ven_fun_fk references fun_funcionario(fun_cpf),
    ven_data date
);

--Sequencia para colocar ids nas vendas
create sequence ven_id_seq
increment by 1;
--drop sequence ven_id_seq;

create table exe_exemplar(
    liv_isbn number(15) constraint exe_liv_fk references liv_livro(liv_isbn),
    exe_id integer,
    exe_paginas integer,
    exe_idioma varchar2(30),
    exe_pais varchar2(50),
    exe_acabamento varchar2(30),
    exe_valor number(6,2),
    for_id integer constraint exe_for_fk references for_fornecedor(for_id),
    ven_id integer default null constraint exe_ven_fk references ven_venda(ven_id),
    constraint exe_pk primary key(liv_isbn, exe_id)
);
--drop table exe_exemplar;
alter table exe_exemplar add constraint exe_chk check(exe_valor>0.0);

--Sequencia para colocar ids nos exemplares
create sequence exe_id_seq
increment by 1;
--drop sequence exe_id_seq;

create table ofe_oferta(
    exe_id integer,
    liv_isbn number(15),
    ofe_valor number(6,2),
    ofe_data date,
    constraint ofe_pk primary key(exe_id, liv_isbn, ofe_data),
    constraint ofe_exe_fk foreign key (exe_id, liv_isbn) references exe_exemplar(exe_id, liv_isbn)
);
--drop table ofe_oferta;

--View criada para visualizar os exemplares relacionados as vendas
create view exv_exemplar_vendido as
select ven_id "No. pedido", exe_id "Cód. Livro", liv_nome "Título"
from liv_livro join exe_exemplar using(liv_isbn) join ven_venda using(ven_id);
--drop view exv_exemplar_vendido;
