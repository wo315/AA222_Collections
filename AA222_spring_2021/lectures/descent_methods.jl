### A Pluto.jl notebook ###
# v0.14.0

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 7dea2baa-8f2c-11eb-184b-cb353ca6ca79
using PlutoUI

# ╔═╡ 9fd099fc-8f2c-11eb-286e-a548737f4572
using Plots

# ╔═╡ 9633d3f8-9000-11eb-3d5a-b3dd2a013890
using LinearAlgebra

# ╔═╡ 2c140db8-9013-11eb-21d9-f7718dc9cf57
using Optim

# ╔═╡ 56018eb0-90e1-11eb-18c0-e1f1aecf307c
using Vec

# ╔═╡ 5fead5d4-8f2d-11eb-2d3c-a34658637923
∇fline(x) = 0.75 * exp(-0.5 * (x - 7)^2) * (x - 7) + exp(-0.25 * (x - 3)^2) * 0.5 *(x - 3);

# ╔═╡ bf810ea8-8f2c-11eb-2d6e-3dcb7961b1fa
fline(x) = 1.5 - exp(-0.25 * (x - 3)^2)  - 0.75 * exp(-0.5 * (x - 7)^2);

# ╔═╡ 99e23b7a-8ffd-11eb-1b86-9940c74de5fc
rosenbrock(x) = (1 - x[1])^2 + 5 * (x[2] - x[1]^2)^2;

# ╔═╡ 9d46db42-8ffe-11eb-1f0f-1d6553bcd608
rosenbrock(x, y) = (1 - x)^2 + 5 * (y - x^2)^2;

# ╔═╡ 9a62773e-8ffd-11eb-315a-611790d3d945
∇rosenbrock(x) = [2 * (10 * x[1]^3 - 10 * x[1] * x[2] + x[1] - 1), 10 * (x[2] - x[1]^2)];

# ╔═╡ fb5587cc-9012-11eb-313a-512bd0f9651b
Hrosenbrock(x) = [-20 * (x[2] - x[1]^2) + 40 * x[1]^2 + 2 -20*x[1];
	              -20*x[1] 10];

# ╔═╡ fb7ea5ef-a2be-43a5-aae6-1bacc3a65f1e
rosenbrock2(x) = (1 - x[1])^2 + 100 * (4x[2] - x[1]^2)^2;

# ╔═╡ db569392-347f-45b1-b7c6-e2a0c235cff9
rosenbrock2(x, y) = (1-x)^2 + 100 * (4y - x^2)^2;

# ╔═╡ 1d09ca7a-8b25-4f3a-9f7d-ef586dd80be8
rosenbrock3(x, y) = (1-x)^2 + 100 * (y - x^2)^2;

# ╔═╡ cb524eeb-d78d-4125-8e5a-5da5e14644bb
∇rosenbrock2(x) = [2 * (200x[1]^3 - 800x[1] * x[2] + x[1] - 1), -800 * (x[1]^2 - 4x[2])];

# ╔═╡ 5e9fcab4-d2fe-445d-9b8e-2fe9fe50444d
md"""
# Descent Direction Iteration

1. Determine if out current x satisfies some termination condition. If so, terminate. If not, proceed.
2. Determine the **descent direction**.
3. Determine the **step size**.
4. Compute the next design point according to $\mathbf{x}^{(k+1)} \gets \mathbf{x}^{(k)} + \alpha^{(k)}\mathbf{d}^{(k)}$.
"""

# ╔═╡ 70855f33-c00d-49c3-82ec-f891ae4b40c5
md"""
nsteps = $(@bind nsteps1d NumberField(0:1:10, default = 0))

α = $(@bind α1d NumberField(0.1:0.1:3, default = 0.1))
"""

# ╔═╡ a3ae828c-3354-43e4-bf49-2284e465660d
begin
	p10 = plot(x -> x^2, legend = false, xlabel = "x", ylabel = "f(x)", color = :black, lw = 3, xlims = (-4,4), ylims = (0, 15))
	
	function run_gd(α, nsteps)
		gd_xs = [-3.5]
		gd_ys = [gd_xs[end]^2]
	
		for i = 1:nsteps
			next_x = gd_xs[end] - α * 2 * gd_xs[end]
			push!(gd_xs, next_x)
			push!(gd_ys, next_x^2)
		end
		
		return gd_xs, gd_ys
	end
	
	gd_xs, gd_ys = run_gd(α1d, nsteps1d)
	
	scatter!(gd_xs, gd_ys, color = :aqua, markersize = 5)
	scatter!(gd_xs, zeros(length(gd_xs)), color = :black, markersize = 5)
	for i = 1:length(gd_xs)
		plot!([gd_xs[i], gd_xs[i]], [0.0, gd_ys[i]], color = :black)
	end
	p10
end

# ╔═╡ 0259e325-9558-4dfc-9ca8-06daade248b9
md"""
# Multiple Dimensions
"""

# ╔═╡ e54c3874-667d-42a8-ba9f-5376f3ae3bd6
md"""
nsteps = $(@bind nsteps2d NumberField(0:1:10, default = 0))

α = $(@bind α2d NumberField(0.1:0.1:3, default = 0.1))
"""

# ╔═╡ 33f938e6-8229-4baa-9e1c-3c0215c53197
begin
	xvec = -4:0.1:4
	yvec = -4:0.1:4
	fbowl(x, y) = (x^2 + y^2) / 2
	
	function run_gd_2d(α, nsteps)
		gd_xs = [-3.5]
		gd_ys = [3.5]
		gd_zs = [fbowl(gd_xs[end], gd_ys[end])]
	
		for i = 1:nsteps
			next_x = gd_xs[end] - α * 2 * gd_xs[end]
			next_y = gd_ys[end] - α * 2 * gd_ys[end]
			push!(gd_xs, next_x)
			push!(gd_ys, next_y)
			push!(gd_zs, fbowl(gd_xs[end], gd_ys[end]))
		end
		
		return gd_xs, gd_ys, gd_zs
	end
	
	gd_xs2, gd_ys2, gd_zs2 = run_gd_2d(α2d, nsteps2d)
	
	sp1 = plot(xvec, yvec, fbowl, st = :surface, c = cgrad(:viridis, rev = true), colorbar = false, size = (600, 300), alpha = 0.5, legend = false, xlabel = "x₁", ylabel = "x₂", zlabel = "f(x)")
	#for i = 1:length(gd_xs)
	scatter!(sp1, gd_xs2, gd_ys2, gd_zs2, color = :red)
	plot!(sp1, gd_xs2, gd_ys2, gd_zs2, color = :black)
		#plot!(sp1, [-3.5, -3.5], [3.5, 3.5], [0.0, 9.0])
	
	sp2 = contour(xvec, yvec, fbowl, c = cgrad(:viridis, rev = true), colorbar = false, aspectratio = :equal, size = (600, 300), xlabel = "x₁", ylabel = "x₂", legend = false)
	scatter!(sp2, gd_xs2, gd_ys2, color = :red)
	plot!(sp2, gd_xs2, gd_ys2, color = :black)
	
	plot(sp1, sp2)
end

# ╔═╡ 9402e2b6-757e-4632-aac2-7251b28a768a
# begin
# # 	# plot(x -> x^2, legend = false, xlabel = "x", ylabel = "f(x)", color = :black, lw = 3, xlims = (-4,4), ylims = (0, 15))
# 	sp10 = plot(xvec, yvec, fbowl, st = :surface, c = cgrad(:viridis, rev = true), colorbar = false, size = (600, 400), alpha = 0.5, legend = false, xlabel = "x₁", ylabel = "x₂", zlabel = "f(x)")
# 	#scatter!(sp10, [-3.5], [3.5], [fbowl(-3.5, 3.5)], color = :red, markersize = 6)
# 	xsline = collect(-4:0.1:4)
# 	ysline = -xsline
# 	fsline = [fbowl(xsline[i], ysline[i]) for i = 1:length(xsline)]
	
# 	plot!(xsline, ysline, fsline, color = :white, lw = 6)
# 	plot!(xsline, ysline, zeros(length(xsline)), color = :black, lw = 6)
# end

# ╔═╡ a364ef52-8f2c-11eb-26a6-5d47e19a7230
md"""
# Line Search
"""

# ╔═╡ 24b2fe6c-9004-11eb-1e5f-0317dd2e85aa
md"""
### First Wolfe Condition
"""

# ╔═╡ 4794ee64-8f34-11eb-1ef2-5981f0e059df
β = 0.2

# ╔═╡ a00a4ec4-8f34-11eb-3db7-49be2cca0e5f
x₀ = 1.5

# ╔═╡ 80e1c23c-8f2e-11eb-3beb-519be0766468
md"""
α = $(@bind αlinedemo Slider(0.05:0.05:5.0, default = 5.0))
"""

# ╔═╡ ed8b99da-8f2c-11eb-14c5-0393c6d531c4
begin
	p1 = plot(fline, xlims = (0, 7.0), ylims = (0.45, 1.65), color = :black, xlabel = "x", ylabel = "f(x)", label = "")
	first_wolf_bound = fline(x₀) + β * αlinedemo * ∇fline(x₀)
	color = fline(x₀ + αlinedemo) < first_wolf_bound ? :green : :red 
	plot!(Shape([0.0, 7.0, 7.0, 0.0, 0.0], [0.0, 0.0, first_wolf_bound, first_wolf_bound, 0.0]), color = color, alpha = 0.3, label = "")
	scatter!([x₀], [fline(x₀)], color = :black, label = "x₀")
	scatter!([x₀ + αlinedemo], [fline(x₀ + αlinedemo)], color = :gray, label = "f(x₀ + αd)")
	if fline(x₀ + αlinedemo) < first_wolf_bound
		xs = collect(x₀ + αlinedemo:0.05:4.05)
		ys = fline.(xs)
		plot!(xs, ys, color = :green, linewidth = 6, label = "")
	end
	p1
end

# ╔═╡ 4c0b5eac-8f35-11eb-06b4-a75f220c7f78
md"""	
**f(x₀ + α):** $(fline(x₀ + αlinedemo)) 

**f(x₀) + βα∇f(x₀):** $first_wolf_bound
"""

# ╔═╡ 3954970e-9004-11eb-3be9-5f7adea26bc2
md"""
### Backtracking Line Search
"""

# ╔═╡ 5479f7d8-8fee-11eb-134b-a781d0affff4
function backtracking_line_search(f, ∇f, x, d, α; p = 0.5, β = 1e-4)
	y, g = f(x), ∇f(x)
	while f(x + α*d) > y + β*α*(g'd)
		α *= p
	end
	α
end

# ╔═╡ f87f64da-8fee-11eb-15fe-8f8090d4d226
md"""
p = $(@bind p NumberField(0.3:0.1:0.9, default = 0.8))
"""

# ╔═╡ ecaf9fe4-8fee-11eb-1c05-d76ef0f7ee1e
begin
	plot(fline, xlims = (0, 7.0), ylims = (0.45, 1.65), color = :black, xlabel = "x", ylabel = "f(x)", label = "", legend = false)
	
	xs1 = collect(x₀:0.05:4.05)
	ys1 = fline.(xs1)
	
	plot!(xs1, ys1, color = :green, linewidth = 6)
	
	function get_trace()
		αbt = 5.0
		attempted_xs = [x₀ + αbt]
		attempted_fs = [fline(x₀ + αbt)]

		while fline(x₀ + αbt) > fline(x₀) + β * αbt * ∇fline(x₀)
			αbt *= p
			push!(attempted_xs, x₀ + αbt)
			push!(attempted_fs, fline(x₀ + αbt))
		end
		return attempted_xs, attempted_fs
	end
	
	attempted_xs, attempted_fs = get_trace()
	
	scatter!(attempted_xs[1:end-1], attempted_fs[1:end-1], color = :red, markersize = 6)
	scatter!([attempted_xs[end]], [attempted_fs[end]], color = :green, markersize = 6)
	scatter!([x₀], [fline(x₀)], color = :black, label = "x₀", markersize = 6)
end

# ╔═╡ 827f2e30-8ffd-11eb-2cd6-9b1edfa701f9
md"""
### Backtracking line search on the Rosenbrock function
"""

# ╔═╡ 3f536d2c-9003-11eb-23c7-7b0b0a92d51a
md"""
nsteps = $(@bind nstepsbls NumberField(0:1:7, default = 0))
"""

# ╔═╡ e0fea120-8ffd-11eb-2cac-4f6e4547cc26
begin
	xr = -2:0.1:2
	yr = -2:0.1:2
	
	# Contour of rosenbrock
	c = contour(xr, yr, rosenbrock, levels=[0.5,1,2,3,5,10,20,50,100], colorbar = false, c = cgrad(:viridis, rev = true), legend = false, xlims = (-2, 2), ylims = (-2, 2), xlabel = "x₁", ylabel = "x₂", aspectratio = :equal)
	xbls = [-1.75, -1.75]
	scatter!([xbls[1]], [xbls[2]], color = :black)
	
	pbls = 0.5
	βbls = 1e-4
	αmaxbls = 6.0
	#nstepsbl = 7
	for k in 1:nstepsbls
		d = -∇rosenbrock(xbls)
		α = αmaxbls
		y, g = rosenbrock(xbls), ∇rosenbrock(xbls)
		
		dir = normalize(d, 2)
		plot!([xbls[1], xbls[1] + 6dir[1]], [xbls[2], xbls[2] + 6dir[2]], color = :red)
		
		while rosenbrock(xbls + α*d) ≥ y + βbls*α*(g⋅d)
			x_push = xbls + d*α
			if -2 ≤ x_push[1] ≤ 2 && -2 ≤ x_push[2] ≤ 2
				scatter!([x_push[1]], [x_push[2]], color = :red)
			end
			α *= pbls
		end
		scatter!([xbls[1] + d[1]*α], [xbls[2] + d[2]*α], color = :black)
		plot!([xbls[1], xbls[1] + d[1]*α], [xbls[2], xbls[2] + d[2]*α], color = :black)
		xbls += d*α
	end
	c
end

# ╔═╡ 4848aa34-9004-11eb-1408-5598d9e145f3
md"""
### Curvature Condition
"""

# ╔═╡ 3ae1a64c-9005-11eb-32cd-adbd7cb6651a
md"""
σ = $(@bind σcurve NumberField(0.1:0.1:1, default = 0.4))
"""

# ╔═╡ 55f1ca30-9004-11eb-2658-972069811aa5
begin
	p2 = plot(fline, xlims = (0, 7.0), ylims = (0.45, 1.65), color = :black, xlabel = "x", ylabel = "f(x)", label = "")
	scatter!([x₀], [fline(x₀)], color = :black, label = "x₀")
	
	gradx₀ = ∇fline(x₀)
	points_curv = collect(x₀:0.05:7)
	gradpoints_curv = ∇fline.(points_curv)
	inds_curv = findall(gradpoints_curv .≥ σcurve * gradx₀)
	
	diffs_inds_curv = [inds_curv[i+1] - inds_curv[i] for i = 1:length(inds_curv)-1]
	breaks_curv = findall(diffs_inds_curv .> 1)
	
	if breaks_curv != nothing
		for i = 1:length(breaks_curv)
			if i == 1
				start_ind = 1
			else
				start_ind = breaks_curv[i-1] + 1
			end
			plot_inds = inds_curv[start_ind:breaks_curv[i]]
			plot!(points_curv[plot_inds], fline.(points_curv[plot_inds]), color = :green, linewidth = 6, label = "")
		end
		plot!(points_curv[inds_curv[breaks_curv[end]+1:end]], fline.(points_curv[inds_curv[breaks_curv[end]+1:end]]), color = :green, linewidth = 6, label = "")
	else
		plot!(points_curv[inds_curv], fline.(points_curv[inds_curv]), color = :green, linewidth = 6, label = "")
	end
	p2
end

# ╔═╡ 529ef5e6-9007-11eb-05b2-a70d8ad51908
md"""
### Strong Curvature Condition (Second Wolfe Condition)
"""

# ╔═╡ 9afa6fa8-9007-11eb-0d4e-01881e229cc7
md"""
σ = $(@bind σscurve NumberField(0.1:0.1:1, default = 0.4))
"""

# ╔═╡ 63249a1a-9007-11eb-2630-0523c391ee59
begin
	p3 = plot(fline, xlims = (0, 7.0), ylims = (0.45, 1.65), color = :black, xlabel = "x", ylabel = "f(x)", label = "")
	scatter!([x₀], [fline(x₀)], color = :black, label = "x₀")
	
	points_scurv = collect(x₀:0.05:7)
	gradpoints_scurv = ∇fline.(points_scurv)
	inds_scurv = findall(abs.(gradpoints_scurv) .≤ -σscurve * gradx₀)
	
	diffs_inds_scurv = [inds_scurv[i+1] - inds_scurv[i] for i = 1:length(inds_scurv)-1]
	breaks_scurv = findall(diffs_inds_scurv .> 1)
	
	if breaks_scurv != nothing
		for i = 1:length(breaks_scurv)
			if i == 1
				start_ind = 1
			else
				start_ind = breaks_scurv[i-1] + 1
			end
			plot_inds = inds_scurv[start_ind:breaks_scurv[i]]
			plot!(points_scurv[plot_inds], fline.(points_scurv[plot_inds]), color = :green, linewidth = 6, label = "")
		end
		plot!(points_scurv[inds_scurv[breaks_scurv[end]+1:end]], fline.(points_scurv[inds_scurv[breaks_scurv[end]+1:end]]), color = :green, linewidth = 6, label = "")
	else
		plot!(points_scurv[inds_scurv], fline.(points_scurv[inds_scurv]), color = :green, linewidth = 6, label = "")
	end
	p3
end

# ╔═╡ e7ca1b5c-9008-11eb-2e5b-972ffbcdad4b
md"""
### Wolfe Conditions
"""

# ╔═╡ 0201e428-9009-11eb-3b2f-d7f3bb5b1831
begin
	p4 = plot(fline, xlims = (0, 7.0), ylims = (0.45, 1.65), color = :black, xlabel = "x", ylabel = "f(x)", label = "")
	scatter!([x₀], [fline(x₀)], color = :black, label = "x₀")
	
	points_wolfe = collect(x₀:0.05:7)
	gradpoints_wolfe = ∇fline.(points_wolfe)
	inds_wolfe1 = findall(fline.(points_wolfe) .≤ fline(x₀) .+ (β .* (points_wolfe .- x₀) .* ∇fline(x₀)))
	inds_wolfe2 = findall(abs.(gradpoints_wolfe) .≤ -σscurve * gradx₀)
	
	diffs_inds_wolfe2 = [inds_wolfe2[i+1] - inds_wolfe2[i] for i = 1:length(inds_wolfe2)-1]
	breaks_wolfe2 = findall(diffs_inds_wolfe2 .> 1)
	
	if breaks_wolfe2 != nothing
		for i = 1:length(breaks_wolfe2)
			if i == 1
				start_ind = 1
			else
				start_ind = breaks_wolfe2[i-1] + 1
			end
			plot_inds = inds_wolfe2[start_ind:breaks_wolfe2[i]]
			plot!(points_wolfe[plot_inds], fline.(points_wolfe[plot_inds]), color = :red, linewidth = 6, label = "")
		end
		plot!(points_wolfe[inds_wolfe2[breaks_wolfe2[end]+1:end]], fline.(points_wolfe[inds_wolfe2[breaks_wolfe2[end]+1:end]]), color = :red, linewidth = 6, label = "2nd Wolfe")
	else
		plot!(points_wolfe[inds_wolfe2], fline.(points_wolfe[inds_wolfe2]), color = :red, linewidth = 6, label = "2nd Wolfe")
	end
	
	plot!(points_wolfe[inds_wolfe1], fline.(points_wolfe[inds_wolfe1]), color = :blue, linewidth = 6, label = "1st Wolfe")
	
	inds_both_wolfe = intersect(inds_wolfe1, inds_wolfe2)
	
	plot!(points_wolfe[inds_both_wolfe], fline.(points_wolfe[inds_both_wolfe]), color = :green, linewidth = 6, label = "Both")
	
	p4
end

# ╔═╡ 631fc672-900b-11eb-1fe2-a531dac443b1
md"""
### Strong Backtracking Line Search
"""

# ╔═╡ a738a7fb-0ebb-42c5-bc2d-af1a4ea72bfc
md"""
If one of the following conditions hold, an interval is guaranteed to contain step lengths satisfying the Wolfe conditions:

$f(\mathbf{x} + \alpha^{(k)}\mathbf{d}) \geq f(\mathbf{x})$

$f(\mathbf{x^{(k)}} + \alpha^{(k)}\mathbf{d^{(k)}}) \geq f(\mathbf{x^{(k)}}) + \beta\alpha\nabla_{\mathbf{d}^{(k)}}f(\mathbf{x}^{(k)})$

$\nabla f(\mathbf{x} + \alpha^{(k)}\mathbf{d}) \geq \mathbf{0}$
"""

# ╔═╡ 272c43fc-9012-11eb-07f6-3d0625cafbab
md"""
nsteps = $(@bind nstepssbls NumberField(0:1:7, default = 0))
"""

# ╔═╡ 75b076d0-900b-11eb-2875-b9b74ab9a943
begin
	x_init = 0.0
	cond1(α_hi) = ∇fline(x_init + α_hi) >= 0
	cond2(α_hi) = fline(x_init + α_hi) > fline(x_init) + β*α_hi*∇fline(x_init)
	cond3(α_hi) = fline(x_init + α_hi) >= fline(x_init)
	
	p5 = plot(fline, xlims = (0, 7.0), ylims = (0.45, 1.65), color = :black, xlabel = "x", ylabel = "f(x)", label = "")
	scatter!([x_init], [fline(x_init)], color = :black, label = "x₀", markersize = 6)
	
	points_cd = collect(0.5:0.05:7)
	cd1 = cond1.(points_cd)
	cd2 = cond2.(points_cd)
	cd3 = cond3.(points_cd)
	inds_cd = findall(cd1 .| cd2 .| cd3)
	
	diffs_inds_cd = [inds_cd[i+1] - inds_cd[i] for i = 1:length(inds_cd)-1]
	breaks_cd = findall(diffs_inds_cd .> 1)
	
	if breaks_cd != nothing
		for i = 1:length(breaks_cd)
			if i == 1
				start_ind = 1
			else
				start_ind = breaks_cd[i-1] + 1
			end
			plot_inds = inds_cd[start_ind:breaks_cd[i]]
			plot!(points_cd[plot_inds], fline.(points_cd[plot_inds]), color = :blue, linewidth = 6, label = "")
		end
		plot!(points_cd[inds_cd[breaks_cd[end]+1:end]], fline.(points_cd[inds_cd[breaks_cd[end]+1:end]]), color = :blue, linewidth = 6, label = "Interval Conditions")
	else
		plot!(points_cd[inds_cd], fline.(points_cd[inds_cd]), color = :blue, linewidth = 6, label = "Interval Conditions")
	end
	
	function sbls()
		α = 0.6
		y0, g0, y_prev, α_prev = fline(x_init), ∇fline(x_init), NaN, 0

		for k = 1:nstepssbls
			y = fline(x_init + α)

			scatter!([α], [y], color = :black, label = "", markersize = 6)

			if y > y0 + β*α*g0 || (!isnan(y_prev) && y >= y_prev)

				α = 0.75α # bisection
				y = fline(α)
				scatter!([α], [y], color = :red, label = "", markersize = 6)
			end
			g = ∇fline(x_init + α)
			if abs(g) <= -σscurve * g0
				break
			elseif g >= 0
				break
			end
			α_prev, α = α, 2α
			y_prev = y
		end
	end
	
	sbls()
	p5
end

# ╔═╡ 81f2c770-9012-11eb-099f-dda2f9c4246f
md"""
# Trust Region Methods
"""

# ╔═╡ e9e89ffc-9018-11eb-1028-856604a9f26b
md"""
nsteps = $(@bind nstepstrust NumberField(0:1:10, default = 0))
"""

# ╔═╡ 447b2884-9013-11eb-1457-0b057903165f
begin
	function solve_trust_region_subproblem(∇f, H, x0, δ)

		Hx0 = H(x0)
		∇fx0 = ∇f(x0)

		# Unconstrained
		f = x -> ∇fx0⋅(x-x0) + ((x-x0)'*Hx0)⋅(x-x0)/2

		# Constrained with huge penalty
		g = x -> norm(x-x0) <= δ ? f(x) : 9999999.0

		result = optimize(g, x0, NelderMead())

		return (result.minimizer, result.minimum)
	end
	
	# Contour of rosenbrock
	cr = contour(xr, yr, rosenbrock, levels=[0.5,1,2,3,5,10,20,50,100], colorbar = false, c = cgrad(:viridis, rev = true), legend = false, xlims = (-2, 2), ylims = (-2, 2), xlabel = "x₁", ylabel = "x₂", aspectratio = :equal)
	
	#scatter!([xbls[1]], [xbls[2]], color = :blue)
	
	function trust_region_rosenbrock(k_max)
		x₀ = [-1.75,-1.75]
		x = deepcopy(x₀)
		y = rosenbrock(x)
		δ = 1.0
		θs = range(0,stop=2π,length=101)
		η1=0.25; η2=0.5; γ1=0.5; γ2=2.0; δ=1.0
		
		for k = 1:k_max
			scatter!([x[1]], [x[2]], color = :black, alpha = k/k_max)
			plot!([x[1] + δ*cos(θ) for θ in θs], [x[2] + δ*sin(θ) for θ in θs], color = :black, alpha = k/k_max)
			
			x′, y′ = solve_trust_region_subproblem(∇rosenbrock, Hrosenbrock, x, δ)
			r = (y - rosenbrock(x′)) / (y - y′)
			if r < η1
				δ *= γ1
			else
				x, y = x′, rosenbrock(x′)
				if r > η2
					δ *= γ2
				end
			end
		end
	end
	
	trust_region_rosenbrock(nstepstrust)
	
	cr
end

# ╔═╡ 82a6b55a-90df-11eb-119b-9d94c9420aae
md"""
# First-Order Methods
"""

# ╔═╡ 9c3268ac-90df-11eb-3a09-cd5b1e01213d
md"""
### Gradient Descent
"""

# ╔═╡ 9397f2be-90e1-11eb-2a0c-559077244bd9
md"""
nsteps = $(@bind nstepsgd NumberField(0:1:10, default = 0))
"""

# ╔═╡ a9d3e5b2-90df-11eb-388f-eb7a9433a6dd
begin
	# Contour of rosenbrock
	cr1 = contour(xr, yr, rosenbrock, levels=[0.5,1,2,3,5,10,20,50,100], colorbar = false, c = cgrad(:viridis, rev = true), legend = false, xlims = (-2, 2), ylims = (-2, 2), xlabel = "x₁", ylabel = "x₂", aspectratio = :equal)
	scatter!([-1.0], [-1.0], color = :black)
	
	# For solving for α
	function secant_method(df, x1, x2, ϵ)
	    df1 = df(x1)

	    delta = Inf
	    while abs(delta) > ϵ
	    	df2 = df(x2)
	        delta = (x2 - x1)/(df2 - df1)*df2
	        x1, x2, df1 = x2, x2 - delta, df2
	    end
	    x2
	end
	
	# Run 
	df(x,y) = [2*(10*x^3-10*x*y+x-1), 10*(y-x^2)]
	
	function grad_descent(nsteps)
		p0 = (-1, -1)
		pts_grad = Tuple{Float64,Float64}[p0]
		for i in 1 : nsteps
			x, y = pts_grad[end]
			dp = normalize(-VecE2{Float64}(df(x, y)...))

			f1d = a -> begin
				x2 = x + a*dp.x
				y2 = y + a*dp.y

				da = df(x2, y2)
				pa = VecE2{Float64}(da[1], da[2])
				proj(pa, dp, Float64)
			end
			alpha = secant_method(f1d, 0.0, 1.0, 0.0001)
			push!(pts_grad, (x + alpha*dp.x, y + alpha*dp.y))
		end
		return pts_grad
	end
	
	pts_grad = grad_descent(10)
	
	plot!([pts_grad[i][1] for i = 1:nstepsgd+1], [pts_grad[i][2] for i = 1:nstepsgd+1], color = :black, linewidth = 2)
end

# ╔═╡ d59fd8f2-90e1-11eb-102a-f36334c851b4
md"""
### Conjugate Gradient Descent
"""

# ╔═╡ 0263d884-90e7-11eb-2d19-37a0ebcf527b
md"""
nsteps = $(@bind nstepsgd_conj NumberField(0:1:10, default = 0))
"""

# ╔═╡ c589570a-90e5-11eb-2100-45f865a96a02
begin
	# Contour of rosenbrock
	cr2 = contour(xr, yr, rosenbrock, levels=[0.5,1,2,3,5,10,20,50,100], colorbar = false, c = cgrad(:viridis, rev = true), legend = false, xlims = (-2, 2), ylims = (-2, 2), xlabel = "x₁", ylabel = "x₂", aspectratio = :equal)
	scatter!([-1.0], [-1.0], color = :black)
	
	function conj_grad(nsteps)
		x0 = Float64[-1, -1]
		pts_conj = Vector{Float64}[x0]
		g0 = ∇rosenbrock(x0)
		d0 = -g0
		f1d = a -> begin
			da = ∇rosenbrock(x0 + a*d0)
			proj(VecE2{Float64}(da[1], da[2]), VecE2{Float64}(d0[1], d0[2]), Float64)
		end
		alpha = secant_method(f1d, 0.0, 0.1, 0.0001) # NOTE: is sensitive to the value of 0.1, does not work with 1.0!
		push!(pts_conj, x0 + alpha*d0)

		for i in 1 : nsteps
			x = pts_conj[end]
			g1 = ∇rosenbrock(x)
			β = max(0.0, dot(g1, g1-g0)/dot(g0,g0))
			d1 = -g1 + β*d0

			f1d = a -> begin
				da = ∇rosenbrock(x + a*d1)
				proj(VecE2{Float64}(da[1], da[2]), VecE2{Float64}(d1[1], d1[2]), Float64)
			end
			alpha = secant_method(f1d, 0.0, 0.1, 0.0001)
			push!(pts_conj, x + alpha*d1)

			d0 = d1
			g0 = g1
		end
		return pts_conj
	end
	
	pts_conj = conj_grad(10)
	
	plot!([pts_grad[i][1] for i = 1:nstepsgd_conj+1], [pts_grad[i][2] for i = 1:nstepsgd_conj+1], color = :black, linewidth = 2, alpha = 0.5)
	plot!([pts_conj[i][1] for i = 1:nstepsgd_conj+1], [pts_conj[i][2] for i = 1:nstepsgd_conj+1], color = :black, linewidth = 2)
end

# ╔═╡ 04834139-2837-4891-9ba1-4f16c32df04f
md"""
### Momentum
"""

# ╔═╡ 50688a3b-c1bf-4cde-a820-874158384fae
md"""
nsteps = $(@bind nstepsgd_mom NumberField(0:1:40, default = 0))
"""

# ╔═╡ 7967346e-bf2f-4791-8e5a-11fee51ba9de
begin
	xr2 = -3:0.1:2
	yr2 = -0.5:0.1:2
	# Contour of rosenbrock 2
	cr3 = contour(xr2, yr2, rosenbrock2, levels=[25,50,100,200,250,300], colorbar = false, c = cgrad(:viridis, rev = true), legend = false, xlims = (-3, 2), ylims = (-0.5, 2), xlabel = "x₁", ylabel = "x₂", aspectratio = :equal, clim = (2, 500))
	scatter!([-2.0], [1.5], color = :black)
	
	abstract type DescentMethod end
	
	function this_step!(M::DescentMethod, v::VecE2{Float64})
	    x = Float64[v.x, v.y]
	    return VecE2{Float64}(step!(M, rosenbrock2, ∇rosenbrock2, x)...)
	end
	
	function run_descent_method(M::DescentMethod, x₀::VecE2{Float64}, N::Int)
	    pts = [x₀]
	    init!(M, rosenbrock2, ∇rosenbrock2, Float64[x₀.x, x₀.y])
	    for i in 1 : N
	        push!(pts, this_step!(M, pts[end]))
	    end
	    return pts
	end
	
	struct GradientDescent <: DescentMethod
		α
	end
	
	function init!(M::GradientDescent, f, ∇f, x)
			return M
	end
	
	function step!(M::GradientDescent, f, ∇f, x)
		α, g = M.α, ∇f(x)
		return x - α*g
	end
	
	mutable struct Momentum <: DescentMethod
		α # learning rate
		β # momentum decay
		v # momentum
	end
	
	function init!(M::Momentum, f, ∇f, x)
		M.v = zeros(length(x))
		return M
	end
	
	function step!(M::Momentum, f, ∇f, x)
		α, β, v, g = M.α, M.β, M.v, ∇f(x)
		v[:] = β*v - α*g
		return x + v
	end
	
	mutable struct NesterovMomentum <: DescentMethod
		α # learning rate
		β # momentum decay
		v # momentum
	end

	function init!(M::NesterovMomentum, f, ∇f, x)
		M.v = zeros(length(x))
		return M
	end

	function step!(M::NesterovMomentum, f, ∇f, x)
		α, β, v = M.α, M.β, M.v
		v[:] = β*v - α*∇f(x + β*v)
		return x + v
	end
	
	mutable struct HyperGradientDescent <: DescentMethod
		α0 # initial learning rate
		μ # learning rate of the learning rate
		α # current learning rate
		g_prev # previous gradient
	end
	
	function init!(M::HyperGradientDescent, f, ∇f, x)
		M.α = M.α0
		M.g_prev = zeros(length(x))
		return M
	end
	
	function step!(M::HyperGradientDescent, f, ∇f, x)
		α, μ, g, g_prev = M.α, M.μ, ∇f(x), M.g_prev
		α = α + μ*(g⋅g_prev)
		M.g_prev, M.α = g, α
		return x - α*g
	end

	mutable struct HyperNesterovMomentum <: DescentMethod
		α0 # initial learning rate
		μ # learning rate of the learning rate
		β # momentum decay
		v # momentum
		α # current learning rate
		g_prev # previous gradient
	end
	
	function init!(M::HyperNesterovMomentum, f, ∇f, x)
		M.α = M.α0
		M.v = zeros(length(x))
		M.g_prev = zeros(length(x))
		return M
	end
	
	function step!(M::HyperNesterovMomentum, f, ∇f, x)
		α, β, μ = M.α, M.β, M.μ
		v, g, g_prev = M.v, ∇f(x), M.g_prev
		α = α - μ*(g⋅(-g_prev - β*v))
		v[:] = β*v + g
		M.g_prev, M.α = g, α
		return x - α*(g + β*v)
	end
	
	N = 40
	
	pts_gd = run_descent_method(GradientDescent(0.0003), VecE2{Float64}(-2,1.5), N)
	pts_mom = run_descent_method(Momentum(0.0003, 0.9, zeros(2)), VecE2{Float64}(-2,1.5), N)
	
	plot!([pts_gd[i][1] for i = 1:nstepsgd_mom + 1], [pts_gd[i][2] for i = 1:nstepsgd_mom + 1], color = :black, linewidth = 2, alpha = 0.5)
	plot!([pts_mom[i][1] for i = 1:nstepsgd_mom + 1], [pts_mom[i][2] for i = 1:nstepsgd_mom + 1], color = :black, linewidth = 2)
end

# ╔═╡ bf301087-6624-4c56-a8d2-dc7a9856d33e
md"""
### Nesterov Momentum
"""

# ╔═╡ 5c4506ab-c281-4f94-a60a-ef5d727fe125
md"""
nsteps = $(@bind nstepsnest_mom NumberField(0:1:40, default = 0))
"""

# ╔═╡ b638d908-35a9-4203-945a-1086f4dba559
begin
	# Contour of rosenbrock 2
	cr4 = contour(xr2, yr2, rosenbrock2, levels=[25,50,100,200,250,300], colorbar = false, c = cgrad(:viridis, rev = true), legend = false, xlims = (-3, 2), ylims = (-0.5, 2), xlabel = "x₁", ylabel = "x₂", aspectratio = :equal, clim = (2, 500))
	scatter!([-2.0], [1.5], color = :black)
	
	pts_nest_mom = run_descent_method(NesterovMomentum(0.0002, 0.92, zeros(2)), VecE2{Float64}(-2,1.5), N)
	
	plot!([pts_mom[i][1] for i = 1:nstepsnest_mom + 1], [pts_mom[i][2] for i = 1:nstepsnest_mom + 1], color = :black, linewidth = 2, alpha = 0.5)
	plot!([pts_nest_mom[i][1] for i = 1:nstepsnest_mom + 1], [pts_nest_mom[i][2] for i = 1:nstepsnest_mom + 1], color = :black, linewidth = 2)
end

# ╔═╡ d0a4ca13-8ea4-4451-ba88-b46d28a1ba89
md"""
### Hypergradient Descent and Hyper-Nesterov
"""

# ╔═╡ b3759a50-11d4-4d96-a80b-bcb6a76ba944
md"""
nsteps = $(@bind nstepshyper NumberField(0:1:40, default = 0))
"""

# ╔═╡ 36099212-4d39-4e22-a142-0b9b88263de2
begin
	# Contour of rosenbrock 2
	cr5 = contour(xr2, yr2, rosenbrock2, levels=[25,50,100,200,250,300], colorbar = false, c = cgrad(:viridis, rev = true), legend = false, xlims = (-3, 2), ylims = (-0.5, 2), xlabel = "x₁", ylabel = "x₂", aspectratio = :equal, clim = (2, 500))
	scatter!([-2.0], [1.5], color = :black)
	
	pts_hyp_gd = run_descent_method(HyperGradientDescent(0.0004, 8e-13, NaN, zeros(2)), VecE2{Float64}(-2,1.5), N)
	pts_hyp_nest = run_descent_method(HyperNesterovMomentum(0.00023, 1e-12, 0.93, zeros(2), NaN, zeros(2)), VecE2{Float64}(-2,1.5), N)
	
	plot!([pts_hyp_gd[i][1] for i = 1:nstepshyper + 1], [pts_hyp_gd[i][2] for i = 1:nstepshyper + 1], color = :black, linewidth = 2, alpha = 0.5)
	plot!([pts_hyp_nest[i][1] for i = 1:nstepshyper + 1], [pts_hyp_nest[i][2] for i = 1:nstepshyper+ 1], color = :black, linewidth = 2)
end

# ╔═╡ Cell order:
# ╠═7dea2baa-8f2c-11eb-184b-cb353ca6ca79
# ╠═9fd099fc-8f2c-11eb-286e-a548737f4572
# ╠═9633d3f8-9000-11eb-3d5a-b3dd2a013890
# ╠═2c140db8-9013-11eb-21d9-f7718dc9cf57
# ╠═56018eb0-90e1-11eb-18c0-e1f1aecf307c
# ╠═5fead5d4-8f2d-11eb-2d3c-a34658637923
# ╠═bf810ea8-8f2c-11eb-2d6e-3dcb7961b1fa
# ╠═99e23b7a-8ffd-11eb-1b86-9940c74de5fc
# ╠═9d46db42-8ffe-11eb-1f0f-1d6553bcd608
# ╠═9a62773e-8ffd-11eb-315a-611790d3d945
# ╠═fb5587cc-9012-11eb-313a-512bd0f9651b
# ╠═fb7ea5ef-a2be-43a5-aae6-1bacc3a65f1e
# ╠═db569392-347f-45b1-b7c6-e2a0c235cff9
# ╠═1d09ca7a-8b25-4f3a-9f7d-ef586dd80be8
# ╠═cb524eeb-d78d-4125-8e5a-5da5e14644bb
# ╟─5e9fcab4-d2fe-445d-9b8e-2fe9fe50444d
# ╟─70855f33-c00d-49c3-82ec-f891ae4b40c5
# ╟─a3ae828c-3354-43e4-bf49-2284e465660d
# ╟─0259e325-9558-4dfc-9ca8-06daade248b9
# ╟─e54c3874-667d-42a8-ba9f-5376f3ae3bd6
# ╟─33f938e6-8229-4baa-9e1c-3c0215c53197
# ╟─9402e2b6-757e-4632-aac2-7251b28a768a
# ╟─a364ef52-8f2c-11eb-26a6-5d47e19a7230
# ╟─24b2fe6c-9004-11eb-1e5f-0317dd2e85aa
# ╟─4794ee64-8f34-11eb-1ef2-5981f0e059df
# ╟─a00a4ec4-8f34-11eb-3db7-49be2cca0e5f
# ╟─80e1c23c-8f2e-11eb-3beb-519be0766468
# ╟─4c0b5eac-8f35-11eb-06b4-a75f220c7f78
# ╟─ed8b99da-8f2c-11eb-14c5-0393c6d531c4
# ╟─3954970e-9004-11eb-3be9-5f7adea26bc2
# ╠═5479f7d8-8fee-11eb-134b-a781d0affff4
# ╟─f87f64da-8fee-11eb-15fe-8f8090d4d226
# ╟─ecaf9fe4-8fee-11eb-1c05-d76ef0f7ee1e
# ╟─827f2e30-8ffd-11eb-2cd6-9b1edfa701f9
# ╟─3f536d2c-9003-11eb-23c7-7b0b0a92d51a
# ╟─e0fea120-8ffd-11eb-2cac-4f6e4547cc26
# ╟─4848aa34-9004-11eb-1408-5598d9e145f3
# ╟─3ae1a64c-9005-11eb-32cd-adbd7cb6651a
# ╟─55f1ca30-9004-11eb-2658-972069811aa5
# ╟─529ef5e6-9007-11eb-05b2-a70d8ad51908
# ╟─9afa6fa8-9007-11eb-0d4e-01881e229cc7
# ╟─63249a1a-9007-11eb-2630-0523c391ee59
# ╟─e7ca1b5c-9008-11eb-2e5b-972ffbcdad4b
# ╟─0201e428-9009-11eb-3b2f-d7f3bb5b1831
# ╟─631fc672-900b-11eb-1fe2-a531dac443b1
# ╟─a738a7fb-0ebb-42c5-bc2d-af1a4ea72bfc
# ╟─272c43fc-9012-11eb-07f6-3d0625cafbab
# ╟─75b076d0-900b-11eb-2875-b9b74ab9a943
# ╟─81f2c770-9012-11eb-099f-dda2f9c4246f
# ╟─e9e89ffc-9018-11eb-1028-856604a9f26b
# ╟─447b2884-9013-11eb-1457-0b057903165f
# ╟─82a6b55a-90df-11eb-119b-9d94c9420aae
# ╟─9c3268ac-90df-11eb-3a09-cd5b1e01213d
# ╟─9397f2be-90e1-11eb-2a0c-559077244bd9
# ╟─a9d3e5b2-90df-11eb-388f-eb7a9433a6dd
# ╟─d59fd8f2-90e1-11eb-102a-f36334c851b4
# ╟─0263d884-90e7-11eb-2d19-37a0ebcf527b
# ╟─c589570a-90e5-11eb-2100-45f865a96a02
# ╟─04834139-2837-4891-9ba1-4f16c32df04f
# ╟─50688a3b-c1bf-4cde-a820-874158384fae
# ╟─7967346e-bf2f-4791-8e5a-11fee51ba9de
# ╟─bf301087-6624-4c56-a8d2-dc7a9856d33e
# ╟─5c4506ab-c281-4f94-a60a-ef5d727fe125
# ╟─b638d908-35a9-4203-945a-1086f4dba559
# ╟─d0a4ca13-8ea4-4451-ba88-b46d28a1ba89
# ╟─b3759a50-11d4-4d96-a80b-bcb6a76ba944
# ╟─36099212-4d39-4e22-a142-0b9b88263de2
