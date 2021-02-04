module ContGridWorlds

# Write your package code here.

# module FourRooms

import Random, Base.size
import Reexport: @reexport

@reexport using MinimalRLCore

using RecipesBase

"""
    Simple reward structure for goals. Can be duck typed.
"""
struct BasicRewFunc
    value::Float64
end

is_terminal(rew::BasicRewFunc) = true
get_reward(rew::BasicRewFunc) = rew.value


module FourRoomsContParams

const BASE_WALLS = [0 0 0 0 0 1 0 0 0 0 0;
                    0 0 0 0 0 1 0 0 0 0 0;
                    0 0 0 0 0 0 0 0 0 0 0;
                    0 0 0 0 0 1 0 0 0 0 0;
                    0 0 0 0 0 1 0 0 0 0 0;
                    1 0 1 1 1 1 0 0 0 0 0;
                    0 0 0 0 0 1 1 1 0 1 1;
                    0 0 0 0 0 1 0 0 0 0 0;
                    0 0 0 0 0 1 0 0 0 0 0;
                    0 0 0 0 0 0 0 0 0 0 0;
                    0 0 0 0 0 1 0 0 0 0 0;]

const GOAL_LOCS =  [0 0 0 0 0 0 0 0 0 0 0;
                    0 0 0 0 0 0 0 0 0 0 0;
                    0 0 0 0 0 0 0 0 0 0 0;
                    0 0 0 0 0 0 0 0 0 0 0;
                    0 0 0 0 0 0 0 0 0 0 0;
                    0 0 0 0 0 0 0 0 0 0 0;
                    0 0 0 0 0 0 0 0 0 0 0;
                    0 0 0 0 0 0 0 0 0 0 0;
                    0 0 0 0 0 0 0 0 0 0 0;
                    0 0 0 0 0 0 0 0 0 0 0;
                    0 0 0 0 0 0 0 0 0 0 0;]

const ROOM_TOP_LEFT = 1
const ROOM_TOP_RIGHT = 2
const ROOM_BOTTOM_LEFT = 3
const ROOM_BOTTOM_RIGHT = 4

const REW_FUNCS = Dict{Int, Function}()

end

module TMazeContParams

import ..BasicRewFunc

const BASE_WALLS = [1 1 1 1 1 1 1 1 1 1 1;
                    1 0 0 1 1 1 1 1 0 0 1;
                    1 0 0 0 0 0 0 0 0 0 1;
                    1 0 0 0 0 0 0 0 0 0 1;
                    1 0 0 0 0 0 0 0 0 0 1;
                    1 0 0 1 0 0 0 1 0 0 1;
                    1 1 1 1 0 0 0 1 1 1 1;
                    1 1 1 1 0 0 0 1 1 1 1;
                    1 1 1 1 0 0 0 1 1 1 1;
                    1 1 1 1 0 0 0 1 1 1 1;
                    1 1 1 1 0 0 0 1 1 1 1;]

const GOAL_LOCS = [-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1;
                   -1  1  1 -1 -1 -1 -1 -1  3  3 -1;
                   -1  0  0  0  0  0  0  0  0  0 -1;
                   -1  0  0  0  0  0  0  0  0  0 -1;
                   -1  0  0  0  0  0  0  0  0  0 -1;
                   -1  2  2 -1  0  0  0 -1  4  4 -1;
                   -1 -1 -1 -1  0  0  0 -1 -1 -1 -1;
                   -1 -1 -1 -1  0  0  0 -1 -1 -1 -1;
                   -1 -1 -1 -1  0  0  0 -1 -1 -1 -1;
                   -1 -1 -1 -1  0  0  0 -1 -1 -1 -1;
                   -1 -1 -1 -1  0  0  0 -1 -1 -1 -1;]

const REW_FUNCS = Dict([i=>BasicRewFunc(i) for i in 1:4]...)

end

include("dynamics.jl")

FourRooms(max_action_noise=0.1,
          drift_noise=0.001;
          normalized=false) =
              ContGridWorld(FourRoomsContParams.BASE_WALLS[end:-1:1, :],
                            FourRoomsContParams.GOAL_LOCS[end:-1:1, :],
                            FourRoomsContParams.REW_FUNCS,
                            max_action_noise,
                            drift_noise,
                            normalized)

TMaze(max_action_noise=0.1, drift_noise=0.001; normalized=false) =
    ContGridWorld(TMazeContParams.BASE_WALLS[end:-1:1, :],
                  TMazeContParams.GOAL_LOCS[end:-1:1, :],
                  TMazeContParams.REW_FUNCS,
                  max_action_noise,
                  drift_noise,
                  normalized)




module PlotParams

using Colors


const SIZE = 10
const BG = Colors.RGB(1.0, 1.0, 1.0)
const WALL = Colors.RGB(0.3, 0.3, 0.3)
const AC = Colors.RGB(0.69921875, 0.10546875, 0.10546875)
const GOAL = Colors.RGB(0.796875, 0.984375, 0.76953125)
const AGENT = [AC AC AC AC;
               AC AC AC AC;
               AC AC AC AC;
               AC AC AC AC;]

end

@recipe function f(env::ContGridWorld)
    ticks := nothing
    foreground_color_border := nothing
    grid := false
    legend := false
    aspect_ratio := 1
    xaxis := false
    yaxis := false

    PP = PlotParams

    s = size(env)
    screen = fill(PP.BG, (s[2] + 2)*PlotParams.SIZE, (s[1] + 2)*PlotParams.SIZE)
    screen[:, 1:PP.SIZE] .= PP.WALL
    screen[1:PP.SIZE, :] .= PP.WALL
    screen[end-(PP.SIZE-1):end, :] .= PP.WALL
    screen[:, end-(PP.SIZE-1):end] .= PP.WALL
    
    for i ∈ 1:s[1]
        for j ∈ 1:s[2]
            sqr_i = ((i)*PP.SIZE + 1):((i+1)*PP.SIZE)
            sqr_j = ((j)*PP.SIZE + 1):((j+1)*PP.SIZE)
            if env.walls[s[1] - i + 1, j]
                screen[sqr_i, sqr_j] .= PP.WALL
            end
            if env.goals[s[1] - i + 1, j] > 0
                screen[sqr_i, sqr_j] .= PP.GOAL
            end
        end
    end
    state = ((env.state[1] - 1, env.state[2] + 1).*PlotParams.SIZE)
    
    screen[collect(-1:2) .+ Int(floor(PP.SIZE*s[1] - state[1])), collect(-1:2) .+ Int(floor(state[2]))] .= PP.AGENT

    
    screen
end


end
