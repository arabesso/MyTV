class Episode
	def initialize (n, s, e, air)
		@title, @seasonNumber, @episodeNumber = n, s, e
		
		@airdate = Date.parse(air)#.next  # YYYY-MM-DD
		@watched = false
		
	end

	def getTitle
		@title
	end

	def getSeason
		@seasonNumber
	end

	def getNumber
		@episodeNumber
	end

	def getAirdate
		@airdate
	end

	def watched
		 @watched=true
		
	end

end