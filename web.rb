BASE_URL = 	"http://api.tvmaze.com"

def searchShow(showName)
	url = BASE_URL + "/search/shows?q=" + showName
end


def searchShowFast(showName)
	url = BASE_URL + "/singlesearch/shows?q=" + showName # &embed=episodes
end

def getSchedule(date) # YYYY-MM-DD
	url = BASE_URL + "/schedule?country=US&date=" + date
end

def getEpisodes(showID)
	url = BASE_URL + "/shows/" + showID + "/episodes" #?specials=1
end

#  For example, http://api.tvmaze.com/shows/1?embed=episodes will serve 
# the show's main information and its episode list in one single response. 
# http://api.tvmaze.com/shows/1?embed=nextepisode would embed the details 
# of that show's upcoming episode in the response, but only if one such 
# episode currently exists. Embedding multiple links is possible with the
# array syntax: http://api.tvmaze.com/shows/1?embed[]=episodes&embed[]=cast