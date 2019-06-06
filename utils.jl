
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

