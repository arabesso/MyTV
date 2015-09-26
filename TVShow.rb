class TVShow
	def initialize(n, e, s)
		@name, @episodes, @status = n, e, s #episodes array/list
	end

	def getName
		@name
	end

	def getEpisodes
		@episodes
	end

	def getStatus
		@status #watched, pending...?
	end

	def loadEpisodes(episodeList)
		@episodes = episodeList
	end

	def to_s # use these methods to create a hash for the DB?
		
	end
end