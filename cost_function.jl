include("map2d.jl")
include("agentdef.jl")
include("utils.jl")

using LinearAlgebra

function make_cost_field(map::Map2d, adef::AgentDef, policy_ht = nothing)
  usingPolicy = (policy_ht != nothing)
  # init data
  s_lst = generate_idx_lst(1, map.N, 1, map.N)
  cost_init = 0.0
  ht_pair_lst = [(s, cost_init) for s in s_lst]
  cost_ht = Dict(ht_pair_lst)
  s_valid_lst = generate_valid_idx(map::Map2d)

  for t in 1:100
    cost_ht_new = copy(cost_ht)
    for s in s_valid_lst
      if usingPolicy
        cost_new = update_cost_with_policy(s, policy_ht, adef, map, cost_ht)
      else
        cost_new = update_cost_without_policy(s, adef, map, cost_ht)
      end
      cost_ht_new[s] = cost_new
    end
    cost_ht = cost_ht_new
  end

  return cost_ht
end

function update_cost_with_policy(state, policy_ht, adef, map, cost_ht)
  action = policy_ht[state]
  cost = calculate_cost_expectancy(state, action, adef, map, cost_ht)
  return cost
end

function update_cost_without_policy(state, adef, map, cost_ht)
  cost_min = Inf
  for action in get_action_lst(state, adef, map)
    cost_cand = calculate_cost_expectancy(state, action, adef, map, cost_ht)
    cost_min = min(cost_min, cost_cand)
  end
  return cost_min
end

function calculate_cost_expectancy(state_now, action, adef, map, cost_ht)
  state_planned = propagate(state_now, action)
  disturbance_lst = get_disturbance_lst(state_planned, adef, map)
  prob_each = 1.0/length(disturbance_lst)
  cost_sum = 0.0
  for disturb in disturbance_lst
    state_possible = propagate(state_planned, disturb)
    dist = norm(state_possible .- state_now)
    cost_sum += (cost_ht[state_possible] + dist + get_addcost(map, state_possible))*prob_each
  end
  return cost_sum
end

