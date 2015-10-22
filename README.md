# MyTV

## What is MyTV?

MyTV allows you to manage a local database of the shows you follow.

It keeps track of the episodes you watch and synchronises with the TVMaze API in order to keep the information updated.

MyTV will only keep in the database those episodes you haven't watched yet in order to save up space, with one exception. If you have watched all the episodes of a show, we'll keep the last one in order to make future updates faster.

## Installation

1. Install prerequisites (ruby)
2. Download the files from GitHub.
3. Open the terminal and move to the folder where you placed the files.
4. Run ruby MyTV.rb

## Usage

Execute the run executable in the terminal (./run). This will start the MyTV CLI.

Available commands:

help													Prints the available commands.
print													Prints basic information about the shows stored
	-a													Prints detailed information about each show and episode stored.
addshow <showname>						Searchs showname and adds it (along with its episodes) to the database.
removeshow <showname>					Removes showname and all its episodes from the database
update												Updates the database. Pulls new episodes, removes episodes you've set as watched.
watched
	-s <showname>								Sets all the episodes for showname as watched.
	-e <season> <episode> <showname>	Sets as watched the specified episode,
	-e <season> <episode1>-<episode2> <showname>	Sets as watched all the episodes in the given interval
nexteps												Prints the next non-watched episodes of each show ordered by airing date.
import
	<filename>									Imports the shows from a given file. One show name per line.
	-e <user> <pass>						Imports all the non-ignored shows in your MyEpisodes account.
download <season> <episode> <showname>	Opens deluge with a magnet link for the specified show.
exit													Exits the program


## Important files
MyTV.rb: Main program.
MyTV.db: This is the database where shows are stored.
README.md: This file
test.log: MyTV's log

## Log

MyTV comes with a log that's tasked with recording almost everything the program does.

By default, only the events with a priority of "warn" or higher are stored. You can change this by editing MyTV.rb, and changing the line:

$logger.level = Logger::LEVEL

Where LEVEL is one of the following:
DEBUG, INFO, WARN, ERROR, FATAL

## Troubleshooting

Common errors and solutions:

getaddrinfo: Name or service not known

Check your Internet connection

A JSON text must at least contain two octets!

The show couldn't be found in TVMaze's database.

undefined method `[]' for nil:NilClass

When setting episodes as watched: episode isn't in the database
