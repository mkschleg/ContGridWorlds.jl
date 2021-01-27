function which_room(env::FourRooms, state)
    frp = FourRoomsContParams
    room = -1
    if state[1] < 6
        # LEFT
        if state[2] < 6
            # TOP
            room = frp.ROOM_TOP_LEFT
        else
            # Bottom
            room = frp.ROOM_BOTTOM_LEFT
        end
    else
        # RIGHT
        if state[2] < 7
            # TOP
            room = frp.ROOM_TOP_RIGHT
        else
            # Bottom
            room = frp.ROOM_BOTTOM_RIGHT
        end
    end
    return room
end
