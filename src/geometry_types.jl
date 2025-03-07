# Marco Riggirello

#############################
# Coordinates and Direction #
#############################

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

###################
# POSE DEFINITION #
###################
# To avoid too long lines and too long columns of arguments,
# the elements of the matrix are arranged in a 3(4) by 4 grid.
# However, since arrays in Julia are _column major_,
# this creates a difference between how elements are ordered
# in the function argument visually TRANSPOSED with respect
# to the actual position in the very matrix. This should not
# be an issue since I expect to construct poses from the
# angles and translations, but I can foresee dramatic silent
# bugs from this choice. Let's be paranoid and add warning
# comments all over the code and let's hope that this and good
# testing prevents alignment apocalypses...

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
    function Pose{T}(
        xx, yx, zx, # CAVE! The "graphical"
        xy, yy, zy, # order of the elements
        xz, yz, zz, # is transposed w.r.t.
        xt, yt, zt  # the true order!!!
    ) where {T}
        return new{T}(
            xx, xy, xz, xt, # See?
            yx, yy, yz, yt, # This is the
            zx, zy, zz, zt, # true ordering!!!
            zero(T), zero(T), zero(T), oneunit(T)
        )
    end
end

# Twelve elements constructors
function Pose(
    xx::T, yx::T, zx::T, # CAVE! The "graphical"
    xy::T, yy::T, zy::T, # order of the elements
    xz::T, yz::T, zz::T, # is transposed w.r.t.
    xt::T, yt::T, zt::T  # the true order!!!
) where {T}
    return Pose{T}(
        xx, yx, zx, # CAVE! The "graphical"
        xy, yy, zy, # order of the elements
        xz, yz, zz, # is transposed w.r.t.
        xt, yt, zt  # the true order!!!
    )
end

function Pose(
    xx, yx, zx, # CAVE! The "graphical"
    xy, yy, zy, # order of the elements
    xz, yz, zz, # is transposed w.r.t.
    xt, yt, zt  # the true order!!!
)
    return Pose(
        promote(
            xx, yx, zx, # CAVE! The "graphical"
            xy, yy, zy, # order of the elements
            xz, yz, zz, # is transposed w.r.t.
            xt, yt, zt  # the true order!!!
        )...
    )
end

# Sixteen elements constructors
function Pose{T}(
    xx, yx, zx, tx, # CAVE! The "graphical"
    xy, yy, zy, ty, # order of the elements
    xz, yz, zz, tz, # is transposed w.r.t.
    xt, yt, zt, tt  # the true order!!!
) where {T}
    if tx ≉ zero(T)
        @warn "tx element was not zero as expected. I'm gonna discard it..."
    elseif ty ≉ zero(T)
        @warn "ty element was not zero as expected. I'm gonna discard it..."
    elseif tz ≉ zero(T)
        @warn "tz element was not zero as expected. I'm gonna discard it..."
    elseif tt ≉ oneunit(T)
        @warn "tt element was not unitary as expected. I'm gonna discard it..."
    end
    return Pose{T}(
        xx, yx, zx, # CAVE! The "graphical"
        xy, yy, zy, # order of the elements
        xz, yz, zz, # is transposed w.r.t.
        xt, yt, zt  # the true order!!!
    )
end

function Pose{T}(
    xx::T, yx::T, zx::T, tx::T, # CAVE! The "graphical"
    xy::T, yy::T, zy::T, ty::T, # order of the elements
    xz::T, yz::T, zz::T, tz::T, # is transposed w.r.t.
    xt::T, yt::T, zt::T, tt::T  # the true order!!!
) where {T}
    return Pose{T}(
        xx, yx, zx, tx, # CAVE! The "graphical"
        xy, yy, zy, ty, # order of the elements
        xz, yz, zz, tz, # is transposed w.r.t.
        xt, yt, zt, tt  # the true order!!!
    )
end

function Pose(
    xx, yx, zx, tx, # CAVE! The "graphical"
    xy, yy, zy, ty, # order of the elements
    xz, yz, zz, tz, # is transposed w.r.t.
    xt, yt, zt, tt  # the true order!!!
)
    return Pose(
        promote(
            xx, yx, zx, tx, # CAVE! The "graphical"
            xy, yy, zy, ty, # order of the elements
            xz, yz, zz, tz, # is transposed w.r.t.
            xt, yt, zt, tt  # the true order!!!
        )...
    )
end

# Matrix constructors
function Pose{T}(a::AbstractMatrix) where {T}
    return Pose{T}(a...)
end

function Pose(a::AbstractMatrix)
    return Pose(a...)
end


# Parametric constructors
"""
The three angles ϕ, χ, ψ are respectively the three Cardan angles called yaw, pitch, roll.
"""
function Pose{T}(x, y, z, ϕ, χ, ψ) where {T<:AbstractFloat}
    s₁, c₁ = sincos(ϕ)
    s₂, c₂ = sincos(χ)
    s₃, c₃ = sincos(ψ)
    # This is the right order
    # c₁*c₂ c₁*s₂*s₃-c₃*s₁ s₁*s₃+c₁*c₃*s₂ x
    # c₂*s₁ c₁*c₃+s₁*s₂*s₃ c₃*s₁*s₂-c₁*s₃ y
    # -s₂ c₂*s₃ c₂*c₃ z
    # zero(T) zero(T) zero(T) one(T)
    xx = c₁ * c₂
    yx = c₂ * s₁
    zx = -s₂
    xy = c₁ * s₂ * s₃ - c₃ * s₁
    yy = c₁ * c₃ + s₁ * s₂ * s₃
    zy = c₂ * s₃
    xz = s₁ * s₃ + c₁ * c₃ * s₂
    yz = c₃ * s₁ * s₂ - c₁ * s₃
    zz = c₂ * c₃
    xt = x
    yt = y
    zt = z
    return Pose{T}(
        xx, yx, zx, # CAVE! The "graphical"
        xy, yy, zy, # order of the elements
        xz, yz, zz, # is transposed w.r.t.
        xt, yt, zt  # the true order!!!
    )
end


Pose(x::T, y::T, z::T, ϕ::T, χ::T, ψ::T) where {T} = Pose{T}(x, y, z, ϕ, χ, ψ)
Pose(x, y, z, ϕ, χ, ψ) = Pose(promote(x, y, z, ϕ, χ, ψ)...)
