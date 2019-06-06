
struct Grid2d
    N::Int64
    dx::Vector{Float64}
    b_min::Vector{Float64}
    b_max::Vector{Float64}
    data::Matrix{Float64}
    boolmat::Matrix{Bool}

    function Grid2d(N, b_min, b_max)
        dx = (b_max - b_min)./N
        data = zeros(N, N)
        boolmat = Array{Bool}(undef, N, N)
        for i in 1:N
          for j in 1:N
            boolmat[i, j] = false
          end
        end
        new(N, dx, b_min, b_max, data, boolmat)
    end
end

@inline function idx_to_dataidx(gr::Grid2d, idx)
  dataidx = gr.N * idx[0] + idx[1]
end

@inline function dataidx_to_idx(gr::Grid2d, dataidx)
  idx_y = mod(dataidx, gr.N)
  idx_x = trunc(Int, (dataidx - idx_x)/gr.N)
  return [idx_x, idx_y]
end

@inline function isVisited(gr::Grid2d, idx)
  return gr.boolmat[idx[1], idx[2]]
end

@inline function set_visited(gr::Grid2d, idx)
  gr.boolmat[idx[1], idx[2]] = true
end

@inline function get_data(gr::Grid2d, idx)
  return isVisited(grid, idx) ? gr.data[idx[1], idx[2]] : nothing
end

@inline function set_data(gr::Grid2d, idx, value)
  gr.data[idx[1], idx[2]] = value
  gr.boolmat[idx[1], idx[2]] = true
end


@inline function get_adjacent_idx(gr::Grid2d, idx::Vector{Int64})
  idx_list = []

  if idx[1] > 1
    idx_left = idx + [-1, 0]
    push!(idx_list, idx_left)
  end

  if idx[1] < gr.N
    idx_right = idx + [1, 0]
    push!(idx_list, idx_right)
  end

  if idx[2] > 1
    idx_down = idx + [0, -1]
    push!(idx_list, idx_down)
  end

  if idx[2] < gr.N
    idx_up = idx + [0, 1]
    push!(idx_list, idx_up)
  end

  return idx_list
end

