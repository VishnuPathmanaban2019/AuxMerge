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

        @user_room_relations.each do |urr|
            urr.artist_scores = Hash.new(0)
            urr.selected_playlists.drop(1).each do |playlist_id|
                playlist = RSpotify::Playlist.find_by_id(playlist_id)
                playlist.tracks.each do |track|

                    # artist score updates
                    artists = track.artists.map { |artist| artist.name }
                    artists.each do |artist|
                        # potential issue with not using update_attribute
                        urr.artist_scores[artist] = urr.artist_scores.fetch(artist, 0) + 1
                    end

                    if Track.where(identifier: track.id).empty?
                        db_track = Track.create(:identifier => track.id, :name => track.name, :authors => artists)
                        TrackRoomRelation.create(:track_id => db_track.id, :room_id => urr.room_id, :listeners => [urr.user_id], :score => 1)
                    else 
                        db_track = Track.where(identifier: track.id).first
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

        @track_room_relations = @room.track_room_relations
        @common_trr = @track_room_relations.select { |trr| trr.score >= @users.length } 
        @common_tracks = []
        @common_trr.each do |trr|
            @common_tracks.append(trr.track.identifier)
        end

        min_length = @user_room_relations.first.artist_scores.length
        min_urr = @user_room_relations.first
        @user_room_relations.each do |urr|
            urr_length = urr.artist_scores.length
            if urr_length < min_length
                min_length = urr_length 
                min_urr = urr
            end
        end

        # will optimize later
        @final_artist_scores = Hash.new(0)
        min_urr.artist_scores.each do |artist,score|
            room_artist_scores = []
            @user_room_relations.each do |urr|
                room_artist_scores.append(urr.artist_scores.fetch(artist, 0))
            end
            @final_artist_scores[artist] = room_artist_scores.min
        end
        @final_artist_scores = @final_artist_scores.sort_by {|artist, score| -score}

        @top_artists = @final_artist_scores.map { |artist,score| artist }[0..4]
        top_artists_songs = []
        @top_artists.each do |artist|
            @track_room_relations.each do |trr|
                if (trr.track.authors.include? artist) and (!(@common_tracks.include? trr.track.identifier)) and (!(top_artists_songs.include? trr.track.identifier))
                    trr.listeners.length.times do |i|
                        top_artists_songs.append(trr.track.identifier)
                    end
                end
            end
        end
        @top_artists_selection = top_artists_songs.sample(50)

        @playlist_songs = []
        @playlist_songs.append(@common_tracks)
        @playlist_songs.append(@top_artists_selection)
        @playlist_songs = @playlist_songs.flatten.shuffle.map { |id| RSpotify::Track.find(id) }

        desc = RSpotify::User.new(@users.first.user_hash).display_name
        @users[1..@users.length].each do |user|
            desc = desc + ' + ' + RSpotify::User.new(user.user_hash).display_name
        end

        playlist = RSpotify::User.new(User.find(@room.creator_id).user_hash).create_playlist!(desc)
        playlist.add_tracks!(@playlist_songs)

        # @recommended_tracks = []
        # if !(@common_tracks.empty?)
        #     @recommended_tracks = RSpotify::Recommendations.generate(seed_tracks: @common_tracks).tracks
        #     playlist = RSpotify::User.new(User.find(@room.creator_id).user_hash).create_playlist!('Group Playlist')
        #     playlist.add_tracks!(@recommended_tracks)
        # end
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