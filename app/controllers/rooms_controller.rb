class RoomsController < ApplicationController
    before_action :set_room, only: [:show]

    def new 
        @room = Room.new
    end    

    def show 
        @users = @room.users
    end

    private
    def set_room
        @room = Room.find(params[:id])
    end
end