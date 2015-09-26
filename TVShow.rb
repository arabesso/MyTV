class TVShow

	def initialize(n, id)
		@name = n
		@id = id
		loadEpisodes(id) #episodes array/list
		#@last_watched = last
		#loadEpisodes(episodeList)
	end

	def getName
		@name
	end

	def getEpisodes
		@episodes
	end

	def getID
		@id
	end

	def getStatus
		@status #watched, pending...?
	end

	def setStatus(st)
		@status = st #watched, pending...?
	end

	def loadEpisodes(id)
		@episodes = Array.new()
		episodelist = Web.getEpisodes(id)
		episodelist.each do |i|
   		@episodes << Episode.new(i['name'], i['season'], i['number'], i['airdate'], i['id'])
		end
	end

	def to_s # use these methods to create a hash for the DB?
		puts "This is the TV show named " + @name + " which has " + @episodes.size.to_s + " episodes"
	end
end