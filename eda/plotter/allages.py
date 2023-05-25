import psycopg2
import matplotlib.pyplot as plt

# Connection parameters
hostname = '***REMOVED***'
port = 5432
database = 'mimiciv'
username = 'mimicuser'
password = '***REMOVED***'

print(" Connect to the PostgreSQL server")
conn = psycopg2.connect(
    host=hostname,
    port=port,
    dbname=database,
    user=username,
    password=password
)

# Create a cursor object
cur = conn.cursor()

# Execute a SELECT query on the "example" table
print("Executing query...")
#cur.execute('SELECT a.age::INTEGER, count(distinct a.subject_id) FROM mimiciv_hosp.patients p JOIN mimiciv_derived.age a on p.subject_id = a.subject_id JOIN mimiciv_derived.sepsis3 s on p.subject_id = s.subject_id and s.sepsis3 WHERE p.subject_id in (	SELECT subject_id from mimiciv_icu.icustays ) GROUP BY a.age::INTEGER ORDER BY a.age::INTEGER asc;')
cur.execute('SELECT a.age::INTEGER, count(distinct a.subject_id) FROM mimiciv_hosp.patients p JOIN mimiciv_derived.age a on p.subject_id = a.subject_id GROUP BY a.age::INTEGER ORDER BY a.age::INTEGER asc;')
print("fetching results")
# Fetch and print the results
results = cur.fetchall()	
print("Fetched " + str(len(results)) + "rows.")
mapped = list(map(list, zip(*results)))
plt.plot(mapped[0], mapped[1])
plt.title('Age of all patients')
plt.xlabel('Age')
plt.ylabel('Count')

plt.show()
plt.savefig('allages.png')
# Close the cursor and connection
cur.close()
conn.close()
