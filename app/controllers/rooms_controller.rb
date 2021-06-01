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
        @user_room_relations = @room.user_room_relations 

        @user_room_relations.each do |urr|
            urr.selected_playlists.drop(1).each do |playlist_id|
                playlist = RSpotify::Playlist.find_by_id(playlist_id)
                playlist.tracks.each do |track|
                    if Track.where(identifier: track.id).empty?
                        db_track = Track.create(:identifier => track.id,:name => track.name)
                        TrackRoomRelation.create(:track_id => db_track.id, :room_id => urr.room_id, :listeners => [urr.user_id], :score => 1)
                    else 
                        db_track = Track.where(identifier: track.id).first
                        if !(TrackRoomRelation.where(:track_id => db_track.id, :room_id => urr.room_id).empty?)
                            trr = TrackRoomRelation.where(:track_id => db_track.id, :room_id => urr.room_id).first
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
        @common_ttr = @track_room_relations.select { |trr| trr.score > 1 } 
        @common_tracks = []
        @common_ttr.each do |ttr|
            if (@common_tracks.length < 5)
                @common_tracks.append(ttr.track.identifier)
            end
        end
        
        @recommended_tracks = []
        if !(@common_tracks.empty?)
            @recommended_tracks = RSpotify::Recommendations.generate(seed_tracks: @common_tracks).tracks
            playlist = RSpotify::User.new(User.find(@room.creator_id).user_hash).create_playlist!('Group Playlist')
            playlist.add_tracks!(@recommended_tracks)
        end
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