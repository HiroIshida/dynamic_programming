include("grid.jl")
N = 100
grid = Grid2d(N, [0, 0], [10, 10])

idx_goal = [N, N]
value_goal = 0.0

function recursion(idx_now)
  set_visited(grid, idx_now)
  idx_adj_lst = get_adjacent_idx(grid, idx_now)
  for idx_adj in idx_adj_lst
    isVisited(grid, idx_adj) || recursion(idx_adj)
  end

end

set_data(grid, idx_goal, 0.0)
recursion(idx_goal)
get_adjacent_idx(grid, idx_goal)
