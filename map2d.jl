using PyPlot
struct Map2d
    N::Int64
    dx::Vector{Float64}
    b_min::Vector{Float64}
    b_max::Vector{Float64}
    idx_object_lst::Vector{Vector{Int64}}

    function Map2d(N, b_min, b_max, idx_object_lst = [])
        dx = (b_max - b_min)./N
        new(N, dx, b_min, b_max, idx_object_lst)
    end
end

@inline function get_adjacent_idx(map::Map2d, idx_here::Vector{Int64})
  idx_adj_lst = []

  function push_if_not_collide(idx_new)
    for idx_object in map.idx_object_lst
      idx_new == idx_object && return
    end
    push!(idx_adj_lst, idx_new) 
  end

  idx_here[1] > 1 && push_if_not_collide(idx_here + [-1, 0])
  idx_here[1] < map.N && push_if_not_collide(idx_here + [1, 0])
  idx_here[2] > 1 && push_if_not_collide(idx_here + [0, -1])
  idx_here[2] < map.N && push_if_not_collide(idx_here + [0, 1])
  return idx_adj_lst
end

@inline function show_contour(map::Map2d, data)
  b_min = map.b_min
  b_max = map.b_max
  extent = [b_min[1] + 0.5*map.dx[1],
            b_max[1] - 0.5*map.dx[1],
            b_min[2] + 0.5*map.dx[2],
            b_max[2] - 0.5*map.dx[2]]
  PyPlot.imshow(data,
                extent = extent,
                interpolation=:bicubic)
  show()
  end

@inline function get_data(data, idx)
  return data[idx[1], idx[2]]
end

@inline function set_data!(data, idx, value)
  data[idx[1], idx[2]] = value
end


