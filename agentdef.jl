include("utils.jl")

struct AgentDef
  A_lst::Idxlst # possible action 
  D_lst::Idxlst # possible disturbance

  function AgentDef(action_lst::Vector{Vector{Int64}}, 
                    disturbance_lst::Vector{Vector{Int64}})
    A_lst = action_lst
    D_lst = disturbance_lst
    new(A_lst, D_lst)
  end

  function AgentDef(a_width::Int64 = 1, d_width::Int64 = 1)
    if d_width == 0
      @warn "if you use d_width = 0 in mc learning, the result may not make sense"  
    end
    A_lst = remove_elem_from_lst(diamond(a_width), [0, 0])
    D_lst = diamond(d_width)
    # delegate constructor
    AgentDef(A_lst, D_lst)
  end
end

function diamond(n)
  n == 0 && return [[0, 0]]
  n == 1 && return [[0, 0], [1, 0], [0, 1], [-1, 0], [0, -1]]
  error("under construction")
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
  idx_ret_lst = Idx[]
  for idx_add in idx_add_lst 
    isInside_map = isInside_rect([1, 1], [map.N, map.N], idx_here + idx_add)
    isInside_map && push!(idx_ret_lst, idx_add)
  end
  return idx_ret_lst 
end
