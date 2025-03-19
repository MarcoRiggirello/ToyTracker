### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# ╔═╡ 20152d8a-0418-11f0-1c66-1bf7d6de0c30
begin
	using Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()
	using TrackerAlignment, WGLMakie
	using Query, DataFrames
	using FileIO, CSVFiles
	WGLMakie.activate!()
	Makie.inline!(true)
end

# ╔═╡ b9aebc66-2ecc-49ac-9443-192cf8d9c3ec
md"""
# Saving synthetic data to file
"""

# ╔═╡ d57c7610-36f7-4b3f-a036-ce49568fd6da
md"""
Our aim is to generate synthetic data and save it to file for later use.

First, we need some sensor! let's define a strip and a pixel module.
"""

# ╔═╡ 5fa0f5c8-d1d2-4812-bfb1-027c44059bdf
begin
	# in cm
	pixel = IdealSensor(uwidth=10., vwidth=10., upitch=0.01, vpitch=0.01)
	strip = IdealSensor(uwidth=10., vwidth=10., upitch=0.01, vpitch=5.0)
end

# ╔═╡ c79442f7-61c2-4074-bcdc-38ddfbee81d7
md"""
Then we need to place them into the space in order to have a detector. Let's use a simple telescope geometry with stacked sensors. We put them slightly misaligned.
"""

# ╔═╡ 37470bf4-122a-4d16-9c6e-a2d67d95c90b
begin
	x = [0.0, 0.1, -0.1,  0.1, -0.1, 0.0]
	y = [0.0, 0.1,  0.0, -0.1,  1.0, 0.0]
	z = [10, 20, 30, 40, 50, 60]
	poses = [
		Pose(x=x, y=y, z=z, yaw=0, pitch=0, roll=0)
		for (x,y,z) in zip(x,y,z)
	]
	sensors = [pixel, pixel, pixel, strip, strip, strip]
	telescope = Tuple(PlacedSensor(s,p) for (s,p) in zip(sensors, poses))
end

# ╔═╡ d705462e-b206-4513-a5da-9cad99299349
begin
	fig2 = Figure()
	ax2 = Axis3(fig2[1,1], viewmode=:free)
	for p in telescope
		mesh!(ax2, p, alpha=.5)
	end
	fig2
end

# ╔═╡ d9769ab7-a005-4a35-8198-e789676409e9
md"""
Next we need to create a particle gun. Since we are using `Query`, we only need a generator in order to make the interaction work.
"""

# ╔═╡ 733af8e2-47bc-4d77-82e6-27297e528086
function particle_gun()
	# in cm
	x_sigma = 1.
	y_sigma = 1.
	# in rad
	x_angle = 0.01
	y_angle = 0.01
	return StraightTrack(
		x_sigma * randn(),
		y_sigma * randn(),
		x_angle * randn(),
		y_angle * randn()
	)
end

# ╔═╡ a74b6266-4d9a-45e4-b120-9112a35f9238
d = @from n in 1:10_000 begin
	@let t = particle_gun()
	@from sensor in enumerate(telescope)
	@let id = sensor[1]
	@let ps = sensor[2]
	@let h = interaction(t, ps)
	@where !ismissing(h)
	@let ip = ps.position(intersection(t, ps.position)[1])
	@let d = TrackerAlignment.flatten(h)
	@let track = (x=t.position.x, y=t.position.y, mx=t.direction.x, my=t.direction.y)
	@select {
		event=n,
		track_x0=track.x,
		track_y0=track.y,
		track_mx=track.mx,
		track_my=track.my,
		sensor_id=id,
		hit_u=d.u,
		hit_v=d.v,
		hit_Du=d.Δu,
		hit_Dv=d.Δv,
		res_u=d.u - ip.u,
		res_v=d.v - ip.v
	}
	@collect DataFrame
end

# ╔═╡ e47961b7-5a68-425a-aede-95c53e00512e
d |> save("culo.csv")

# ╔═╡ c0ce278a-e437-40dc-b6d6-1b1da7ecca5e
md"""
Lemme just see the residuals...
"""

# ╔═╡ eac2ce7a-2b6d-4da7-8142-4cdca06dabea
function plot_residuals(res_u, res_v)
	fig = Figure()
	ax1 = Axis(fig[1, 1])
	ax2 = Axis(fig[2, 1])
	ax3 = Axis(fig[2, 2])
	hist!(ax1, res_u; strokewidth=0.5)
    scatter!(ax2, res_u, res_v; markersize=1, strokewidth=0, alpha=0.5)
	hist!(ax3, res_v; direction=:x, strokewidth=0.5)
	hideydecorations!(ax3, ticks=false, grid=false)
	hidexdecorations!(ax1, ticks=false, grid=false)
	colsize!(fig.layout, 1, Relative(2 / 3))
	rowsize!(fig.layout, 1, Relative(1 / 3))
	colgap!(fig.layout, 10)
	rowgap!(fig.layout, 10)
	return fig
end

# ╔═╡ d120f2c4-afbf-4cfc-8be6-2cc5b9ee895a
begin
	res_u_pixel = @from e in d begin
		@where e.sensor_id == 1
		@select e.res_u
		@collect
	end
	res_v_pixel = @from e in d begin
		@where e.sensor_id == 1
		@select e.res_v
		@collect
	end
	plot_residuals(res_u_pixel, res_v_pixel)
end

# ╔═╡ bb777f49-7c0b-41ee-8ebf-db8890273077
begin
	res_u_strip = @from e in d begin
		@where e.sensor_id == 6
		@where e.hit_v > 0
		@select e.res_u
		@collect
	end
	res_v_strip = @from e in d begin
		@where e.sensor_id == 6
		@where e.hit_v > 0
		@select e.res_v
		@collect
	end
	plot_residuals(res_u_strip, res_v_strip)
end

# ╔═╡ Cell order:
# ╟─b9aebc66-2ecc-49ac-9443-192cf8d9c3ec
# ╠═20152d8a-0418-11f0-1c66-1bf7d6de0c30
# ╟─d57c7610-36f7-4b3f-a036-ce49568fd6da
# ╠═5fa0f5c8-d1d2-4812-bfb1-027c44059bdf
# ╟─c79442f7-61c2-4074-bcdc-38ddfbee81d7
# ╠═37470bf4-122a-4d16-9c6e-a2d67d95c90b
# ╠═d705462e-b206-4513-a5da-9cad99299349
# ╟─d9769ab7-a005-4a35-8198-e789676409e9
# ╠═733af8e2-47bc-4d77-82e6-27297e528086
# ╠═a74b6266-4d9a-45e4-b120-9112a35f9238
# ╠═e47961b7-5a68-425a-aede-95c53e00512e
# ╠═c0ce278a-e437-40dc-b6d6-1b1da7ecca5e
# ╠═eac2ce7a-2b6d-4da7-8142-4cdca06dabea
# ╠═d120f2c4-afbf-4cfc-8be6-2cc5b9ee895a
# ╠═bb777f49-7c0b-41ee-8ebf-db8890273077
