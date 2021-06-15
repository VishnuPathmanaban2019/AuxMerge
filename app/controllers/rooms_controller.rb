class RoomsController < ApplicationController
    before_action :set_room, only: [:show]

    def new 
        @room = Room.new
        @room.creator_id = params[:creator_id] if params[:creator_id]
    end    

    def show 
        @users = @room.users
        @user_room_relations = @room.user_room_relations
    end

    def playlist
        @room = Room.find(params[:id])
        @users = @room.users
        @user_room_relations = @room.user_room_relations 

        @genre_rank_ceil = Float::INFINITY
        # TRR creation loop
        @user_room_relations.each do |urr|
            urr.artist_scores = Hash.new(0)
            urr.selected_playlists.drop(1).each do |playlist_id|
                playlist = RSpotify::Playlist.find_by_id(playlist_id)
                @genre_rank_ceil = [@genre_rank_ceil,playlist.tracks.length].min
                playlist.tracks.each do |track|

                    # artist and genre score updates
                    artists = track.artists
                    artists.each do |artist|
                        # potential speed loss with not using update_attribute
                        urr.artist_scores[artist.name] = urr.artist_scores.fetch(artist.name, 0) + 1
                    end
                    artists = artists.map { |artist| artist.name }
                    genre_list = track.artists.first.genres
                    genre_list.each do |genre|
                        urr.genre_scores[genre] = urr.genre_scores.fetch(genre, 0) + 1
                    end

                    if Track.where(:identifier => track.id).empty?
                        db_track = Track.create(:identifier => track.id, :name => track.name, :authors => artists, :genres => genre_list)
                        TrackRoomRelation.create(:track_id => db_track.id, :room_id => urr.room_id, :listeners => [urr.user_id], :score => 1)
                    else 
                        db_track = Track.where(:identifier => track.id).first
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
                end
            end
        end

        # make final playlist
        @playlist_songs = []

        # find common tracks
        @track_room_relations = @room.track_room_relations
        @common_trr = @track_room_relations.select { |trr| trr.score >= @users.length } 
        @common_tracks = []
        @common_trr.each do |trr|
            @common_tracks.append(trr.track.identifier)
        end

        @playlist_songs.append(@common_tracks).flatten.uniq

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
        
        # search for possible collabs to add
        @unique_artists = []
        @user_room_relations.each do |urr|
            @user_unique_artists = []
            user_artists = urr.artist_scores.sort_by {|artist, score| -score}.map { |artist,score| artist }
            user_artists.each do |artist|
                if !(@top_artists.include? artist)
                    @user_unique_artists.append(artist)
                end
                if @user_unique_artists.length >= 3
                    break
                end 
            end
            @unique_artists.append(@user_unique_artists)
        end
        head, *rest = @unique_artists 
        @collab_combos = head.product(*rest)
        @collab_combos = @collab_combos
        
        @collabs_found = []
        if @users.length <= 3
            @collab_combos.each do |combo|
                collab_tracks = RSpotify::Track.search(combo.join(', ')).sort_by {|track| -track.popularity}
                if !(collab_tracks.empty?)
                    includes_all_artists = true 
                    combo.each do |artist|
                        if !(collab_tracks.first.artists.map { |artist| artist.name }.include? artist)
                            includes_all_artists = false
                        end 
                    end
                    if includes_all_artists
                        @collabs_found.append(collab_tracks.first.id)
                    end
                end 
            end
        end

        @playlist_songs.append(@collabs_found).flatten.uniq

        # create top artist songs array with weighted probabilities based on listeners, then randomly sample and remove duplicates
        @top_artists_songs = []
        @top_artists.each do |artist|
            @track_room_relations.each do |trr|
                if (trr.track.authors.include? artist) and (!(@playlist_songs.include? trr.track.identifier)) and (!(@top_artists_songs.include? trr.track.identifier))
                    trr.listeners.length.times do |i|
                        @top_artists_songs.append(trr.track.identifier)
                    end
                end
            end
        end
        @top_artists_selection = @top_artists_songs.sample(100 - @playlist_songs.length)
            
        @playlist_songs.append(@top_artists_selection).flatten.uniq

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
            @final_genre_scores = @final_genre_scores.sort_by {|genre,score| -score}
            @top_genres = @final_genre_scores.select { |genre,score| score >= (0.1*@genre_rank_ceil) }.map { |genre,score| genre }

            # create top genre songs array with weighted probabilities based on listeners, then randomly sample and remove duplicates
            @top_genres_songs = []
            @top_genres.each do |genre|
                @track_room_relations.each do |trr|
                    if (trr.track.genres.include? genre) and (!(@playlist_songs.include? trr.track.identifier)) and (!(@top_genres_songs.include? trr.track.identifier))
                        trr.listeners.length.times do |i|
                            @top_genres_songs.append(trr.track.identifier)
                        end
                    end
                end
            end
            @top_genres_selection = @top_genres_songs.sample(100 - @playlist_songs.length)

            @playlist_songs.append(@top_genres_selection).flatten.uniq
        end

        @playlist_songs = @playlist_songs[0..99]
        @playlist_songs = @playlist_songs.flatten.uniq.map { |id| RSpotify::Track.find(id) }

        # fill up playlist with recommendation
        if @playlist_songs.length < 100 and (@common_tracks.length > 0 or @top_artists.length > 0) 
            remainder = 100 - @playlist_songs.length
            if @common_tracks.length >= 5
                recommendation = RSpotify::Recommendations.generate(limit: remainder, seed_tracks: @common_tracks[0..4])
            else 
                n = 5 - @common_tracks.length
                artist_names = @top_artists[0..(n-1)]
                artist_seeds = []
                artist_names.each do |name|
                    # need to optimize later, maybe memoization
                    artist_seeds.append(RSpotify::Artist.search(name).first.id)
                end
                recommendation = RSpotify::Recommendations.generate(limit: remainder, seed_tracks: @common_tracks[0..4], seed_artists: artist_seeds)
            end
            @playlist_songs.append(recommendation.tracks).flatten.uniq
        end
        
        # no seeds case (no common songs or artists)
        # songs with more than one listener
        if @playlist_songs.length < 100
            remainder = 100 - @playlist_songs.length
            popular_trr = @track_room_relations.select {|trr| trr.listeners.length > 1 }.sort_by {|trr| -trr.listeners.length}
            popular_trr = popular_trr[0..(remainder-1)]
            @playlist_songs.append(popular_trr.map { |trr| RSpotify::Track.find(trr.track.identifier) }).flatten.uniq
        end

        # still need more
        if @playlist_songs.length < 100
            remainder = 100 - @playlist_songs.length
            for i in 0..(@users.length-1)
                users = @users.to_a
                user = users[i]
                selected_trr = TrackRoomRelation.where(:listeners => [user.id]).sample(remainder/users.length)
                @playlist_songs.append(selected_trr.map { |trr| RSpotify::Track.find(trr.track.identifier) }).flatten.uniq
            end
        end

        # put shuffle after slice later
        @playlist_songs = @playlist_songs[0..99]
        @playlist_songs = @playlist_songs.shuffle

        desc = RSpotify::User.new(@users.first.user_hash).display_name
        @users[1..@users.length].each do |user|
            desc = desc + ' + ' + RSpotify::User.new(user.user_hash).display_name
        end

        playlist = RSpotify::User.new(User.find(@room.creator_id).user_hash).create_playlist!(desc)
        playlist.add_tracks!(@playlist_songs)
    end

    def create
        @room = Room.new(room_params)

        if @room.save
            
            @creator = User.find(@room.creator_id)
            UserRoomRelation.create(:user_id => @creator.id,:room_id => @room.id, :selected_playlists => @room.creator_playlists)

            redirect_to room_path(@room)
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