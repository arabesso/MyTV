module Database

	# DATABASE_NAME = "MyTV.db"
	# DB = Sequel.connect('sqlite://MyTV.db')

	# Add a new show and its episodes. Receives a string and the dataset myShows and episodes as parameters
	def Database.addShow(showName, dataset1, dataset2)
		# Finding the show
		obj = Web.searchShowFast(showName)
		$logger.info "Trying to add show <" + obj['name'] + ">"

		# Checks it's not in the database already
		if dataset1.where(:id => obj['id']).count == 1
			$logger.info "The show <" + obj['name'] + "> is already in the database"
		else
			newshow = TVShow.new(obj['name'], obj['id'])
			dataset1.insert(:id => newshow.getID, :name => newshow.getName)
			Database.addEpisodes(newshow, dataset2)
			$logger.info "...completed"
		end



	end

	# Add episodes to the database. Receives a TVShow and the dataset episodes as parameters
	def Database.addEpisodes (show, dataset)
		id = show.getID
		show.getEpisodes().each do |i|

			if dataset.where(:id => i.getID).count == 1
				$logger.info "The episode <" + i.getTitle + "> is already in the database"
			else
	 			dataset.insert(:id => i.getID, :title => i.getTitle, :seasonNumber => i.getSeason, :episodeNumber => i.getNumber, :airdate => i.getAirdate, :watched => false, :show_id => id)
				$logger.info "Added episode <" + i.getTitle + ">"
	 		end

	 	end
	end

	# Removes an episodes from the database.
	def Database.removeEntry (dataset, id)
		if dataset.where(:id => id).count == 1
			dataset.where(:id => id).delete
			$logger.info "Deleting entry with id <" + id.to_s + "> from dataset "
		else
			$logger.info "Couldn't delete entry with id <" + id.to_s + ">. Entry not found."
		end
		
	end

	# Creates the TVShows and Episodes tables
	def Database.createTables

		DB.create_table :TVShows do
  		Integer :id, :primary_key=>true #TVMAZE ID
  		String :name
		end

		DB.create_table :Episodes do
		  Integer :id, :primary_key=>true #tvmaze id
		  String :title
		  Integer :seasonNumber
		  Integer :episodeNumber
		  Date :airdate
		  Boolean :watched
		  Integer :show_id #FOREIGN KEY REFERENCES TVSHOWS ID
		end

	end

	# Returns a TVShow object. Receives the myShows dataset and the show id
	def Database.getShow (dataset, id)
		tvshowdata = dataset.where(:id => id).to_a
		TVShow.new(tvshowdata[0][:name], tvshowdata[0][:id])
	end

	# Returns the episodes of a specific show id. Receives the episodes dataset and a showid as parameters
	def Database.getEpisodes(dataset, showID)
		dataset.where(:show_id => showID)
		
	end

	# Returns the current number of entries in the given dataset
	def Database.numberOfEntries (dataset)
		dataset.count
	end

end