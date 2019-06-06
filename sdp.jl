include("map2d.jl")
include("utils.jl")

function test()
  N = 30
  idx_collision_obj_lst = [[4, 4], [4, 5], [4, 6], [5, 6]]
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
      idx_action_lst = get_adjacent_idx(map, idx_now)
      cost_min = inf
      for idx_action in idx_action_lst 
        cost = calculate_prob_cost(map, data, idx_action)
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

function calculate_prob_cost(map, data, idx_now) 
  # assume uniform disturbance
  width = 3
  dist = 1
  idx_possible_lst = get_adjacent_idx(map, idx_now, width)
  prob_each = 1.0/length(idx_possible_lst)

  cost_sum = 0

  for idx_possible in idx_possible_lst
    cost_sum += (get_data(data, idx_possible) + get_cost(map, idx_possible)) * prob_each 
  end
  cost_sum += dist

  return cost_sum
end

map_, data = test()

