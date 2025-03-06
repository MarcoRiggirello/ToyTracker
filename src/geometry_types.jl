# Marco Riggirello


"""
Vector of homogenous coordinates in the global reference frame.
"""
struct GlobalCoordinates{T} <: FieldVector{4,T}
    x::T
    y::T
    z::T
    unity::T
    function GlobalCoordinates{T}(a, b, c) where {T}
        return new{T}(a, b, c, oneunit(T))
    end
end


GlobalCoordinates(a::T, b::T, c::T) where {T} = GlobalCoordinates{T}(a, b, c)
GlobalCoordinates(a, b, c) = GlobalCoordinates(promote(a, b, c)...)

function GlobalCoordinates(a, b, c, d)
    if d ≉ oneunit(d)
        @warn "Fourth element was not unitary as expected. I'm gonna discard it..."
    end
    return GlobalCoordinates(a, b, c)
end

GlobalCoordinates(a::AbstractVector) = GlobalCoordinates(a...)


"""
Vector of homogenous coordinates in a local reference frame.
"""
struct LocalCoordinates{T} <: FieldVector{4,T}
    u::T
    v::T
    w::T
    unity::T
    function LocalCoordinates{T}(a, b, c) where {T}
        return new{T}(a, b, c, oneunit(T))
    end
end


LocalCoordinates(a::T, b::T, c::T) where {T} = LocalCoordinates{T}(a, b, c)
LocalCoordinates(a, b, c) = LocalCoordinates(promote(a, b, c)...)

function LocalCoordinates(a, b, c, d)
    if d ≉ oneunit(d)
        @warn "Fourth element was not unitary as expected. I'm gonna discard it..."
    end
    return LocalCoordinates(a, b, c)
end

LocalCoordinates(a::AbstractVector) = LocalCoordinates(a...)



"""
Direction vector in a global reference frame.

Direction is different from usual coordinates since it is affected
only by the rotation part, not the traslation one. Hence, its fourth
element is zero and not unitary.
"""
struct GlobalDirection{T} <: FieldVector{4,T}
    x::T
    y::T
    z::T
    μηδεν::T
    function GlobalDirection{T}(a, b, c) where {T}
        return new{T}(a, b, c, zero(T))
    end
end

GlobalDirection(a::T, b::T, c::T) where {T} = GlobalDirection{T}(a, b, c)
GlobalDirection(a, b, c) = GlobalDirection(promote(a, b, c)...)

function GlobalDirection(a, b, c, d)
    if d ≉ zero(d)
        @warn "Fourth element was not null as expected. I'm gonna discard it..."
    end
    return GlobalDirection(a, b, c)
end

GlobalDirection(a::AbstractVector) = GlobalDirection(a...)



"""
Direction vector in a local reference frame.

Direction is different from usual coordinates since it is affected
only by the rotation part, not the traslation one. Hence, its fourth
element is zero and not unitary.
"""
struct LocalDirection{T} <: FieldVector{4,T}
    x::T
    y::T
    z::T
    μηδεν::T
    function LocalDirection{T}(a, b, c) where {T}
        return new{T}(a, b, c, zero(T))
    end
end

LocalDirection(a::T, b::T, c::T) where {T} = LocalDirection{T}(a, b, c)
LocalDirection(a, b, c) = LocalDirection(promote(a, b, c)...)

function LocalDirection(a, b, c, d)
    if d ≉ zero(d)
        @warn "Fourth element was not null as expected. I'm gonna discard it..."
    end
    return LocalDirection(a, b, c)
end

LocalDirection(a::AbstractVector) = LocalDirection(a...)



"""
A pose as defined in "A tutorial on SE(3) transformation parameterizations and on-manifold optimization", J. Blanco, 2010.
"""
struct Pose{T} <: FieldMatrix{4,4,T}
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
                xx xy xz xt
                yx yy yz yt
                zx zy zz zt
                zero(T) zero(T) zero(T) one(T)
            ]...
        )
    end
end


Pose(a::T...) where {T} = Pose{T}(a...)


Pose(a...) = Pose(promote(a...)...)


Pose(a::StaticArray{S,T,2} where {S<:Tuple,T}) = Pose(a...)


"""
The three angles ϕ, χ, ψ are respectively the three Cardan angles called yaw, pitch, roll.
"""
function Pose{T}(x, y, z, ϕ, χ, ψ) where {T<:AbstractFloat}
    s₁, c₁ = sincos(ϕ)
    s₂, c₂ = sincos(χ)
    s₃, c₃ = sincos(ψ)
    return Pose{T}(
        SA[
            c₁*c₂ c₁*s₂*s₃-c₃*s₁ s₁*s₃+c₁*c₃*s₂ x
            c₂*s₁ c₁*c₃+s₁*s₂*s₃ c₃*s₁*s₂-c₁*s₃ y
            -s₂ c₂*s₃ c₂*c₃ z
            zero(T) zero(T) zero(T) one(T)
        ]
    )
end


Pose(x::T, y::T, z::T, ϕ::T, χ::T, ψ::T) where {T} = Pose{T}(x, y, z, ϕ, χ, ψ)


Pose(x, y, z, ϕ, χ, ψ) = Pose(promote(x, y, z, ϕ, χ, ψ)...)


Pose(x::Integer, y::Integer, z::Integer, ϕ::Integer, χ::Integer, ψ::Integer) = Pose{Float64}(x, y, z, ϕ, χ, ψ)
