import os
import re
# Convert data to sql insert statements

# read data from file
with open(os.path.join(os.path.dirname(__file__), 'data.txt'), 'r') as f:
    data = f.read()
    # Remove E infront of every line
    regex = re.compile('^E\s+', re.MULTILINE)
    data = regex.sub('\n', data)
    data = data.replace('\n\n', '\n')
    tables = data.split('\n\n')
    
    sql_begin = "SET SEARCH_PATH TO uber, public;\n"
    table_insert = ""
    table_names = []

    for table in tables:
        table = table.strip()
        table_lines = table.split('\n')
        table_name = table_lines[0]
        table_names.append(table_name)
        table_columns = table_lines[1].split('|')
        table_columns = [x.strip() for x in table_columns]
        table_lines = table_lines[3:]
        table_insert += 'INSERT INTO %s VALUES' % table_name + '\n'
        for row in table_lines:
            row = row.split('|')
            row = [x.strip() for x in row]
            # Add quotes to strings
            row = ["'%s'" % x if not x.isdigit() else x for x in row]
            table_insert += '(%s),' % ', '.join(row) + '\n'
        table_insert = table_insert[:-2] + ';' + '\n' + '\n'

    # Add tuncate statements in beginning of file
    truncate = 'TRUNCATE TABLE %s CASCADE;' % ', '.join(table_names) + '\n' + '\n'
    table_insert = sql_begin + truncate + table_insert

    with open(os.path.join(os.path.dirname(__file__), 'data_test.sql'), 'w') as f:
        f.write(table_insert)
