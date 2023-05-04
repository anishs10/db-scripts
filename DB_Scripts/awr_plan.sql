select * from table(dbms_xplan.display_awr('&sql_id',null,null,'ALL'));
