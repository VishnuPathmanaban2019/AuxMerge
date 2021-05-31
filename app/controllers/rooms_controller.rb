class RoomsController < ApplicationController
    before_action :set_room, only: [:show]

    def new 
        @room = Room.new
        @room.creator_id = params[:creator_id] if params[:creator_id]
    end    

    def show 
        @users = @room.users
        @user_room_relations = @room.user_room_relations
        @user_room_relations.each do |urr|
            urr.selected_playlists.drop(1).each do |playlist_id|
                playlist = RSpotify::Playlist.find_by_id(playlist_id)
                playlist.tracks.each do |track|
                    if Track.where(identifier: track.id).empty?
                        db_track = Track.create(:identifier => track.id,:name => track.name)
                        TrackRoomRelation.create(:track_id => db_track.id, :room_id => urr.room_id, :user_id => urr.user_id, :score => 1)
                    else 
                        db_track = Track.where(identifier: track.id).first
                        if !(TrackRoomRelation.where(:track_id => db_track.id, :room_id => urr.room_id, :user_id => urr.user_id).empty?)
                            # if track exists in room but same user (do nothing)
                        elsif !(TrackRoomRelation.where(:track_id => db_track.id, :room_id => urr.room_id).empty?)
                            trr = TrackRoomRelation.where(:track_id => db_track.id, :room_id => urr.room_id).first
                            trr.update_attribute(:score, trr.score + 1)
                            trr.update_attribute(:user_id, urr.user_id)
                            trr.reload
                        else 
                            TrackRoomRelation.create(:track_id => db_track.id, :room_id => urr.room_id, :user_id => urr.user_id, :score => 1)
                        end
                    end
                end
            end
        end
        @room.reload
        @track_room_relations = @room.track_room_relations
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