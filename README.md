# MyTV

## What is MyTV?

MyTV allows you to manage a local database of the shows you follow.

It keeps track of the episodes you watch and synchronises with the TVMaze API in order to keep the information updated.

MyTV will only keep in the database those episodes you haven't watched yet in order to save up space, with one exception. If you have watched all the episodes of a show, we'll keep the last one in order to make future updates faster.

## Installation

1. Install prerequisites (ruby and rubygems)
2. Download the files from GitHub.
3. Open the terminal and move to the folder where you placed the files.

##Compatibility

This app should work in every platform. However, the download functionality requires an UNIX-based system with Deluge installed.

## Usage

Execute the run executable in the terminal (./run). This will start the MyTV CLI.

Available commands:

Print all the available commands:

    help

Prints basic information about the shows stored

    print

Prints detailed information about each show and episode stored.

    print -a

Adds a show and all its episodes to the database

    addshow <showname>

Removes a show and all its episodes from the database

    removeshow <showname>

Updates the database. Pulls new episodes and removes episodes you've set as watched.

    update

Sets all the episodes for a show as watched.

    watched -s <showname>

Sets as watched the specified episode

    watched -e <season> <episode> <showname>

Sets as watched all the episodes from interval [episode1, episode2]

    watched -e <season> <episode1>-<episode2> <showname>

Prints the next non-watched episodes of each show ordered by airing date.

    nexteps

Imports the shows from a given file. One show name per line.

    import <filename>

Imports all the non-ignored shows in your MyEpisodes account.
	
    import -e <user> <pass>

Opens deluge with a magnet link for the specified show.

    download <season> <episode> <showname>

Exits the program

    exit

## Important files
mytv.db: This is the database where shows are stored. 

README.md: This file.

test.log: MyTV's log.

export: Standalone binary used to export your MyEpisodes show list. Can be called with the destination filename as an argument (shows.txt by default)

## Log

MyTV comes with a log that's tasked with recording almost everything the program does.

By default, only the events with a priority of "warn" or higher are stored. You can change this by editing MyTV.rb, and changing the line:

$logger.level = Logger::LEVEL

Where LEVEL is one of the following:
DEBUG, INFO, WARN, ERROR, FATAL

## Troubleshooting

###Common errors and solutions:

*getaddrinfo: Name or service not known*

Check your Internet connection

*Error: 404 => Net::HTTPNotFound for http://api.tvmaze.com/singlesearch/shows?q=---- -- unhandled response [Mechanize::ResponseCodeError]*

The show couldn't be found in TVMaze's database.

*undefined method `[]' for nil:NilClass [NoMethodError]*

When setting episodes as watched: episode isn't in the database

* Modifying the mytv.db file can result in errors when using mytv.
