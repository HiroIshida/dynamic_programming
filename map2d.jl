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

@inline function get_adjacent_idx(map::Map2d, idx::Vector{Int64})
  idx_list = []

  if idx[1] > 1
    idx_left = idx + [-1, 0]
    push!(idx_list, idx_left)
  end

  if idx[1] < map.N
    idx_right = idx + [1, 0]
    push!(idx_list, idx_right)
  end

  if idx[2] > 1
    idx_down = idx + [0, -1]
    push!(idx_list, idx_down)
  end

  if idx[2] < map.N
    idx_up = idx + [0, 1]
    push!(idx_list, idx_up)
  end

  return idx_list
end

@inline function get_data(data, idx)
  return data[idx[1], idx[2]]
end

@inline function set_data!(data, idx, value)
  data[idx[1], idx[2]] = value
end


