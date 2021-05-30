class UserRoomRelationsController < ApplicationController
    def new 
        @user_room_relation = UserRoomRelation.new
    end    
end