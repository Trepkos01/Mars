import psycopg2
import uuid
import sys

try:
    conn = psycopg2.connect("dbname='' user='' host='' password=''")
except:
    print ("I am unable to connect to the database.")
	
filename = sys.argv[1]

with open(filename + ".txt") as f:
    restaurants = f.readlines()
	
cur = conn.cursor()

user_id = "0f1212f3-343d-4f3c-a553-4a695133525f"

for restaurant in restaurants:
	id = uuid.uuid4().hex
	restaurant_details = restaurant.split(";")
	restaurant_name = restaurant_details[0]
	address = restaurant_details[1]
	lat = restaurant_details[2]
	lng = restaurant_details[3]
	print("Inserting " + id + " " + restaurant_name + " " + address + " " + lat + "," + lng + " " + user_id)
	
	cur.execute("INSERT INTO restaurants (id, restaurant_name, address, lat, lng, active, created_at, updated_at, user_id) VALUES (%s, %s, %s, %s, %s, %s, current_timestamp, current_timestamp, %s)", (id, restaurant_name, address, lat, lng, True, user_id,))

conn.commit()


