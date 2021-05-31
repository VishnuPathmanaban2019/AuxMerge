class RoomsController < ApplicationController
    before_action :set_room, only: [:show]

    def new 
        @room = Room.new
        @room.creator_int = params[:creator_int] if params[:creator_int]
    end    

    def show 
        @users = @room.users
    end

    def create
        @room = Room.new(room_params)
        if @room.save
        # if saved to database
        flash[:notice] = "Successfully created room."
        @creator = User.find(@room.creator_int)
        UserRoomRelation.create(:user_id => @creator.id,:room_id => @room.id)
        redirect_to room_path(@room) # go to show page
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
        params.require(:room).permit(:password, :creator_int)
    end
end