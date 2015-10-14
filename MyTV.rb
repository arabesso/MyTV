require "rubygems"
require "sequel"
require "date"
require 'net/http'
require 'digest'
require 'json'
require 'logger' # debug, info, warn, error, fatal

require_relative 'web'
require_relative 'TVShow'
require_relative 'Episode'
require_relative 'database'

$logger = Logger.new('test.log', 'daily')
$logger.level = Logger::DEBUG

# Initialising the DB connection,
$logger.debug "Connecting to the database"
DB = Sequel.connect('sqlite://MyTV.db')
if (DB.table_exists?(:TVShows) and DB.table_exists?(:Episodes))
	myShows = DB[:TVShows] 
	episodes = DB[:Episodes]
else
	$logger.debug "Creating tables... "
	Database.createTables
	myShows = DB[:TVShows] 
	episodes = DB[:Episodes]
end
$logger.debug "...completed"

puts a[]]


# Main code here:
#Database.update(myShows, episodes)


=begin

Full console: NO GUI
Decide how to use the program
	a. commandline arguments (Trollops vs OptionParser)
		+ http://www.rubyinside.com/trollop-command-line-option-parser-for-ruby-944.html
		+ http://stackoverflow.com/questions/897630/really-cheap-command-line-option-parsing-in-ruby/1012930#1012930
		* http://ruby.about.com/od/advancedruby/a/optionparser.htm
		* http://ruby-doc.org/stdlib-2.2.3/libdoc/optparse/rdoc/OptionParser.html
	b. interactive console (REPL)
		+ http://stackoverflow.com/questions/9853853/creating-interactive-ruby-console-application

ALL THE METHODS IN DATABASE MUST HAVE THE SAME STYLE
(DATASET1, DATASET2, PARAM1, PARAM2,...)

Marking an episode as watched twice doesn't log properly, takes too long

# Method getShowID (showName)
myShows.where(:name => "The Blacklist").to_a[0][:id]
if it doesnt find anything -> try Web.searchShowFast

# Ruby classes are only used to serve as a bridge between the API-database or the user-database

# Import from a csv/file

# Method that gives you ID of a show passing its name? Necessary?

#Database.addEpisodes(TVShow.new("The Player", "2244"), episodes)

#puts Database.getEpisodes(episodes, 2244).to_a #[0]
#puts Database.getEpisodes(episodes, 2244).to_a[0][:airdate]

=end