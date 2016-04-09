from sys import argv
import psycopg2

conn = psycopg2.connect(database="tcount", user="postgres", password="pass", host="localhost", port="5432")
cur = conn.cursor()

if len(argv)>1:
    name, word = argv
    
    try:
        cur.execute("SELECT count FROM Tweetwordcount WHERE word=%s", [word])
    
        record = cur.fetchall()
    
        print "Total number of occurences of %s : %s" % (word,record[0][0])
        conn.commit()
        conn.close()
    
    except:
        print "Not in dictionary"

else: 
    cur.execute("SELECT word, count FROM Tweetwordcount ORDER BY word")
    record = cur.fetchall()
    for i in record:
        print i
    
    conn.commit()
    conn.close()
