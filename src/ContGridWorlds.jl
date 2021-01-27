module ContGridWorlds

# Write your package code here.

# module FourRooms

import Random, Base.size
import Reexport: @reexport

@reexport using MinimalRLCore


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

const ROOM_TOP_LEFT = 1
const ROOM_TOP_RIGHT = 2
const ROOM_BOTTOM_LEFT = 3
const ROOM_BOTTOM_RIGHT = 4

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
                   -1  1  1 -1  1  1  1 -1  3  3 -1;
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

FourRooms(max_action_noise=0.1, drift_noise=0.001; normalized=false) =
    ContGridWorld(FourRoomsContParams.BASE_WALLS[end:-1:1, :], max_action_noise, drift_noise, normalized)

TMaze(max_action_noise=0.1, drift_noise=0.001; normalized=false) =
    ContGridWorld(TMazeContParams.BASE_WALLS[end:-1:1, :],
                  TMazeContParams.GOAL_LOCS[end:-1:1, :],
                  TMazeContParams.REW_FUNCS,
                  max_action_noise,
                  drift_noise,
                  normalized)






# function MonteCarloReturn(env::FourRoomsCont, gvf::GVF, start_state::Array{Float64, 1},
#                           num_returns::Int64, γ_thresh::Float64=1e-6,
#                           max_steps::Int64=Int64(1e7);
#                           rng=Random.GLOBAL_RNG)

#     returns = zeros(num_returns)
#     for ret in 1:num_returns
#         step = 0
#         cur_state = start_state
#         cumulative_gamma = 1.0
#         while cumulative_gamma > γ_thresh && step < max_steps
#             action = StatsBase.sample(rng, gvf.policy, cur_state)
#             next_state, _, _ = _step(env, cur_state, action; rng=rng)
#             c, γ, pi_prob = get(gvf, cur_state, action, next_state, nothing, nothing)
#             returns[ret] += cumulative_gamma*c
#             cumulative_gamma *= γ
#             cur_state = next_state
#             step += 1
#         end
#     end

#     return returns
# end

# import ProgressMeter

# function get_sequence(env::FourRoomsCont, num_steps, policy; seed=0, normalized=false)
#     rng = Random.MersenneTwister(seed)
#     env.normalized = normalized
#     states = Array{Array{Float64, 1}}(undef, num_steps+1)
#     _, state = start!(env; rng=rng)
#     states[1] = copy(state[1])
#     ProgressMeter.@showprogress 0.1 "Step:" for step in 1:num_steps
#         action = StatsBase.sample(rng, policy, state)
#         _, state, _, _ = step!(env, action; rng=rng)
#         states[step+1] = copy(state[1])
#     end
#     return states
# end



end
