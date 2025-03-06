# Marco Riggirello



for name in (:GlobalCoordinates, :LocalCoordinates, :GlobalDirection, :LocalDirection)
    string_name = String(name)
    islocal = contains(string_name, "Local")
    isdirection = contains(string_name, "Direction")

    # Determine field names based on the type name
    fields = islocal ? (:u, :v, :w, :unity) : (:x, :y, :z, :μηδεν)

    # Determine the unity expression based on the type name
    homogeneous_term = isdirection ? :(zero(T)) : :(oneunit(T))

    # Construct the docstring dynamically
    docstr = """
    Vector of homogenous coordinates in the $islocal ? "local" : "global") reference frame.
    """
    if isdirection
        docstr *= """
        Direction is different from usual coordinates since it is affected
        only by the rotation part, not the translation one. Hence, its fourth
        element is zero and not unitary.
        """
    end

    # Define the type and constructors
    @eval begin
        @doc $docstr
        struct $(name){T} <: FieldVector{4,T}
            $(fields[1])::T
            $(fields[2])::T
            $(fields[3])::T
            $(fields[4])::T
            function $(name){T}(a, b, c) where {T}
                return new{T}(a, b, c, $homogeneous_term)
            end
        end

        # Three-element constructors
        $(name)(a::T, b::T, c::T) where {T} = $(name){T}(a, b, c)
        $(name)(a, b, c) = $(name)(promote(a, b, c)...)

        # Four-element constructors
        function $(name){T}(a, b, c, d) where {T}
            if d ≉ $homogeneous_term
                @warn "Fourth element was not $($(isdirection) ? "zero" : "unitary") as expected. I'm gonna discard it..."
            end
            return $(name){T}(a, b, c)
        end
        $(name)(a::T, b::T, c::T, d::T) where {T} = $(name){T}(a, b, c, d)
        $(name)(a, b, c, d) = $(name)(promote(a, b, c, d)...)

        # Vector constructors
        $(name){T}(a::AbstractVector) where {T} = $(name){T}(a...)
        $(name)(a::AbstractVector) = $(name)(a...)
    end
end


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
    function Pose{T}(xx, yx, zx, xy, yy, zy, xz, yz, zz, xt, yt, zt) where {T}
        return new{T}(
            xx, xy, xz, xt,
            yx, yy, yz, yt,
            zx, zy, zz, zt,
            zero(T), zero(T), zero(T), oneunit(T)
        )
    end
end
#    function Pose{T}(xx, yx, zx, tx, xy, yy, zy, ty, xz, yz, zz, tz, xt, yt, zt, tt) where {T<:AbstractFloat}

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
