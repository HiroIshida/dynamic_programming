include("map2d.jl")
include("agentdef.jl")
include("utils.jl")
include("cost_function.jl")
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
    t_max_horizon = 30

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
    disturbance_lst = get_disturbance_lst(state .+ action, mc.adef, mc.map)
    disturbance = disturbance_lst[rand(1:length(disturbance_lst))]
    state_next = state .+ action .+ disturbance

    if ~isVisited_ht[(state, action)]
      addcost = get_addcost(map, state_next)
      dist = norm(state .- state_next)
      action_next = mc.policy_ht[state_next]
      g = mc.Q_ht[(state_next, action_next)] + dist + addcost
      
      push!(mc.Returns_ht[(state, action)], g)
      Returns = mc.Returns_ht[(state, action)]
      mc.Q_ht[(state, action)] = mean(Returns)
      isVisited_ht[(state, action)] = true
      if state == [2, 2] && action == [-1, 0]
        #println(g)
      end
    end
    state = state_next
    action = mc.policy_ht[state]
    if state == mc.map.idx_goal
      break
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
    # check_policy(mc, state, action) # TODO be aware of scope of for loop ..
    mc.policy_ht[state] = action_best 
  end
  
end

function check_policy(mc, state, action_new)
  if action_new ∉ get_action_lst(state, mc.adef, mc.map)
    error("fuck")
  end
end

function mc_trial(mc::MonteCarlo)
  isVisited_ht = copy(mc.isVisited_ht) # all element was set to false
  for n_loop in 1:10
    for state in generate_valid_idx(mc.map)
      for action in get_action_lst(state, mc.adef, mc.map)
        single_episode(mc, state, action)
      end
    end
  end
end


N = 10
idx_collision_obj_lst = [[4, 4], [4, 5], [4, 6], [5, 6]]
adef = AgentDef(1, 1)
map = Map2d(N, [0, 0], [10, 10])
add_rect_object!(map, [3, -1], [4, 8])
mc = MonteCarlo(map, adef)
@time mc_trial(mc)
cost_ht = make_cost_field(map, adef, mc.policy_ht)
show_contour(map, cost_ht)






