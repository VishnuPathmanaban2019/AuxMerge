class UserRoomRelationsController < ApplicationController
    def new 
        @user_room_relation = UserRoomRelation.new
        @user_room_relation.user_id = params[:user_id] if params[:user_id]
    end    

    def create
        @user_room_relation = UserRoomRelation.new(user_room_relation_params)
        if @user_room_relation.save
        # if saved to database
        flash[:notice] = "Successfully joined room."
        redirect_to room_path(@user_room_relation.room) # go to show page
        else
        # return to the 'new' form
        render action: 'new'
        end
    end

    private
    def user_room_relation_params
        params.require(:user_room_relation).permit(:user_id, :room_id)
    end
end