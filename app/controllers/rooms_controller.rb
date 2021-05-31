class RoomsController < ApplicationController
    before_action :set_room, only: [:show]

    def new 
        @room = Room.new
        @room.creator_id = params[:creator_id] if params[:creator_id]
    end    

    def show 
        @users = @room.users
    end

    def create
        @room = Room.new(room_params)

        if @room.save
            
            @creator = User.find(@room.creator_id)
            UserRoomRelation.create(:user_id => @creator.id,:room_id => @room.id)

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
        params.require(:room).permit(:password, :creator_id)
    end
end