module Web

	BASE_URL = 	"http://api.tvmaze.com"

	def Web.searchShow(showName)
		url = BASE_URL + "/search/shows?q=" + showName
		resp = Net::HTTP.get_response(URI.parse(url))
		resp_text = resp.body

		obj = JSON.parse(resp_text)
	end

	def Web.getShowID(showName)
		url = BASE_URL + "/singlesearch/shows?q=" + showName
		resp = Net::HTTP.get_response(URI.parse(url))
		resp_text = resp.body

		obj = JSON.parse(resp_text)

		obj['id']
	
	end

	##
	# "id"=>2244
	# "status"=>"Running"
	# "schedule"=>{"time"=>"22:00", "days"=>["Thursday"]}
	# "updated"=>1443264033
	# "_links"=>{previousepisode"=>{"href"=>"http://api.tvmaze.com/episodes/182003"}, "nextepisode"=>{"href"=>"http://api.tvmaze.com/episodes/215496"}}
	def Web.searchShowFast(showName)
		url = BASE_URL + "/singlesearch/shows?q=" + showName # &embed=episodes
		resp = Net::HTTP.get_response(URI.parse(url))
		resp_text = resp.body

		obj = JSON.parse(resp_text)
	end
	def Web.getSchedule(date) # YYYY-MM-DD
		url = BASE_URL + "/schedule?country=US&date=" + date
		resp = Net::HTTP.get_response(URI.parse(url))
		resp_text = resp.body

		obj = JSON.parse(resp_text)
	end

	def Web.getEpisodes(showID)
		url = BASE_URL + "/shows/" + showID.to_s + "/episodes" #?specials=1
		resp = Net::HTTP.get_response(URI.parse(url))
		resp_text = resp.body

		obj = JSON.parse(resp_text)
	end
end
#  For example, http://api.tvmaze.com/shows/1?embed=episodes will serve 
# the show's main information and its episode list in one single response. 
# http://api.tvmaze.com/shows/1?embed=nextepisode would embed the details 
# of that show's upcoming episode in the response, but only if one such 
# episode currently exists. Embedding multiple links is possible with the
# array syntax: http://api.tvmaze.com/shows/1?embed[]=episodes&embed[]=cast
