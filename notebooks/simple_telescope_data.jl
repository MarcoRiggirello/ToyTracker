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

# ╔═╡ b6f5a7c0-015a-4cd5-b6db-57508f123800
begin
	n_tracks = 1_000
	# in cm
	x_sigma = 1.
	y_sigma = 1.
	# in rad
	x_angle = 0.01
	y_angle = 0.01
	particle_gun = (
		StraightTrack(
			x_sigma * randn(),
			y_sigma * randn(),
			x_angle * randn(),
			y_angle * randn()
		)
		for _ in 1:n_tracks
	)
end

# ╔═╡ a74b6266-4d9a-45e4-b120-9112a35f9238
d = @from t in particle_gun begin
	@let hits = interaction.((t,), telescope)
	@where all(!ismissing(h) for h in hits)
	@let data = collect(
		d => h for (d,h) in enumerate(TrackerAlignment.flatten.(hits))
	)
	@let track = (x=t.position.x, y=t.position.y, mx=t.direction.x, my=t.direction.y)
	@select {track, data}
	@collect DataFrame
end

# ╔═╡ e47961b7-5a68-425a-aede-95c53e00512e
d |> save("culo.csv")

# ╔═╡ Cell order:
# ╟─b9aebc66-2ecc-49ac-9443-192cf8d9c3ec
# ╠═20152d8a-0418-11f0-1c66-1bf7d6de0c30
# ╟─d57c7610-36f7-4b3f-a036-ce49568fd6da
# ╠═5fa0f5c8-d1d2-4812-bfb1-027c44059bdf
# ╟─c79442f7-61c2-4074-bcdc-38ddfbee81d7
# ╠═37470bf4-122a-4d16-9c6e-a2d67d95c90b
# ╠═d705462e-b206-4513-a5da-9cad99299349
# ╟─d9769ab7-a005-4a35-8198-e789676409e9
# ╠═b6f5a7c0-015a-4cd5-b6db-57508f123800
# ╠═a74b6266-4d9a-45e4-b120-9112a35f9238
# ╠═e47961b7-5a68-425a-aede-95c53e00512e
