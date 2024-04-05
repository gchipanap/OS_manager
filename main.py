from flask import Flask, render_template, request, redirect
import pymysql
import time

def connect_to_database():
    attempts = 0
    max_attempts = 3
    while attempts < max_attempts:
        try:
            conn = pymysql.connect(
                host='localhost',
                user='root',
                password='12345',
                database='task'
            )
            return conn
        except pymysql.err.OperationalError as e:
            print(f"Error connecting to database: {e}")
            print("Retrying connection...")
            attempts += 1
            time.sleep(1)
    raise Exception("Failed to connect to database after multiple attempts")

app = Flask(__name__, static_folder='templates')

@app.route('/')
def index():
    try:
        conn = connect_to_database()
        with conn:
            with conn.cursor() as cursor:
                cursor.execute("SELECT id, state FROM os WHERE id_AST IN (SELECT id FROM AST WHERE state = 1) ORDER BY state;")
                os_records = cursor.fetchall()

        todo = [os_record for os_record in os_records if os_record[1] == 'To-do']
        in_process = [os_record for os_record in os_records if os_record[1] == 'In-process']
        finished = [os_record for os_record in os_records if os_record[1] == 'Finished']

        return render_template('index.html', todo=todo, in_process=in_process, finished=finished)
    except Exception as e:
        return f"Error refreshing database: {str(e)}", 500 

def refresh_database():
    try:
        conn = connect_to_database()
        with conn.cursor() as cursor:
            sql_query = "UPDATE os SET state = 'To-do' WHERE id_AST IN (SELECT id FROM AST WHERE state = 1);"
            cursor.execute(sql_query)

        conn.commit()
        conn.close()

        return "Database refreshed successfully!", 200 

    except Exception as e:
        return f"Error refreshing database: {str(e)}", 500


@app.route('/create_task', methods=['POST'])
def create_task():
    tipo = request.form['tipo']  # D o A
    id_os = request.form['id_os']

    sql_update_os = "UPDATE os SET state = 'In-process', " \
                    "id_task_desarme = CASE WHEN %s = 'D' THEN LAST_INSERT_ID() END, " \
                    "id_task_armado = CASE WHEN %s = 'A' THEN LAST_INSERT_ID() END " \
                    "WHERE id = %s;"
    
    sql_insert_task = "INSERT INTO tasks (tipo, state, fecha_inicio) VALUES (%s, 'To-do', NOW());"
    
    conn = pymysql.connect(
        host='localhost',
        user='root',
        password='12345',
        database='task'
    )

    with conn:
        with conn.cursor() as cursor:
            cursor.execute(sql_insert_task, (tipo,))
            
            task_id = cursor.lastrowid
            
            cursor.execute(sql_update_os, (tipo, tipo, id_os))

    return redirect('/')

if __name__ == '__main__':
    app.run(debug=True)
