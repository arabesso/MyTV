require "rubygems"
require "sequel"
require "date"
require 'net/http'
require 'digest'
require 'json'
require 'logger'
require 'shoes'
require_relative 'web'
require_relative 'TVShow'
require_relative 'Episode'
require_relative 'database'

$logger = Logger.new('test.log', 'daily')
$logger.level = Logger::DEBUG

# Initialising the DB connection,
$logger.info "Connecting to the database"
DB = Sequel.connect('sqlite://MyTV.db')
if (DB.table_exists?(:TVShows) and DB.table_exists?(:Episodes))
	myShows = DB[:TVShows] 
	episodes = DB[:Episodes]
else
	$logger.info "Creating tables... "
	Database.createTables
	myShows = DB[:TVShows] 
	episodes = DB[:Episodes]
end
$logger.info "...completed"


#Database.addShow("The Player", myShows, episodes)


#puts Database.getShow(myShows, 2244)
#Database.addEpisodes(TVShow.new("The Player", "2244"), episodes)

#puts Database.numberOfEntries(myShows).to_s + " shows"
#puts Database.numberOfEntries(episodes).to_s + " episodes"

#puts Database.getEpisodes(episodes, 2244).to_a #[0]
#puts Database.getEpisodes(episodes, 2244).to_a[0][:airdate]

=begin

# Ruby classes are only used to serve as a bridge between the API-database or the user-database

# SQL pseudocode to remove episodes from the db once watched
WATCHED EPISODE --> DROP EPISODE


# compares the last episode stored with the last episode in the API for every show in the database
def updateShows()
	
end

# Setting episode as watched should remove the episode from the database
# What if it's the last episode, for example? If i remove it,
# new updates would pull it again.
# Maybe keeping always at least1 episode, even if it's watched

=end