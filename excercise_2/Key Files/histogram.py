from sys import argv
import psycopg2

conn = psycopg2.connect(database="tcount", user="postgres", password="pass", host="localhost", port="5432")
cur = conn.cursor()

script, k1, k2 = argv

k1 = k1.replace(',', '')

command = "SELECT word, count FROM Tweetwordcount WHERE count>%s and count< %s ORDER BY count DESC LIMIT 10" % (k1,k2,)

cur.execute(command)   
record = cur.fetchall()

for i in record:
    print i

conn.commit()
conn.close()