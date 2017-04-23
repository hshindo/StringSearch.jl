module StringSearch

include("sais.jl")
include("lcp.jl")

export substrings

function substrings{T}(t1::Vector{T}, t2::Vector{T})
    m = length(t1)
    text = copy(t1)
    append!(text, t2)
    println(typeof(text))
    sa = sais(text)
    lcps = lcparray(text, sa)

    substrs = Tuple{3,Int}[]
    for i = 2:length(text)
        k1, k2 = sa[i-1], sa[i]
        (k1 <= m) == (k2 <= m) && continue
        k1, k2 = k1 > k2 ? (k2,k1) : (k1,k2)
        len = min(lcps[i], m-k1+1)
        len > 0 && push!(substrs, (k1,k2,len))
    end
    #sort!(lcps, by=x->x[2], rev=true)
    substrs
end
substrings(t1::String, t2::String) = substrings(collect(t1), collect(t2))

end
