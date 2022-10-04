-- Procedures are generally used for automation, but in this code we will try something new.
-- We will create Transaction_table with procedure to get column names dynamically.
-- You can use this method if you need pivot table but having problem with long SQL scripts because of naming columns.
-- In this code we will create columns according to financial week numbers.

CREATE OR REPLACE PROCEDURE procedure_for_dynamic_loop()
  RETURNS string
  LANGUAGE JAVASCRIPT
  EXECUTE AS CALLER
    AS
 $$
// dynamic way of writing sql query

var loop_columns = ''
var week_num = 201930

// loop for weeks
    do {
        var column_name_t = 'trans_' + String(week_num).substring(4,6)
        var column_name_v = 'trans_value_' + String(week_num).substring(4,6)

        loop_columns += ', count (distinct case when WEEK_NO=' + week_num + ' then TRANSACTION_KEY end) as ' + column_name_t
        + ',sum(case when WEEK_NO=' + week_num + ' then TRANSACTION_VALUE end) as ' + column_name_v
        week_num = week_num + 1
            } while(week_num <= 201952)

// create sql command
    var sqlCommand = 'create or replace temp table transaction_table as select "ID" as ID_TRANS '+loop_columns

    + ',count(distinct case when DATE_KEY between ' + "'2019-10-04'" + ' and ' + "'2019-12-12'" + ' then TRANSACTION_KEY end) as transaction'
    + ',sum(case when DATE_KEY between ' + "'2019-10-04'" + ' and ' + "'2019-12-12'" + ' then TRANSACTION_VALUE end) as trans_value'

    +" from transaction_main_table 
    
    group by 1;"
    
    var Result_1 = snowflake.execute({sqlText:sqlCommand});
    return 'END'
$$
;

-- call the procedure
CALL procedure_for_dynamic_loop();