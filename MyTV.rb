require "rubygems"
require "sequel"
require "date"
require 'net/http'
require 'digest'
require 'json'
require_relative 'web'
require_relative 'TVShow'
require_relative 'Episode'
require_relative 'database'

# Initialising the DB connection,
puts "Connecting to the database..."
DB = Sequel.connect('sqlite://MyTV.db')
if (DB.table_exists?(:TVShows) and DB.table_exists?(:Episodes))
	myShows = DB[:TVShows] 
	episodes = DB[:Episodes]
else
	puts "Creating tables... "
	Database.createTables
	myShows = DB[:TVShows] 
	episodes = DB[:Episodes]
end
puts " completed"

print "Trying to add show The Player..."
Database.addShow("The Player", myShows, episodes)
puts " completed"

#puts Database.numberOfEntries(myShows).to_s + " shows"
#puts Database.numberOfEntries(episodes).to_s + " episodes"



=begin

# Ruby classes are only used to serve as a bridge between the API-database or the user-database


# SQL pseudocode to fetch all episodes from the same show
SELECT * FROM EPISODES WHERE SHOW_ID = (AND WATCHED = FALSE)
# SQL pseudocode to remove episodes from the db once watched
WATCHED EPISODE --> DROP EPISODE


# populate the table

items.insert(:name => 'def', :price => rand * 100)
items.insert(:name => 'ghi', :price => rand * 100)

# print out the number of records


# print out the average price
puts "The average price is: #{items.avg(:price)}"

# compares the last episode stored with the last episode in the API for every show in the database
def updateShows()
	
end

# In Episode: watched removes the episode from the database
# Do I need to do anything else? If it's the last episode, for example?
# In order to prevent new updates from not pulling it.
# Maybe keeping always 1 episode, even if it's watched?


=end

