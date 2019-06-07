include("map2d.jl")
include("agentdef.jl")
include("utils.jl")

function test()
  N = 30
  idx_collision_obj_lst = [[4, 4], [4, 5], [4, 6], [5, 6]]
  adef = AgentDef(3, 3)
  map = Map2d(N, [0, 0], [10, 10])
  add_rect_object!(map, [3, -1], [4, 8])
  idx_lst = generate_valid_idx(map)
  idx_goal = [1, 1]

  inf = 10000000000000
  delta = 0
  dist = 1.0
  data = zeros(N, N) 
  for iii in 1:100
    data_new = zeros(N, N)

    for idx_now in idx_lst
      cost_current = get_data(data, idx_now)
      idx_action_lst = propagate(idx_now, get_action_lst(idx_now, adef, map))
      cost_min = inf
      for idx_action in idx_action_lst 
        cost = calculate_prob_cost(idx_action, adef, map, data)
        cost_min = min(cost_min, cost)
      end
      set_data!(data_new, idx_now, cost_min)
      delta = max(abs(cost_min - cost_current), delta)
    end

    data = data_new
  end
  show_contour(map, data)
  return map, data
end

function calculate_prob_cost(idx_now, adef, map, data) 
  # assume uniform disturbance
  width = 3
  dist = 1
  disturbance_lst = get_disturbance_lst(idx_now, adef, map)
  idx_new_lst = propagate(idx_now, disturbance_lst)
  prob_each = 1.0/length(idx_new_lst)

  cost_sum = 0

  for idx_possible in idx_new_lst
    cost_sum += (get_data(data, idx_possible) + get_cost(map, idx_possible)) * prob_each 
  end
  cost_sum += dist

  return cost_sum
end

map_, data = test()

