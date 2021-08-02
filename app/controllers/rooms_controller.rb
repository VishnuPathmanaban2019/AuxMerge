class RoomsController < ApplicationController
    before_action :set_room, only: [:show, :leave, :playlist]

    def new 
        if !(params[:creator_id].nil?) and session[:current_user_id] == params[:creator_id].to_i
            @room = Room.new
            @room.creator_id = params[:creator_id] if params[:creator_id]
        else 
            flash[:notice] = "You do not have access to this section."
            redirect_to home_path
        end
    end    

    def show 
        @users = @room.users
        @user_ids = @users.map { |user| user.id }
        if !(params[:user_id].nil?) and (@user_ids.include? session[:current_user_id]) and (params[:user_id].to_i == session[:current_user_id])
            @user_id = params[:user_id] if params[:user_id]
            @user = User.where(:id => @user_id).first
            @user.update_attribute(:downloaded, false)

            @user_room_relations = @room.user_room_relations
            @user_tracks_dict = Hash.new
            @user_room_relations.each do |urr|
                @names_arr = []
                urr.selected_playlists.drop(1).each do |playlist_id|
                    begin
                        playlist = RSpotify::Playlist.find_by_id(playlist_id)
                        @names_arr = @names_arr + [playlist.name]
                    rescue Exception => exc
                        
                    end
                end
                @user_tracks_dict[urr.user.id] = @names_arr
            end
        else 
            flash[:notice] = "You do not have access to this section."
            redirect_to home_path
        end
    end

    def leave
        @users = @room.users
        @user_ids = @users.map { |user| user.id }
        if !(params[:user_id].nil?) and (@user_ids.include? session[:current_user_id]) and (params[:user_id].to_i == session[:current_user_id])
            @user_id = params[:user_id] if params[:user_id]
            @user = User.find(@user_id)
            @user.update_attribute(:valid_rooms, @user.valid_rooms - [@room.id])
            @room.update_attribute(:valid_users, @room.valid_users - [@user.id])
            @room.user_room_relations.where(:user_id => @user_id).first.destroy
            redirect_to user_path(@user)
        else 
            flash[:notice] = "You do not have access to this section."
            redirect_to home_path
        end
    end

    def playlist
        @users = @room.users
        @user_ids = @users.map { |user| user.id }
        if !(params[:user_id].nil?) and (@user_ids.include? session[:current_user_id]) and (params[:user_id].to_i == session[:current_user_id])
            @user_id = params[:user_id] if params[:user_id]
            @user = User.where(:id => @user_id).first

            @user_room_relations = @room.user_room_relations 

            if !(@user.downloaded)
                # random index generation
                @max_requests = 100
                @sample_num = @max_requests/@users.length
                @user_tracks_dict = Hash.new
                @rand_dict = Hash.new
                @user_room_relations.each do |urr|
                    @tracks_arr = []
                    urr.selected_playlists.drop(1).each do |playlist_id|
                        begin
                            playlist = RSpotify::Playlist.find_by_id(playlist_id)
                            @tracks_arr = @tracks_arr + playlist.tracks
                        rescue Exception => exc
                            
                        end
                    end
                    @total_length = @tracks_arr.length

                    if @total_length < @sample_num
                        rand_arr = [true] * @total_length
                    else
                        rand_arr = [false] * @total_length

                        already_selected = []
                        @sample_num.times do
                            i = rand(@total_length)
                            while (already_selected.include? i) do
                                i = rand(@total_length)
                            end
                            rand_arr[i] = true
                            already_selected.append(i)
                        end
                    end
                    @rand_dict[urr.user.id] = rand_arr
                    @user_tracks_dict[urr.user.id] = @tracks_arr
                end
                
                # TRR creation loop
                @genre_count = 0
                @user_room_relations.each do |urr|
                    counter = 0
                    @rand_arr = @rand_dict[urr.user.id]
                    urr.artist_scores = Hash.new(0)
                    @user_tracks_dict[urr.user.id].each do |track|

                        # artist and genre score updates
                        artists_objs = track.artists
                        artists = artists_objs.map { |artist| artist.id }
                        artists.each do |artist|
                            # potential speed loss with not using update_attribute
                            urr.artist_scores[artist] = urr.artist_scores.fetch(artist, 0) + 1
                        end

                        if @rand_arr[counter]
                            genre_list = artists_objs.first.genres
                            if !(genre_list).nil?
                                genre_list.each do |genre|
                                    urr.genre_scores[genre] = urr.genre_scores.fetch(genre, 0) + 1
                                end
                                @genre_count = @genre_count + genre_list.length
                            else
                                genre_list = []
                            end
                        else
                            genre_list = []
                        end

                        track_id = track.id
                        if Track.where(:identifier => track_id).empty?
                            db_track = Track.create(:uri => track.uri, :identifier => track_id, :authors => artists, :genres => genre_list)
                            TrackRoomRelation.create(:track_id => db_track.id, :room_id => urr.room_id, :listeners => [urr.user_id], :score => 1)
                        else 
                            db_track = Track.where(:identifier => track_id).first
                            trr = TrackRoomRelation.where(:track_id => db_track.id, :room_id => urr.room_id)
                            if !(trr.empty?)
                                trr = trr.first
                                if !(trr.listeners.include? urr.user_id)
                                    trr.update_attribute(:score, trr.score + 1)
                                    trr.update_attribute(:listeners, trr.listeners.append(urr.user_id))
                                end
                            else 
                                TrackRoomRelation.create(:track_id => db_track.id, :room_id => urr.room_id, :listeners => [urr.user_id], :score => 1)
                            end
                        end
                        counter = counter + 1
                    end
                end

                # make final playlist
                @playlist_songs = []

                # find common tracks
                @track_room_relations = @room.track_room_relations
                @common_trr = @track_room_relations.select { |trr| trr.score >= @users.length }
                @common_track_ids = @common_trr.map { |trr| trr.track.identifier }
                @common_tracks = @common_trr.map { |trr| trr.track.uri }

                @playlist_songs = @common_tracks[0..99]

                if @playlist_songs.length < 100
                    # artist ranking
                    # find user with least artists to loop through in next step
                    min_length = @user_room_relations.first.artist_scores.length
                    min_urr = @user_room_relations.first
                    @user_room_relations.each do |urr|
                        urr_length = urr.artist_scores.length
                        if urr_length < min_length
                            min_length = urr_length 
                            min_urr = urr
                        end
                    end

                    # calculate artist scores for the room with min method
                    @final_artist_scores = Hash.new(0)
                    min_urr.artist_scores.each do |artist,score|
                        room_artist_scores = []
                        @user_room_relations.each do |urr|
                            room_artist_scores.append(urr.artist_scores.fetch(artist, 0))
                        end
                        @final_artist_scores[artist] = room_artist_scores.min
                    end
                    @final_artist_scores = @final_artist_scores.sort_by {|artist, score| -score}
                    @top_artists = @final_artist_scores.select { |artist,score| score > 0 }.map { |artist,score| artist }

                    # create top artist songs array with weighted probabilities based on listeners, then randomly sample and remove duplicates
                    @top_artists_songs = []
                    @top_artists.each do |artist|
                        @track_room_relations.each do |trr|
                            if (trr.track.authors.include? artist) and (!(@playlist_songs.include? trr.track.uri)) and (!(@top_artists_songs.include? trr.track.uri))
                                trr.listeners.length.times do |i|
                                    @top_artists_songs.append(trr.track.uri)
                                end
                            end
                        end
                    end
                    @top_artists_selection = @top_artists_songs.sample(100 - @playlist_songs.length)
                        
                    @playlist_songs = @playlist_songs + @top_artists_selection
                    @playlist_songs = @playlist_songs.uniq
                end

                if @playlist_songs.length < 100
                    # genre ranking
                    # find user with least genres to loop through in next step
                    min_length = @user_room_relations.first.genre_scores.length
                    min_urr = @user_room_relations.first
                    @user_room_relations.each do |urr|
                        urr_length = urr.genre_scores.length
                        if urr_length < min_length
                            min_length = urr_length 
                            min_urr = urr
                        end
                    end

                    # calculate genre scores for the room with min method
                    @final_genre_scores = Hash.new(0)
                    min_urr.genre_scores.each do |genre,score|
                        room_genre_scores = []
                        @user_room_relations.each do |urr|
                            room_genre_scores.append(urr.genre_scores.fetch(genre, 0))
                        end
                        @final_genre_scores[genre] = room_genre_scores.min
                    end
                    @top_genres = @final_genre_scores.select { |genre,score| score >= 0.05*@genre_count }.map { |genre,score| genre }

                    # create top genre songs array with weighted probabilities based on listeners, then randomly sample and remove duplicates
                    @top_genres_songs = []
                    @top_genres.each do |genre|
                        @track_room_relations.each do |trr|
                            if (trr.track.genres.include? genre) and (!(@playlist_songs.include? trr.track.uri)) and (!(@top_genres_songs.include? trr.track.uri))
                                trr.listeners.length.times do |i|
                                    @top_genres_songs.append(trr.track.uri)
                                end
                            end
                        end
                    end
                    @top_genres_selection = @top_genres_songs.sample(100 - @playlist_songs.length)

                    @playlist_songs = @playlist_songs + @top_genres_selection
                    @playlist_songs = @playlist_songs.uniq
                end

                # fill up playlist with recommendation
                if @playlist_songs.length < 100 and (@common_tracks.length > 0 or @top_artists.length > 0) 
                    remainder = 100 - @playlist_songs.length
                    if @common_tracks.length >= 5
                        recommendation = RSpotify::Recommendations.generate(limit: remainder, seed_tracks: @common_track_ids[0..4])
                    else 
                        n = 5 - @common_tracks.length
                        artist_seeds = @top_artists[0..(n-1)]
                        recommendation = RSpotify::Recommendations.generate(limit: remainder, seed_tracks: @common_track_ids[0..4], seed_artists: artist_seeds)
                    end
                    @playlist_songs = @playlist_songs + (recommendation.tracks.map { |track| track.uri })
                    @playlist_songs = @playlist_songs.uniq
                end
                
                # no seeds case (no common songs or artists)
                # songs with more than one listener
                if @playlist_songs.length < 100
                    remainder = 100 - @playlist_songs.length
                    popular_trr = @track_room_relations.select {|trr| trr.listeners.length > 1 }.sort_by {|trr| -trr.listeners.length}
                    popular_trr = popular_trr[0..(remainder-1)]
                    @playlist_songs = @playlist_songs + (popular_trr.map { |trr| trr.track.uri })
                    @playlist_songs = @playlist_songs.uniq
                end

                # still need more
                if @playlist_songs.length < 100
                    remainder = 100 - @playlist_songs.length
                    for i in 0..(@users.length-1)
                        users = @users.to_a
                        user = users[i]
                        selected_trr = TrackRoomRelation.where(:listeners => [user.id]).sample(remainder/users.length)

                        @playlist_songs = @playlist_songs + (selected_trr.map { |trr| trr.track.uri })
                        @playlist_songs = @playlist_songs.uniq
                    end
                end

                # put shuffle after slice later
                # @playlist_songs = @playlist_songs.flatten.uniq
                @playlist_songs = @playlist_songs[0..99]
                @playlist_songs = @playlist_songs.shuffle

                # desc = @users.first.name
                # @users[1..@users.length].each do |user|
                #     desc = desc + ' + ' + user.name
                # end

                playlist = RSpotify::User.new(User.find(@user_id).user_hash).create_playlist!(@room.playlist_name)
                playlist.add_tracks!(@playlist_songs)
                @user.update_attribute(:downloaded, true)
                @playlist_url = 'https://open.spotify.com/playlist/' + playlist.id.to_s
            end
        else 
            flash[:notice] = "You do not have access to this section."
            redirect_to home_path
        end
    end

    def create
        @room = Room.new(room_params)

        if @room.save
            @creator = User.find(@room.creator_id)
            @room.update_attribute(:valid_users, @room.valid_users.append(@room.creator_id.to_i))
            redirect_to new_user_room_relation_path(user_id: @room.creator_id, room_id: @room.id)
        else
            # return to the 'new' form
            render action: 'new'
        end
    end

    private
    def set_room
        @room = Room.find(params[:id])
    end

    def room_params
        params.require(:room).permit(:password, :creator_id, creator_playlists:[])
    end
end