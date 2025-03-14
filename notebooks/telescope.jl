### A Pluto.jl notebook ###
# v0.20.4

#> [[frontmatter.author]]
#> name = "Marco Riggirello"

using Markdown
using InteractiveUtils

# ╔═╡ 3d8ac329-b4ef-43eb-be79-53678efaea8d
begin
	using Pkg
    Pkg.activate(Base.current_project())
    Pkg.instantiate()
	using ToyTracker, WGLMakie, FileIO
	WGLMakie.activate!()
	Makie.inline!(true)
end

# ╔═╡ 61d51130-00fa-43af-894c-cf433f7e33fd
md"""
# A simple particle telescope event generation
"""

# ╔═╡ 088eafbb-312c-4b7c-a0f1-2e1634175434
md"""
In this notebook we want to introduce the ergonomics of the `ToyTracker` experimental package as well as generating some synthetic data for track-based alignment studies.

To simulate a particle tracker and its response to the passage of a particle, we need to know five things:
- How does the particle move?
- What is a sensor?
- Where are the sensors?
- Where does the particle cross the sensor?
- How does the sensor respond to a particle passing through it?

Thus, before moving to the actual generation, I will quickly review all the components needed to answer to the very five questions above.
"""

# ╔═╡ 7c5e5dc6-8e72-4904-9c99-5011cd2b6903
md"""
## The building blocks of tracking simulation
"""

# ╔═╡ d200b5e9-40ea-4b73-9aca-f95a6f9609ce
md"""
### Homogeneous representation of coordinates tranformations
"""

# ╔═╡ 0239c88e-6efb-4b86-aee3-cb5d6aadf5ec
md"""
First thing to know is how to move from the reference frame of the lab to the one of the sensor, where the planar measurement happens.

If we have a point in the local reference frame of coordinates $(u, v, w)^T$ we can obtain its coordinates into the global reference frame by knowing the rotation matrix $\mathbf{R}$ and the translation vector $\mathbf{t}$

$\begin{bmatrix}
x \\
y \\
z
\end{bmatrix}
= \mathbf{R} \begin{bmatrix}
u \\
v \\
w
\end{bmatrix}
+
\begin{bmatrix}
t_x \\
t_y \\
t_z
\end{bmatrix}$

"""

# ╔═╡ 13d99be7-e46b-42cc-9cc1-82d17edf6e54
md"""

The set of 3D rotations + 3D translations forms a group called SE(3) and it is all what we need to move a rigid body into the space.

 One very handy representation is the *homogeneous representation*: if the coordinates  of a point in the 3D space are represented by 4D vectors like

$\mathbf{x} = \begin{bmatrix}
x \\
y \\
z \\
1
\end{bmatrix}, \qquad
\mathbf{u} = \begin{bmatrix}
u \\
v \\
w \\
1
\end{bmatrix}$

then the rotation and the translation can be merged in a single 4 by 4 matrix, called a *pose*:

$\mathbf{x} =
\mathbf{T}\mathbf{u} = \begin{bmatrix}
\mathbf{R} & \mathbf{t} \\
\mathbf{0} & 1
\end{bmatrix}
\mathbf{u}$

Although it may seem like a waste of space in memory, pose representation have lot of advantages in terms of composability, inversion, ...

!!! note
	To further explore the problem of how to represent of the SE(3) group, see [the fantastic technical report of Jose-Luis Blanco](http://ingmec.ual.es/~jlblanco/papers/jlblanco2010geometry3D_techrep.pdf)
"""

# ╔═╡ 5049d925-0604-4275-8293-6224c0ba180e
md"""
A `Pose` can be constructed from the three translations and the three angles `yaw`, `pitch` and `roll` representing the extrinsinc Tait-Bryan angles of active rotation around the $x$, $y$, and $z$ axis respectively.
"""

# ╔═╡ 2ca8372a-d5af-4be4-b580-4b9e63d259d8
p1 = Pose(x=0.1,y=1.0,z=10., yaw=0.01, pitch=0.1, roll=-0.1)

# ╔═╡ c99f9990-29e5-4a57-ad0d-30cebbbb99bc
md"""
In `ToyTracker` local and global coordinates are two different types in order to always do the right transformation.
"""

# ╔═╡ 8fabd78a-b47f-4d46-a7fc-de3ed3b2eaf8
lcoord = LocalCoordinates(1.,2.,3.)

# ╔═╡ c1ebcdbb-540d-4d75-afc4-95981a9def67
gcoord = GlobalCoordinates(4.,5.,6.)

# ╔═╡ f4bb4a14-0a37-40b1-b9bb-d72bbc2d2e21
md"""
Poses are callable and the alway transform global vectors into local vectors and vice versa (applying $\mathbf{T}$ or $\mathbf{T}^{-1}$ accordingly).
"""

# ╔═╡ 804b8853-60cf-486d-ac19-e7e225a31926
p1(lcoord)

# ╔═╡ c0deb85d-ae77-419f-82bd-c1806e87dea3
p1(gcoord)

# ╔═╡ 13fa5e68-184d-4fa4-8c03-b6d5934a90dd
md"""
With a slight abuse of notation, vectors of type `Direction` are defined in order to represent, as the name suggests, directions which they have the properties of not being affected by translation. Their fourth component is then null:

$\tilde{\mathbf{x}}=\begin{bmatrix}
x \\
y \\
z \\
0 \end{bmatrix},\qquad
\tilde{\mathbf{u}}=\begin{bmatrix}
u \\
v \\
w \\
0 \end{bmatrix}$
"""

# ╔═╡ eb56d28b-9368-4c56-b18f-0434a343eb98
ldir = LocalDirection(3.,2.,1.)

# ╔═╡ 2e7cb04f-0628-4b3e-b0a0-7bba57031943
gdir = GlobalDirection(6.,5.,4.)

# ╔═╡ 1a24c8e1-7e8a-4882-8a11-6bda0c002da8
md"""
Poses are callable on directions too, having the same good property of moving from one reference frame to the other:
"""

# ╔═╡ 8524b1f7-e775-4477-b98d-03ba0d40d817
p1(ldir)

# ╔═╡ 68f49886-384c-47f5-a15b-aacf8fb64cb3
p1(gdir)

# ╔═╡ d20495d1-b771-45de-b216-975034043614
md"""
### Sensors
"""

# ╔═╡ b3356a6f-0a8b-42aa-895d-cff5e9789622
md"""
An ideal sensor is a rectangular sensor with rectangular pixels and infinitesimal thickness, having no multiple scattering and no energy loss effect on the particle impinging on the sensor. It has perfect efficiency and the signal is only on the pixel where the particle hit the detector plane.
"""

# ╔═╡ b1e6c6f2-d3fe-4b7c-b2b6-c18c985ee5a3
begin
	# in cm
	pixel = IdealSensor(uwidth=10.0, vwidth=5.0, upitch=0.01, vpitch=0.1)
	strip = IdealSensor(uwidth=10.0, vwidth=5.0, upitch=0.01, vpitch=2.5)
end

# ╔═╡ de96c450-2414-4d61-90ce-06e0156a9719
md"""
A sensor moved into its own position is represented by a `PlacedSensor`:
"""

# ╔═╡ 6d28f43c-7c86-4a42-8a61-32ebc657a43c
ps1 = PlacedSensor(pixel, p1)

# ╔═╡ fba5b692-f9c6-4468-9883-70b5e0a503d6
md"""
Using `Makie` we can even plot a `PlacedSensor` to make sure that it is in the expected place (messing with rotation is easy). We can color the two faces in different colors to have an even better understanding of the spatial relationship.
"""

# ╔═╡ 7cda2618-9081-4b4a-b5f0-af9568484718
begin
	color = two_sides_colors(pixel, :red, :blue)
	mesh(ps1, color=color, alpha=.5)
end

# ╔═╡ a154adc7-fb26-4ee0-8366-54a9dafeb537
md"""
### Particle trajectories
"""

# ╔═╡ e5250b5a-ac45-4208-9521-00bc5fae9939
md"""
In our context, a particle trajectory is a function $f(\tau) : \mathbb{R}^+\to\mathbb{R}^4$ that computes the particle position in the global reference frame as a function of a positive, dimensionless parameter $\tau$:

$f(\tau)=\begin{bmatrix}
x(\tau) \\
y(\tau) \\
z(\tau) \\
1\end{bmatrix}$

The homogeneous coordinates convention comes very handy when it comes to computing the direction of the particle, defined as the Jacobian of $f$ with respect to $\tau$:

$d(\tau)=\begin{bmatrix}
x'(\tau) \\
y'(\tau) \\
z'(\tau) \\
0\end{bmatrix}$

which is a proper direction in the sense that it is not affected by translations.
"""

# ╔═╡ 860ee5c1-5964-46d7-9cca-6126be3334a4
md"""
A `StraightTrack` is, as the name suggests, a straight particle trajectory. Its parameters are a `GlobalCoordinate` $\mathbf{p_0}$ and a `GlobalDirection` $\tilde{\mathbf{d}}$ in such a way that

$f(\tau)=\mathbf{p_0} + \tau \tilde{\mathbf{d}}, \qquad d(\tau)=\tilde{\mathbf{d}}$

If we fix $z_0=0$ and $d_z=1$ we have only four degrees of freedom left.
"""

# ╔═╡ c4dc1e8f-a9bf-44d9-8117-4afcd8f344db
t1 = StraightTrack(0, 0, -0.1, 0.1)

# ╔═╡ a9da4e95-cfd8-4928-8511-1fcb3ba3a52c
md"""
As for the placed sensors case, we can visualize the track:
"""

# ╔═╡ 11139ded-32f7-4528-87c4-2ff6ebe8fd50
lines(t1, 0:1)

# ╔═╡ df84c218-bd59-4c36-a2a8-5b9fcdd479d5
md"""
### Particle interaction with the sensor
"""

# ╔═╡ aa718b7a-89a4-41d2-b1af-ac15c9f0e0ee
md"""
The interaction of a straight track with an ideal sensor is quite simple:
- The intersection of the sensor plane with the track happens for the value of $\tau$ such that the $w$ component of $Tf(\tau)$ is null;
- Given the local coordinates of intersection, the measurement correspond to the center of the closest pixel.

The return type is a `Hit` made of the $(u,v)$ coordinates of the center and their covariance matrix. This is unnecessary for the present situation since the  2d measurement uncertainty is diagonal, but it leaves the door open to more advanced model of detector response!
"""

# ╔═╡ e0ff714d-8a8a-4b81-8fb6-174328e0669f
interaction(t1, ps1)

# ╔═╡ 8ba962ef-d6d3-4fe1-a85c-f5d282182a16
md"""
## Telescope simulation
"""

# ╔═╡ 0e40773c-3c61-45e0-ae63-fae010f02cfb
md"""
Now we are ready to "build" our telescope. First, we define our set of poses:
"""

# ╔═╡ 74d2f9a0-d466-4a63-a990-11b950694036
begin
	xpos = [0., 0.1, 0.]
	ypos = [0.,-0.2, 0.]
	zpos = [10., 20., 30.]
	pxposes = [Pose(x=x, y=y, z=z, yaw=0, pitch=0, roll=0) for (x,y,z) in zip(xpos, ypos, zpos)]
	stposes = [Pose(x=x, y=y, z=z+0.4, yaw=0, pitch=0, roll=0) for (x,y,z) in zip(xpos, ypos, zpos)]
end

# ╔═╡ 1a5098d5-5a20-4ae7-b0af-38ecfc5ff707
md"""
Then our placed sensors:
"""

# ╔═╡ d81c513a-35eb-48e9-a7cd-33de43c6e8ac
begin
	pixels = [PlacedSensor(pixel, p) for p in pxposes]
	strips = [PlacedSensor(strip, p) for p in stposes]
end

# ╔═╡ 408bc1f1-815c-47f2-b9c1-b89f13c9b773
md"""
And finally our telescope! Which is simply a tuple of placed sensors:
"""

# ╔═╡ d614121c-f06c-46c6-9ff7-e142b742c777
telescope = Tuple(Iterators.flatten(zip(pixels, strips)))

# ╔═╡ 7358312b-909f-40bf-9789-95dfd686f634
begin
	fig1 = Figure()
	ax1 = Axis3(fig1[1,1], viewmode=:fit)
	for p in telescope
		mesh!(ax1, p, color=color, alpha=.5)
	end
	fig1
end

# ╔═╡ 9737c598-37a0-4056-af87-e56c5f614c40
md"""
Now we can generate a beam of straight tracks to generate synthetic data: here as example we choose a gaussian beam spot with 3 cm sigma on the $x$ axis and 2 cm sigma in the $y$ axis, with an angular divergence of around 14 mrad.
"""

# ╔═╡ c608d304-6f6d-4bca-bd24-1a44cd383d06
begin
	fig2 = Figure()
	ax2 = Axis3(fig2[1,1], viewmode=:free)
	for _ in 1:30
		t = StraightTrack(3randn(), 2randn(), 1e-2randn(), 1e-2randn())
		lines!(ax2, t, 0:40)
	end
	for p in telescope
		mesh!(ax2, p, color=color, alpha=.5)
	end
	fig2
end

# ╔═╡ Cell order:
# ╟─61d51130-00fa-43af-894c-cf433f7e33fd
# ╠═3d8ac329-b4ef-43eb-be79-53678efaea8d
# ╟─088eafbb-312c-4b7c-a0f1-2e1634175434
# ╟─7c5e5dc6-8e72-4904-9c99-5011cd2b6903
# ╟─d200b5e9-40ea-4b73-9aca-f95a6f9609ce
# ╟─0239c88e-6efb-4b86-aee3-cb5d6aadf5ec
# ╟─13d99be7-e46b-42cc-9cc1-82d17edf6e54
# ╟─5049d925-0604-4275-8293-6224c0ba180e
# ╠═2ca8372a-d5af-4be4-b580-4b9e63d259d8
# ╟─c99f9990-29e5-4a57-ad0d-30cebbbb99bc
# ╠═8fabd78a-b47f-4d46-a7fc-de3ed3b2eaf8
# ╠═c1ebcdbb-540d-4d75-afc4-95981a9def67
# ╟─f4bb4a14-0a37-40b1-b9bb-d72bbc2d2e21
# ╠═804b8853-60cf-486d-ac19-e7e225a31926
# ╠═c0deb85d-ae77-419f-82bd-c1806e87dea3
# ╟─13fa5e68-184d-4fa4-8c03-b6d5934a90dd
# ╠═eb56d28b-9368-4c56-b18f-0434a343eb98
# ╠═2e7cb04f-0628-4b3e-b0a0-7bba57031943
# ╟─1a24c8e1-7e8a-4882-8a11-6bda0c002da8
# ╠═8524b1f7-e775-4477-b98d-03ba0d40d817
# ╠═68f49886-384c-47f5-a15b-aacf8fb64cb3
# ╟─d20495d1-b771-45de-b216-975034043614
# ╟─b3356a6f-0a8b-42aa-895d-cff5e9789622
# ╠═b1e6c6f2-d3fe-4b7c-b2b6-c18c985ee5a3
# ╟─de96c450-2414-4d61-90ce-06e0156a9719
# ╠═6d28f43c-7c86-4a42-8a61-32ebc657a43c
# ╟─fba5b692-f9c6-4468-9883-70b5e0a503d6
# ╠═7cda2618-9081-4b4a-b5f0-af9568484718
# ╟─a154adc7-fb26-4ee0-8366-54a9dafeb537
# ╟─e5250b5a-ac45-4208-9521-00bc5fae9939
# ╟─860ee5c1-5964-46d7-9cca-6126be3334a4
# ╠═c4dc1e8f-a9bf-44d9-8117-4afcd8f344db
# ╟─a9da4e95-cfd8-4928-8511-1fcb3ba3a52c
# ╠═11139ded-32f7-4528-87c4-2ff6ebe8fd50
# ╟─df84c218-bd59-4c36-a2a8-5b9fcdd479d5
# ╟─aa718b7a-89a4-41d2-b1af-ac15c9f0e0ee
# ╠═e0ff714d-8a8a-4b81-8fb6-174328e0669f
# ╟─8ba962ef-d6d3-4fe1-a85c-f5d282182a16
# ╟─0e40773c-3c61-45e0-ae63-fae010f02cfb
# ╠═74d2f9a0-d466-4a63-a990-11b950694036
# ╟─1a5098d5-5a20-4ae7-b0af-38ecfc5ff707
# ╠═d81c513a-35eb-48e9-a7cd-33de43c6e8ac
# ╟─408bc1f1-815c-47f2-b9c1-b89f13c9b773
# ╠═d614121c-f06c-46c6-9ff7-e142b742c777
# ╠═7358312b-909f-40bf-9789-95dfd686f634
# ╟─9737c598-37a0-4056-af87-e56c5f614c40
# ╠═c608d304-6f6d-4bca-bd24-1a44cd383d06
