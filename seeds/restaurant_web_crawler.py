# You'll want to make sure that you have the selenium bindings for python installed.
# http://selenium-python.readthedocs.io/
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import NoSuchElementException
import sys
import geocoder

class restaurant:
	def __init__(self, name, address, lat, lng):
		self.name = name
		self.address = address
		self.lat = lat
		self.lng = lng

def write_list_to_file_and_exit(filename):
	target = open(filename + ".txt", 'w')

	for restaurant in array_of_restaurants:
		target.write(restaurant.name + ";" + restaurant.address + ";" + str(restaurant.lat) + ";" + str(restaurant.lng) + "\n")
		
	target.close()
	exit()

def grab_page_data(restaurant_no):
	name = driver.find_element_by_xpath("//*[@id='naturalResults." + str(x) + ".name']/div[1]/div/div/h4/span[1]").text
	address = driver.find_element_by_xpath("//*[@id='naturalResults." + str(x) + ".address']/span[1]").text
	city = driver.find_element_by_xpath("//*[@id='naturalResults." + str(x) + ".address']/span[2]").text
	state = driver.find_element_by_xpath("//*[@id='naturalResults." + str(x) + ".address']/span[3]").text 
	if name.find("CLOSED") == -1:
		location_string = address + " " + city + " " + state
		location_geocoded = geocoder.google(location_string)
		print(name + " " + location_string + " (" + str(location_geocoded.lat) + "," + str(location_geocoded.lng) + ")\n")
		if location_geocoded.lat != None and location_geocoded.lng != None:
			array_of_restaurants.append(restaurant(name, location_string, location_geocoded.lat, location_geocoded.lng))
	
# Get the city and two-letter state abbreviation from commandline.	python restaurant_web_crawler memphis tn 3000
city = sys.argv[1]
state_abbrev = sys.argv[2]
restaurant_number_estimate = sys.argv[3]

# Download this driver from https://sites.google.com/a/chromium.org/chromedriver/downloads
driver = webdriver.Chrome('chromedriver_win32/chromedriver.exe') 
driver.get("http://www.citysearch.com/search?what=restaurants&where=" + city + "%2C+" + state_abbrev)

# Wait for page to load.
driver.implicitly_wait(2)

array_of_restaurants = []

theoretical_page_limit = int(int(restaurant_number_estimate)/10)

print("Finding restaurants for " + city + ", " + state_abbrev)
print("Looking for " + restaurant_number_estimate + " restaurants roughly " + str(int(restaurant_number_estimate)/10) + " pages.")

for page in range(1, theoretical_page_limit+1):
	for x in range(1, 11):
		try:
			grab_page_data(x)
			driver.implicitly_wait(1)
		# Sometimes the page 404s, just reload the page and continue.
		except NoSuchElementException:
			driver.get("http://www.citysearch.com/search?what=restaurants&where=" + city + "%2C+" + state_abbrev + "&page=" + str(page))
			driver.implicitly_wait(1)
			# Try again.
			try:
				grab_page_data(x)
				driver.implicitly_wait(1)
			except NoSuchElementException:
				#If it fails again, just write the list and exit.
				write_list_to_file_and_exit(city + "_" + state_abbrev + "_restaurants")
	next_link = driver.find_element_by_id("pagination.link.next")
	next_link.click()
	driver.implicitly_wait(2)
	

write_list_to_file_and_exit(city + "_" + state_abbrev + "_restaurants")
	

	
	


