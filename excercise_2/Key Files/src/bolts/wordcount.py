from __future__ import absolute_import, print_function, unicode_literals

from collections import Counter
from streamparse.bolt import Bolt
import psycopg2


class WordCounter(Bolt):

    conn = psycopg2.connect(database="tcount", user="postgres", password="pass", host="localhost", port="5432")

    def initialize(self, conf, ctx):
        self.counts = Counter()
        #self.redis = StrictRedis()

    def process(self, tup):
        word = tup.values[0]

        # Write codes to increment the word count in Postgres
        # Use psycopg to interact with Postgres
        # Database name: Tcount 
        # Table name: Tweetwordcount 
        # you need to create both the database and the table in advance.
        
        cur = self.conn.cursor()
        self.counts[word] += 1

        #Check if word exists
        
        #exists = cur.execute("select count(1) from tweetwordcount where word = %s" % word)
        
        '''if self.counts[word]==1:
            cur.execute('INSERT INTO Tweetwordcount (word,count) VALUES (%s, 1)', [word])
            self.conn.commit()'''    
        if self.counts[word]==1:
            try: 
                cur.execute('INSERT INTO Tweetwordcount (word,count) VALUES (%s, 1)', [word])
                self.conn.commit()    
            except:
                self.conn.rollback()
                cur.execute("SELECT count FROM Tweetwordcount WHERE word=%s", [word])
                record = cur.fetchall()
                self.counts[word] = record[0][0]+1
                cur.execute('UPDATE Tweetwordcount SET count=%s WHERE word=%s', (self.counts[word],word))
                self.conn.commit()
                pass
                                                            
        else:
                #Assuming you are passing the tuple (uWord, uCount) as an argument
            cur.execute('UPDATE Tweetwordcount SET count=%s WHERE word=%s', (self.counts[word],word))
            self.conn.commit()
        

        # Increment the local count
        self.emit([word, self.counts[word]])

        # Log the count - just to see the topology running
        self.log('%s: %d' % (word, self.counts[word]))

