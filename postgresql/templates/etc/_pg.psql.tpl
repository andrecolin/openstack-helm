CREATE EXTENSION pglogical;

# create a test role and password
CREATE USER test WITH SUPERUSER PASSWORD 'test';

#create database test with role test 
createdb -O test test 

# create the pglogical master node
SELECT pglogical.create_node(node_name :='provider1',dsn:='host=localhost port=5432 dbname=test');

# create replication set named default with all tables in public schema
SELECT pglogical.replication_set_add_all_tables('default', ARRAY['public']);