class UserRoomRelationsController < ApplicationController
    def new 
        @user_room_relation = UserRoomRelation.new
        @user_room_relation.user_id = params[:user_id] if params[:user_id]
    end    

    def create
        @user_room_relation = UserRoomRelation.new(user_room_relation_params)

        if @user_room_relation.save
            redirect_to room_path(@user_room_relation.room)
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