module Database

	# DATABASE_NAME = "MyTV.db"
	# DB = Sequel.connect('sqlite://MyTV.db')

	# Add a new show and its episodes. Receives a string and the dataset myShows and episodes as parameters
	def Database.addShow(showName, dataset1, dataset2)
		# Finding the show
		obj = Web.searchShowFast(showName)
		newshow = TVShow.new(obj['name'], obj['id'])
		dataset1.insert(:name => newshow.getName())
		Database.addEpisodes(newshow, dataset2)
	end

	# Add episodes to the database. Receives a TVShow and the dataset episodes as parameters
	def Database.addEpisodes (show, dataset)
		show.getEpisodes().each do |i|
	 		dataset.insert(:title => i.getTitle, :seasonNumber => i.getSeason, :episodeNumber => i.getNumber, :airdate => i.getAirdate)
	 	end
	end

	# Creates the TVShows and Episodes tables
	def Database.createTables

		DB.create_table :TVShows do
  		primary_key :id #REPLACE BY TVMAZE ID? ALTERNATIVE PRIMARY KEY
  		String :name
		end

		DB.create_table :Episodes do
		  primary_key :id
		  String :title
		  Integer :seasonNumber
		  Integer :episodeNumber
		  Date :airdate
		  Boolean :watched
		  Integer :show_id #FOREIGN KEY REFERENCES TVSHOWS ID
		end

	end

	# Returns the current number of entries in the given dataset
	def Database.numberOfEntries (dataset)
		dataset.count
	end

end