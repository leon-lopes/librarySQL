SET SERVEROUTPUT ON;
--Insere todas as atualizacoes de valores de um exemplar na tabela ofe_oferta.
--Obs.: Para esse trigger funcionar, foi preciso ir em:
--Ferramentas->Preferências->Banco de Dados->Compilador de PL/SQL->Identificadores de PLScope->colocar em None
create or replace trigger oferta_registro_temporal
after insert or update on exe_exemplar
for each row

begin
    if inserting then
        insert into ofe_oferta(exe_id,liv_isbn,ofe_valor,ofe_data)
        values(:new.exe_id, :new.liv_isbn, :new.exe_valor, sysdate);
    elsif updating then
        --Verifica se houve alteracao no valor do exemplar
        if(:old.exe_valor != :new.exe_valor) then
            insert into ofe_oferta(exe_id,liv_isbn,ofe_valor,ofe_data)
            values(:new.exe_id, :new.liv_isbn, :new.exe_valor, sysdate);
        end if;
    end if;
end oferta_registro_temporal;
/


--Exibe uma mensagem informando qual livro foi vendido e em qual pedido ele esta
create or replace trigger exemplar_vendido
after update on exe_exemplar
for each row when(new.ven_id is not null)

declare
    nome liv_livro.liv_nome%type;
    
    --Para evitar o erro ORA-04091:
    Pragma Autonomous_Transaction;

begin
    select liv_nome into nome
    from liv_livro join exe_exemplar using(liv_isbn)
    where exe_id=:new.exe_id;
    
    dbms_output.put_line('O livro "' || :new.exe_id || ': ' || nome || '" foi incluído no pedido ' || :new.ven_id);
end exemplar_vendido;
/


--Impede que um exemplar ja vendido seja adicionado em outro pedido
create or replace trigger exemplar_ja_vendido
before update on exe_exemplar
for each row when(old.ven_id is not null)

begin
    if(:old.ven_id != :new.ven_id) then
        raise_application_error(-20101,'Não é possível alterar um exemplar já vendido!');
    end if;
end exemplar_ja_vendido;
/
