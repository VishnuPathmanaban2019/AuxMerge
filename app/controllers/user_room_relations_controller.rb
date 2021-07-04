class UserRoomRelationsController < ApplicationController
    def new 
        if (!(params[:user_id].nil?) and !(params[:room_id].nil?) and 
            session[:current_user_id] == params[:user_id].to_i and User.find(params[:user_id].to_i).valid_rooms.include? params[:room_id].to_i)
            @user_room_relation = UserRoomRelation.new
            @user_room_relation.user_id = params[:user_id] if params[:user_id]
            @user_room_relation.room_id = params[:room_id] if params[:room_id]

            @playlists = RSpotify::User.new(@user_room_relation.user.user_hash).playlists
            @safe_playlists = []
            @playlists.each do |playlist|
                begin
                    safe_playlist = RSpotify::Playlist.find_by_id(playlist.id)
                    @safe_playlists.append(safe_playlist)
                rescue Exception => exc
                    
                end
            end
        else 
            flash[:notice] = "You do not have access to this section."
            redirect_to home_path
        end
    end    

    def create
        @user_room_relation = UserRoomRelation.new(user_room_relation_params)
        @all_urr = UserRoomRelation.where(:user_id => @user_room_relation.user_id, :room_id => @user_room_relation.room_id)
        if @all_urr.length > 0
            @all_urr.first.destroy
        end

        if @user_room_relation.save
            redirect_to room_path(@user_room_relation.room, :user_id => @user_room_relation.user_id)
        else
            # return to the 'new' form
            render action: 'new'
        end
    end

    private
    def user_room_relation_params
        params.require(:user_room_relation).permit(:user_id, :room_id, selected_playlists:[])
    end
end