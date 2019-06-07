
@inline function isInside_rect(b_min, b_max, pos)
  for i in 1:2
    b_min[i] > pos[i] && return false
    b_max[i] < pos[i] && return false
  end
  return true
end

@inline function get_data(data, idx)
  return data[idx[1], idx[2]]
end

@inline function set_data!(data, idx, value)
  data[idx[1], idx[2]] = value
end

@inline function propagate(idx_here::Vector{Int64}, idx_add::Vector{Int64})
  return idx_here .+ idx_add
end

@inline function propagate(idx_here::Vector{Int64}, idx_add_lst::Vector{Vector{Int64}})
  idx_new_lst = []
  for idx_add in idx_add_lst
    push!(idx_new_lst, propagate(idx_here, idx_add))
  end
  return idx_new_lst
end
