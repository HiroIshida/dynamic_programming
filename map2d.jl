include("utils.jl")
using PyPlot

mutable struct Map2d
    N::Int64
    dx::Vector{Float64}
    b_min::Vector{Float64}
    b_max::Vector{Float64}
    idx_goal
    addcostfield::Matrix{Float64}

    function Map2d(N, b_min, b_max, idx_goal = [1, 1])
        dx = (b_max - b_min)./N
        addcostfield = zeros(N, N)
        new(N, dx, b_min, b_max, idx_goal, addcostfield)
    end
end

@inline function get_adjacent_idx(map::Map2d, idx_here::Vector{Int64}, width=3)
  r = trunc(Int, (width - 1)/2)
  idx_adj_cand_lst = propagate(idx_here, generate_idx_lst(-r, r, -r, r))
  idx_adj_lst = []
  for idx_adj_cand in idx_adj_cand_lst 
    isInside_rect([1, 1], [map.N, map.N], idx_adj_cand) && push!(idx_adj_lst, idx_adj_cand)
  end
  return idx_adj_lst
end

function generate_valid_idx(map::Map2d) # TODO 
  idx_avoid_set = Set([map.idx_goal])
  idx_base_set = Set(generate_idx_lst(1, map.N, 1, map.N))
  idx_valid = setdiff(idx_base_set, idx_avoid_set)
  return collect(idx_valid)
end

function add_rect_object!(map::Map2d, b_min, b_max, object_cost = 20)
  idx_base_lst = generate_idx_lst(1, map.N, 1, map.N)
  # can be easily make this better, but .. TODO
  for idx_base in idx_base_lst
    if isInside_rect(b_min, b_max, idx_to_pos(map, idx_base))
      set_data!(map.addcostfield, idx_base, object_cost)
    end
  end

end

function show_contour(map::Map2d, data_ht::Dict)
  data_mat = zeros(map.N, map.N)
  for i in 1:map.N, j in 1:map.N
    key = [i, j]
    data_mat[i, j] = data_ht[key]
  end
  show_contour(map, data_mat) # not recursion!! multiple dipatch
end

function show_contour(map::Map2d, data::Matrix)
  b_min = map.b_min
  b_max = map.b_max
  extent = [b_min[1] + 0.5*map.dx[1],
            b_max[1] - 0.5*map.dx[1],
            b_min[2] + 0.5*map.dx[2],
            b_max[2] - 0.5*map.dx[2]]
  PyPlot.imshow(data,
                extent = extent,
                interpolation=:nearest)
  show()
end

@inline function get_addcost(map::Map2d, idx)
  return get_data(map.addcostfield, idx)
end

@inline function idx_to_pos(map::Map2d, idx)
  return map.b_min + map.dx.*(idx .- 1)
end



