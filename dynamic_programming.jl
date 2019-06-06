include("map2d.jl")

function test()
  N = 100
  map = Map2d(N, [0, 0], [10, 10])
  idx_lst = [[i, j] for i in 2:N, j in 2:N]
  idx_goal = [1, 1]

  inf = 10000000000000
  delta = 0
  dist = 1.0
  data = zeros(N, N)
  for iii in 1:10
    data_new = zeros(N, N)

    for idx_now in idx_lst
      cost_current = get_data(data, idx_now)
      idx_adj_lst = get_adjacent_idx(map, idx_now)
      cost_min = inf
      for idx_adj in idx_adj_lst 
        cost = get_data(data, idx_adj) + dist
        cost_min = min(cost_min, cost)
      end
      set_data!(data_new, idx_now, cost_min)
      delta = max(abs(cost_min - cost_current), delta)
    end

    data = data_new
  end

  return data
end
data = test()
