include("map2d.jl")
include("agentdef.jl")
include("utils.jl")
include("cost_function.jl")

function test()
  N = 15
  adef = AgentDef(1, 0)
  map = Map2d(N, [0, 0], [10, 10])
  add_rect_object!(map, [3, -1], [4, 8])
  cost_ht = make_cost_field(map, adef, N_itr = 100)
  show_contour(map, cost_ht)
end

test()

