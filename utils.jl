const Idxlst = Vector{Vector{Int64}}
const Idx = Vector{Int64}

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

@inline function generate_idx_lst(i_min, i_max, j_min, j_max)
  idx_lst_ret = Vector{Int64}[]
  for i in i_min : i_max
    for j in j_min : j_max
      push!(idx_lst_ret, [i, j])
    end
  end
  return idx_lst_ret
end
