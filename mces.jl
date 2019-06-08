include("map2d.jl")
include("agentdef.jl")
include("utils.jl")
using Statistics
using Test
using LinearAlgebra

mutable struct MonteCarlo
  map::Map2d
  adef::AgentDef
  Q_ht::Dict{Tuple{Idx, Idx}, Float64}
  Returns_ht::Dict{Tuple{Idx, Idx}, Vector{Float64}}
  isVisited_ht::Dict{Tuple{Idx, Idx}, Bool}
  policy_ht::Dict{Idx, Idx}
  t_max_horizon::Int64

  function MonteCarlo(map::Map2d, adef::AgentDef)
    t_max_horizon = 100

    Q_hashtable_lst = []
    Returns_hashtable_lst = []
    isVisited_hashtable_lst = []
    policy_hashtable_lst = []
    state_lst = generate_idx_lst(1, map.N, 1, map.N)

    for state in state_lst
      action_lst = get_action_lst(state, adef, map)
      for action in action_lst
        key_sa = (state, action)
        push!(Q_hashtable_lst, (key_sa, 0.0))
        push!(Returns_hashtable_lst, (key_sa, []))
        push!(isVisited_hashtable_lst, (key_sa, false))
      end
      key_s = state
      push!(policy_hashtable_lst, (key_s, action_lst[1]))
    end
    d_type_key = Tuple{Idx, Idx}
    Q_ht = Dict{d_type_key, Float64}(Q_hashtable_lst)
    Returns_ht = Dict{d_type_key, Vector{Float64}}(Returns_hashtable_lst)
    isVisited_ht = Dict{d_type_key, Bool}(isVisited_hashtable_lst)
    policy_ht = Dict{Idx, Idx}(policy_hashtable_lst)
    new(map, adef, Q_ht, Returns_ht, isVisited_ht, policy_ht, t_max_horizon)
  end
end

function single_episode(mc::MonteCarlo, state0::Idx, action0::Idx)
  isVisited_ht = copy(mc.isVisited_ht) # all element was set to false

  state = state0
  action = action0
  state_visited_lst = Idx[]

  for t in 1:mc.t_max_horizon
    push!(state_visited_lst, state)
    state_next = propagate(state, action)
    if ~isVisited_ht[(state, action)]
      # # #
      addcost = get_addcost(map, state)
      dist = norm(state .- state_next)
      g = mc.Q_ht[(state, action)] + dist + addcost
      push!(mc.Returns_ht[(state, action)], g)
      Returns = mc.Returns_ht[(state, action)]
      mc.Q_ht[(state, action)] = mean(Returns)
      # # #
      isVisited_ht[(state, action)] = true
    end
    state = state_next
    action = mc.policy_ht[state]
    if state == mc.map.idx_goal
      return
    end
  end

  for state in state_visited_lst
    Q_min = Inf
    action_best = nothing
    for action in get_action_lst(state, mc.adef, mc.map)
      Q = mc.Q_ht[(state, action)]
      if Q < Q_min
        Q_min = Q
        action_best = action
      end
    end
    mc.policy_ht[state] = action
  end
  
end


function mc_trial(mc::MonteCarlo)
  state0 = [6, 10]
  action_lst = get_action_lst(state0, mc.adef, mc.map)
  action0 = action_lst[1] 
  for i in 1:30*30*9
    single_episode(mc, state0, action0)
  end
end

N = 30
idx_collision_obj_lst = [[4, 4], [4, 5], [4, 6], [5, 6]]
adef = AgentDef(3, 3)
map = Map2d(N, [0, 0], [10, 10])
add_rect_object!(map, [3, -1], [4, 8])
mc = MonteCarlo(map, adef)
@time mc_trial(mc)



