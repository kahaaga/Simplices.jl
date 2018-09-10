"""
    simplicial_subdivision(k, E)

Generate generic rules for generating vertices when splitting an E-dimensional
simplex with a size reducing factor of k.

Note: Subsimplices containing any of the original vertices is not considered.

This function comes in two versions. Both versions returns information about
all the subsimplices of the splitted original simplex. They differ in what
information they return about the vertices furnishing these simplices.

The SimplicialSubdivisionMultiple function returns an array of vertices that
containONLY THE NEW VERTICES. This is to prevent duplication when considering
triangulations, in which simplices might share vertices.

SimplicialSubdivisionSingle(k, E) returns an array of all the vertices
furnishing the subidivded simplex, including the vertices of the original
simplex. Use this function when you want to split a single simplex.

SimplexSplittingOutput the decomposition part of a SimplexSplitting output.
This is a (k^E * (E+1) x k) array of integers. (so, ignore the orientations
	for now)
"""
function simplicial_subdivision(k::Int, E::Int)

    # Get simplex splitting rules, ignore orientations for now.
    splits::Array{Int, 2} = simplex_split(k, E, orientations = false)

    # Retrieve integer labels from the tensor decomposition. This is a a
    #  way of uniquely identifying the rows of the 'splits' array. Each integer
    # corresponds to a row in the splits array (but are not necessarily in order).
    integer_labels::Vector{Int} = (splits .- 1) * ((E+1) .^ collect(0:(k-1)))

    # Find the unique labels and sort them
    uniquelabels = sort(unique(integer_labels))

    # How many unique rows are there?
    n_rows = size(uniquelabels, 1)

    J = indexin(integer_labels, uniquelabels)

    # IndicesOfUnqiueIntegersinOriginal
    I = Vector{Int}(undef, length(uniquelabels))
    for i = 1:length(uniquelabels)
        I[i] = something(findfirst(isequal(uniquelabels[i]), integer_labels), 0)
    end
    V::Array{Int, 2} = repeat(uniquelabels, 1, E + 1)

    tmp = repeat((((E+1)^k - 1) ./ E) * transpose(collect(0:E)), n_rows, 1)

    tmp = heaviside0(-abs.(V - tmp)) .* repeat(collect(1:n_rows), 1, E + 1)
    tmp = tmp[findall(tmp)]

    aux = round.(Int, tmp)
    Caux = round.(Int, complementary(tmp, n_rows))
    Ipp = [aux; Caux]

    Ip = zeros(Int, size(I))

    # for any i\in Ipp, Ip(i) is the number j\in {1,...,size(Ipp,1)} such that
    # Ipp(j)=i
    Ip[Ipp] = transpose(collect(1:size(I, 1)))

    # Indices of the non-repeated vertices that are not part of the original
    # simplex. These are the truly new vertices generated by the splitting.
    new_vertices = splits[I, :][Caux, :]

    # Subarrays of dimension E+1 x 1 vertically concatenated. Each subarray
    # contains the indices in the rows of NewVert corresponding to the vertices
    # furnishing the corresponding simplex (analogous to the output of
    # SimplexSplitting, check notes).
    subtriangulation_inds = Ip[J]

    subtriangulation_inds = copy(transpose(reshape(subtriangulation_inds, E + 1, k^E)))

    return new_vertices, subtriangulation_inds
end
