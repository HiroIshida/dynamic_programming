struct AgentDef
  A_lst # possible action 
  D_lst # possible disturbance

  function AgentDef(action_lst::Vector{Vector{Int64}}, 
                    disturbance_lst::Vector{Vector{Int64}})
    @warn "not checked"
    A_lst = action_lst
    D_lst = disturbance_lst
    new(A_lst, D_lst)
  end

  function AgentDef(a_width::Int64, d_width::Int64)
    if ~(isodd(a_width) && isodd(d_width))
       error("width must be odd number")
    end
    a_w_half = trunc(Int, (a_width - 1)/2)
    d_w_half = trunc(Int, (d_width - 1)/2)
    A_lst = generate_idx_lst(-a_w_half, a_w_half, -a_w_half, a_w_half)
    D_lst = generate_idx_lst(-d_w_half, d_w_half, -d_w_half, d_w_half)
    println(typeof(A_lst))
    new(A_lst, D_lst)
  end
end

function get_action_lst(idx_here, adef::AgentDef, map)
  idx_ret = push_if_valid(idx_here, adef.A_lst, map)
  return idx_ret
end

function get_disturbance_lst(idx_here, adef::AgentDef, map)
  idx_ret = push_if_valid(idx_here, adef.D_lst, map)
  return idx_ret
end

function push_if_valid(idx_here, idx_add_lst, map)
  idx_ret_lst = []
  for idx_add in idx_add_lst 
    isInside_map = isInside_rect([1, 1], [map.N, map.N], idx_here + idx_add)
    isInside_map && push!(idx_ret_lst, idx_add)
  end
  return idx_ret_lst 
end
