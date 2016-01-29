module MyTV
	class Web


		# ************************************************************+
		# **                      TVMaze                             **
		# ************************************************************+
		
		TVMAZE_URL = 	"http://api.tvmaze.com"

		def Web.get_show_id(show_name)
			url = TVMAZE_URL + "/singlesearch/shows?q=" + show_name # &embed=episodes

			agent = Mechanize.new
			page = agent.get(url).content
			
			obj = JSON.parse(page)

			obj['id']

		end

		##
		# "id"=>2244
		# "status"=>"Running"
		# "schedule"=>{"time"=>"22:00", "days"=>["Thursday"]}
		# "updated"=>1443264033
		# "_links"=>{previousepisode"=>{"href"=>"http://api.tvmaze.com/episodes/182003"}, "nextepisode"=>{"href"=>"http://api.tvmaze.com/episodes/215496"}}
		def Web.search_show(show_name)
			url = TVMAZE_URL + "/singlesearch/shows?q=" + show_name # &embed=episodes

			agent = Mechanize.new
			page = agent.get(url).content
			
			obj = JSON.parse(page)

			return obj
		end

		def Web.get_episodes(showID)
			url = TVMAZE_URL + "/shows/" + showID.to_s + "/episodes" #?specials=1
			
			agent = Mechanize.new
			page = agent.get(url).content
			
			obj = JSON.parse(page)
			
			return obj
			
		end

		# ************************************************************+
		# **                      RARBG                              **
		# ************************************************************+
		# Choose 720p
		TPB_URL = 	"https://thehiddenbay.me/search/"
		GROUPS = ["LOL", "BATV", "DIMENSION", "FLEET", "KILLERS"]

		def Web.get_magnet_link(season, episode, showname)
			search = Array.new
			search << showname.split(" ")
			
			if season.to_i < 10
				seasonnum = "S0" + season.to_s
			else
				seasonnum = "S" + season.to_s
			end

			search << seasonnum

			if episode.to_i < 10
				epnum = "E0" + episode.to_s
			else
				epnum = "E" + episode.to_s
			end

			search = search.join("+")
			search << epnum
			# Add ettv/rartv?
			search << "/0/7/0"
			uri = TPB_URL + search.to_s
			agent = Mechanize.new
			page = agent.get(uri)
			
			page.links_with(:text => "Magnet link")[0].href
		
			# Parse for: table id searchResult
			# tbody > tr > td (second one) > first link
			# or tbody > tr > td (second one) > div detname > first link.click > parse new page

		rescue => e
			$logger.error("Exception in get_magnet_link : " + e.message + " [" + e.class.to_s + "]")
			puts "Error: " + e.message + " [" + e.class.to_s + "]"

		end

		def Web.get_torrent_link()
			
		end

		# ************************************************************+
		# **                        Addic7ed                         **
		# ************************************************************+
		ADD_URL = 	"http://Addic7ed.org"

		def get_subtitles()
			uri = ADD_URL# Full url
			agent = Mechanize.new
			page = agent.get(uri)
			
		rescue => e
			$logger.error("Exception in get_subtitles : " + e.message + " [" + e.class.to_s + "]")
			puts "Error: " + e.message + " [" + e.class.to_s + "]"	
		end

	end
end

=begin

<tr class="lista2">
	<td align="left" class="lista" width="48" style="width:48px;">
		<a href="/torrents.php?category=18"><img src="//dyncdn.me/static/20/images/categories/cat_new18.gif" border="0" alt="" /></a></td>
		<td align="left" class="lista">
			<a onmouseover="return overlib('<img src=\'//dyncdn.me/static/20/tvdb/314002_small.jpg\' border=0>')" onmouseout="return nd();" 
				href="/torrent/kh6l95s" title="The Player 2015 S01E01 HDTV XviD-FUM[ettv]">
	
	def Web.searchShow(show_name)
		url = TVMAZE_URL + "/search/shows?q=" + show_name
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