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
	QUAL = "-720p" # Change to 720p to get links to 720p torrents

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
		search << "%20"
		search << "ettv"
		search << "%20"
		search << QUAL

		=begin

		<tr class="odd" id="torrent_quantico_s01e02_ettv_720p11361274">
						<td>
						<div class="iaconbox center floatright">
								<a rel="11361274,0" class="icommentjs icon16" href="/quantico-s01e02-hdtv-x264-lol-ettv-t11361274.html#comment"><em style="font-size: 12px; margin: 0 4px 0 4px;" class="iconvalue">261</em><i class="ka ka-comment"></i></a>				<a class="icon16" href="/quantico-s01e02-hdtv-x264-lol-ettv-t11361274.html" title="Verified Torrent"><i class="ka ka16 ka-verify ka-green"></i></a>                                <a href="#" data-nop onclick="sc('redirect', '_b91ea3142d712c64815b8c569ca90f34', { 'name': 'Quantico%20S01E02%20HDTV%20x264-LOL%5Bettv%5D', 'magnet': 'magnet%3A%3Fxt%3Durn%3Abtih%3A11F77466C2EE04FBA543338FB7A56BEC962D4EF2%26dn%3Dquantico%2Bs01e02%2Bhdtv%2Bx264%2Blol%2Bettv%26tr%3Dudp%253A%252F%252Ftracker.publicbt.com%252Fannounce%26tr%3Dudp%253A%252F%252Fopen.demonii.com%253A1337' }); return false;" class="icon16"><i class="ka ka16 ka-arrow-down blueButton"></i></a>
								<a data-nop title="Torrent magnet link" href="magnet:?xt=urn:btih:11F77466C2EE04FBA543338FB7A56BEC962D4EF2&dn=quantico+s01e02+hdtv+x264+lol+ettv&tr=udp%3A%2F%2Ftracker.publicbt.com%2Fannounce&tr=udp%3A%2F%2Fopen.demonii.com%3A1337" class="icon16"><i class="ka ka16 ka-magnet"></i></a>

		url = KAT_URL + "/usearch/" + search.to_s + "/"
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