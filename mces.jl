include("map2d.jl")
include("agentdef.jl")
include("utils.jl")
using Test

mutable struct MonteCarlo
  map
  adef
  Q_ht 
  G_ht
  isVisited_ht
  policy_ht
  t_max_horizon 

  function MonteCarlo(map::Map2d, adef::AgentDef)
    t_max_horizon = 100

    Q_hashtable_lst = []
    G_hashtable_lst = []
    isVisited_hashtable_lst = []
    policy_hashtable_lst = []
    state_lst = generate_idx_lst(1, map.N, 1, map.N)

    for state in state_lst
      action_lst = get_action_lst(state, adef, map)
      for action in action_lst
        key_sa = (state, action)
        push!(Q_hashtable_lst, (key_sa, 0.0))
        push!(G_hashtable_lst, (key_sa, nothing))
        push!(isVisited_hashtable_lst, (key_sa, false))
      end
      key_s = state
      push!(policy_hashtable_lst, (key_s, action_lst[1]))
    end
    d_type_key = Tuple{Idx, Idx}
    Q_ht = Dict{d_type_key, Float64}(Q_hashtable_lst)
    G_ht = Dict{d_type_key, Union{Nothing, Float64}}(G_hashtable_lst)
    isVisited_ht = Dict{d_type_key, Bool}(isVisited_hashtable_lst)
    policy_ht = Dict{Idx, Idx}(policy_hashtable_lst)
    new(map, adef, Q_ht, G_ht, isVisited_ht, policy_ht, t_max_horizon)
  end
end

function single_episode(mc::MonteCarlo, state0, action0)

  isVisited_ht = copy(mc.isVisited_ht)

  state = state0
  action = action0
  for t in 1:mc.t_max_horizon
    println(t)
    state = propagate(state, action)
    action = get_hashed_data(mc.policy_ht, state)
    if state == mc.map.idx_goal
      return
    end
  end
end

function get_hashed_data(hashtable::Dict, state::Idx, action::Idx)
  key = (state, action)
  data = hashtable[key]
  return data
end

function get_hashed_data(hashtable::Dict, state::Idx)
  key = state
  data = hashtable[key]
  return data
end

function set_hashed_data!(hashtable::Dict, state::Idx, action::Idx, data::Number)
  key = (state, action)
  hashtable[key] = data
end

function set_hashed_data!(hashtable::Dict, state::Idx, data::Number)
  key = state
  hashtable[key] = data
end

function mc_trial(mc::MonteCarlo)
  state0 = [6, 10]
  action_lst = get_action_lst(state0, mc.adef, mc.map)
  action0 = action_lst[1] 
  single_episode(mc, state0, action0)
end

N = 30
idx_collision_obj_lst = [[4, 4], [4, 5], [4, 6], [5, 6]]
adef = AgentDef(3, 3)
map = Map2d(N, [0, 0], [10, 10])
add_rect_object!(map, [3, -1], [4, 8])
mc = MonteCarlo(map, adef)
mc_trial(mc)



