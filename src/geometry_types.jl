# Marco Riggirello

# Inspired by the coding style of Rotations.jl
for frame in [:Local, :Global]
    FrameVec = Symbol(frame, :Vector)
    x = frame == :Global ? :x : :u 
    y = frame == :Global ? :y : :v 
    z = frame == :Global ? :z : :w 
    @eval begin
        struct $FrameVec{T} <: FieldVector{4,T}
            $x::T
            $y::T
            $z::T
            unity::T
            function $FrameVec{T}(a, b, c, d) where {T}
                if !(d ≈ 1)
                    @warn "The 4th element of the input vector is not close to 1 as expected for a $FrameVec. That element will be discarded."
                end
                return new{T}(a, b, c, one(T))
            end
        end

        $FrameVec(a::T, b::T, c::T, d::T) where {T} = $FrameVec{T}(a, b, c, d)
        $FrameVec(a, b, c, d) = $FrameVec(promote(a, b, c, d)...)

        $FrameVec{T}(a, b, c) where {T} = $FrameVec{T}(a, b, c, one(T))
        $FrameVec(a::T, b::T, c::T) where {T} = $FrameVec{T}(a, b, c, one(T))

        $FrameVec(a, b, c) = $FrameVec(promote(a, b, c)...)
        $FrameVec(b::AbstractVector) = $FrameVec(b...)

    end
end


"""
A pose as defined in "A tutorial on SE(3) transformation parameterizations and on-manifold optimization", J. Blanco, 2010.
"""
struct Pose{T} <: FieldMatrix{4, 4, T}
    rotxx::T
    rotyx::T
    rotzx::T
    zerox::T
    rotxy::T
    rotyy::T
    rotzy::T
    zeroy::T
    rotxz::T
    rotyz::T
    rotzz::T
    zeroz::T
    trasx::T
    trasy::T
    trasz::T
    unity::T
    function Pose{T}(xx, yx, zx, tx, xy, yy, zy, ty, xz, yz, zz, tz, xt, yt, zt, tt) where {T<:AbstractFloat}
        if !(tx ≈ 0) || !(ty ≈ 0) || !(tz ≈ 0) || !(tt ≈ 1)
            @warn "Some of the elements of the last row are not as expected, they will be discarded."
        end
        return new{T}(
            SA[
                xx      xy      xz          xt
                yx      yy      yz          yt
                zx      zy      zz          zt
                zero(T) zero(T) zero(T) one(T)
            ]...
        )
    end
end


Pose(a::T...) where {T} = Pose{T}(a...)


Pose(a...) = Pose(promote(a...)...)


Pose(a::AbstractMatrix) = Pose(a...)


"""
The three angles ϕ, χ, ψ are respectively the three Cardan angles called yaw, pitch, roll.
"""
function Pose{T}(x, y, z, ϕ, χ, ψ) where {T<:AbstractFloat}
    s₁, c₁ = sincos(ϕ)
    s₂, c₂ = sincos(χ)
    s₃, c₃ = sincos(ψ)
    return Pose{T}(
        SA[
            c₁*c₂    c₁*s₂*s₃-c₃*s₁  s₁*s₃+c₁*c₃*s₂      x
            c₂*s₁    c₁*c₃+s₁*s₂*s₃  c₃*s₁*s₂-c₁*s₃      y
            -s₂      c₂*s₃           c₂*c₃               z
            zero(T)  zero(T)         zero(T)        one(T)
        ]
    )
end


Pose(x::T, y::T, z::T, ϕ::T, χ::T, ψ::T) where {T} = Pose{T}(x, y, z, ϕ, χ, ψ)


Pose(x, y, z, ϕ, χ, ψ) = Pose(promote(x, y, z, ϕ, χ, ψ)...)


Pose(x::Integer, y::Integer, z::Integer, ϕ::Integer, χ::Integer, ψ::Integer) = Pose{Float64}(x, y, z, ϕ, χ, ψ)
