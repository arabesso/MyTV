module Web

	# ************************************************************+
	# **                      TVMaze                             **
	# ************************************************************+
	
	TVMAZE_URL = 	"http://api.tvmaze.com"

	def Web.getShowID(showName)
		url = TVMAZE_URL + "/singlesearch/shows?q=" + showName
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
		url = TVMAZE_URL + "/singlesearch/shows?q=" + showName # &embed=episodes
		resp = Net::HTTP.get_response(URI.parse(url))
		resp_text = resp.body

		obj = JSON.parse(resp_text)
	end

	def Web.getEpisodes(showID)
		url = TVMAZE_URL + "/shows/" + showID.to_s + "/episodes" #?specials=1
		resp = Net::HTTP.get_response(URI.parse(url))
		resp_text = resp.body

		obj = JSON.parse(resp_text)
	end

	# ************************************************************+
	# **                      KickassTorrents                    **
	# ************************************************************+
	# Choose 720p
	KAT_URL = 	"https://kat.cr"
	GROUPS = ["LOL", "BATV", "DIMENSION", "FLEET", "KILLERS"]

	def Web.getMagnetLink(showname, season, episode)
		search = Array.new
		search << showname.split(" ")
		
		if season < 10
			seasonnum = "S0" + season.to_s
		else
			seasonnum = "S" + season.to_s
		end

			search << seasonnum

		if episode < 10
			epnum = "E0" + episode.to_s
		else
			epnum = "E" + episode.to_s
		end

		search = search.join("%20")
		search << epnum

		url = KAT_URL + "/usearch/" + search.to_s
		puts url
		resp = Net::HTTP.get_response(URI.parse(url))
		resp_text = resp.body
	end

	def Web.getTorrentLink()
		
	end

	# ************************************************************+
	# **                        Addic7ed                         **
	# ************************************************************+
	ADDIC_URL = 	"http://Addic7ed.org"
	

	# Choose 720p
end

=begin
	
	def Web.searchShow(showName)
		url = TVMAZE_URL + "/search/shows?q=" + showName
		resp = Net::HTTP.get_response(URI.parse(url))
		resp_text = resp.body

		obj = JSON.parse(resp_text)
	end

	def Web.getSchedule(date) # YYYY-MM-DD
		url = TVMAZE_URL + "/schedule?country=US&date=" + date
		resp = Net::HTTP.get_response(URI.parse(url))
		resp_text = resp.body

		obj = JSON.parse(resp_text)
	end
=end