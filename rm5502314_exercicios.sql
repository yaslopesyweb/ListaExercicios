-- Tabela
create table funcionarios (
    nm_fun varchar2(45),
    salario number(7,2),
    departamento varchar2(45)
);

insert into funcionarios (nm_fun, salario, departamento) values ('João', 3500, 'Financeiro');
insert into funcionarios (nm_fun, salario, departamento) values ('Maria', 3000, 'Compras');
insert into funcionarios (nm_fun, salario, departamento) values ('Paulo', 3000.00, 'RH');
insert into funcionarios (nm_fun, salario, departamento) values ('Frengus', 3600.00, 'RH');
insert into funcionarios (nm_fun, salario, departamento) values ('Aderbaldo', 2800.00, 'TI');
insert into funcionarios (nm_fun, salario, departamento) values ('Ana', 3200.00, 'TI');
insert into funcionarios (nm_fun, salario, departamento) values ('Pedro', 2900.00, 'Financeiro');
insert into funcionarios (nm_fun, salario, departamento) values ('Juliana', 3300.00, 'Financeiro');

-- Ex. 1
set serveroutput on;
declare
    v_nome funcionarios.nm_fun%type;
    v_salario funcionarios.salario%type;
    v_departamento funcionarios.departamento%type;
begin
    for funcionario in (select * from funcionarios) loop
        v_nome := funcionario.nm_fun;
        v_salario := funcionario.salario;
        v_departamento := funcionario.departamento;
        dbms_output.put_line('Nome: ' || v_nome || ', Salário: ' || v_salario || ', Departamento: ' || v_departamento);
    end loop;
end;

-- Ex 2
set serveroutput on;
declare
    v_departamento funcionarios.departamento%type := '&Departamento';
    v_total_salarios number := 0;
    v_qtde_funcionarios number := 0;
    v_media_salarios number := 0;
begin
    for funcionario in (select salario from funcionarios where departamento = v_departamento) loop
        v_total_salarios := v_total_salarios + funcionario.salario;
        v_qtde_funcionarios := v_qtde_funcionarios + 1;
    end loop;

    if v_qtde_funcionarios = 0 then
        dbms_output.put_line('Nenhum funcionário encontrado para o departamento.');
    else
        v_media_salarios := v_total_salarios / v_qtde_funcionarios;
        dbms_output.put_line('O salário médio dos funcionários do departamento ' || v_departamento || ' é: ' || v_media_salarios);
    end if;
end;

-- Ex 3
set serveroutput on;
declare
    v_percentual number := 0.10;
begin
    for funcionario in (select * from funcionarios) loop
        update funcionarios 
        set salario = salario * (1 + v_percentual)
        where nm_fun = funcionario.nm_fun;
    end loop;
    dbms_output.put_line('Salários atualizados em 10% com sucesso.');
end;

-- Ex 4
set serveroutput on;
declare
    v_departamento_maximo funcionarios.departamento%type;
    v_qtde_maxima number := 0;
    v_qtde_funcionarios number := 0;
begin
    for departamento in (select departamento, count(*) as qtde_funcionarios
                         from funcionarios
                         group by departamento) loop
        if departamento.qtde_funcionarios > v_qtde_maxima then
            v_qtde_maxima := departamento.qtde_funcionarios;
            v_departamento_maximo := departamento.departamento;
        end if;
    end loop;
    
    dbms_output.put_line('O departamento com o maior número de funcionários é: ' || v_departamento_maximo);
end;

-- Ex 5
set serveroutput on;
declare
    cursor c_departamentos is
        select departamento from funcionarios group by departamento;
begin
    for dept in c_departamentos loop
        delete from funcionarios where departamento = dept.departamento;
    end loop;
    commit;
    dbms_output.put_line('Todos os registros da tabela de departamentos foram excluídos.');
exception
    when others then
        dbms_output.put_line('Erro ao excluir registros da tabela de departamentos: ' || sqlerrm);
end;

-- Ex 6
set serveroutput on;
declare
    v_max_salario funcionarios.salario%type;
    v_nome_funcionario funcionarios.nm_fun%type;
begin
    select max(salario) into v_max_salario from funcionarios;
    select nm_fun into v_nome_funcionario
    from funcionarios
    where salario = v_max_salario;
    
    dbms_output.put_line('Funcionário com o maior salário: ' || v_nome_funcionario);
end;

-- Ex 7
set serveroutput on;
declare
    v_total_salarios number := 0;
begin
    for funcionario in (select salario from funcionarios) loop
        v_total_salarios := v_total_salarios + funcionario.salario;
    end loop;
    
    dbms_output.put_line('Total dos salários dos funcionários: ' || v_total_salarios);
end;

-- Ex 8
set serveroutput on;
declare
    v_departamento funcionarios.departamento%type := '&Departamento';
    cursor c_funcionarios is
        select * from funcionarios where departamento = v_departamento for update of salario;
begin
    for funcionario in c_funcionarios loop
        update funcionarios
        set salario = salario * 1.1
        where current of c_funcionarios;
    end loop;

    dbms_output.put_line('Salários dos funcionários do departamento ' || v_departamento || ' foram aumentados em 10%.');
end;

-- Ex 9
set serveroutput on;
declare
    v_min_qtde_funcionarios number := null;
    v_id_departamento funcionarios.departamento%type;
begin
    for depto in (select departamento, count(*) as qtde_funcionarios 
                  from funcionarios 
                  group by departamento 
                  order by count(*) asc) loop
        v_min_qtde_funcionarios := depto.qtde_funcionarios;
        v_id_departamento := depto.departamento;
        exit; 
    end loop;

    dbms_output.put_line('O departamento com a menor quantidade de funcionários é o: ' || v_id_departamento);
end;

-- Ex 10
set serveroutput on;
declare
    v_departamento funcionarios.departamento%type := '&Departamento';
    v_total_funcionarios number := 0;
begin
    for funcionario in (select count(*) as total_funcionarios
                         from funcionarios
                         where departamento = v_departamento) loop
        v_total_funcionarios := funcionario.total_funcionarios;
    end loop;
    dbms_output.put_line('O número total de funcionários no departamento ' || v_departamento || ' é: ' || v_total_funcionarios);
end;

-- Ex 11
set serveroutput on;
declare
    v_salario_limite number := &salario_limite;
begin
    for funcionario in (select nm_fun, salario
                         from funcionarios
                         where salario > v_salario_limite) loop
        dbms_output.put_line('Nome: ' || funcionario.nm_fun || ', Salário: ' || funcionario.salario);
    end loop;
end;

-- Ex 12
set serveroutput on;
declare
    v_num_departamentos number := 0;
begin
    for depto in (select distinct departamento from funcionarios) loop
        v_num_departamentos := v_num_departamentos + 1;
    end loop;
    dbms_output.put_line('O número total de departamentos na empresa é: ' || v_num_departamentos);
end;

-- Ex 13
set serveroutput on;
declare
    v_total_salarios number := 0;
    v_numero_funcionarios number := 0;
begin
    for funcionario in (select salario from funcionarios) loop
        v_total_salarios := v_total_salarios + funcionario.salario;
        v_numero_funcionarios := v_numero_funcionarios + 1;
    end loop;
    dbms_output.put_line('O valor total de salários pagos pela empresa é: ' || v_total_salarios);
    dbms_output.put_line('O total de salários pagos são: ' || v_numero_funcionarios);
end;

-- Ex 14
set serveroutput on;
declare
    v_departamento funcionarios.departamento%type := '&Departamento';
begin
    for funcionario in (select * from funcionarios where departamento = v_departamento) loop
        update funcionarios
        set salario = salario * 0.9 
        where nm_fun = funcionario.nm_fun;
    end loop;
    dbms_output.put_line('Salários diminuidos em 10% com sucesso.');
end;

-- Ex 15
set serveroutput on;
declare
    v_departamento_max_soma funcionarios.departamento%type;
    v_soma_maxima_salarios number := 0;
    v_soma_salarios number;
begin
    for depto in (select departamento, sum(salario) as total_salarios from funcionarios group by departamento) loop
        if depto.total_salarios > v_soma_maxima_salarios then
            v_soma_maxima_salarios := depto.total_salarios;
            v_departamento_max_soma := depto.departamento;
        end if;
    end loop;
    
    dbms_output.put_line('O departamento com a maior soma de salários é: ' || v_departamento_max_soma);
end;
