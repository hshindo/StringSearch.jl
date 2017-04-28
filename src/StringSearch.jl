module StringSearch

include("sais.jl")
include("lcp.jl")

export substrings

function substrings{T}(t1::Vector{T}, t2::Vector{T})
    m = length(t1)
    text = copy(t1)
    append!(text, t2)
    sa = sais(text)
    lcps = lcparray(text, sa)

    substrs = Tuple{Int,Int,Int}[]
    for i = 2:length(text)
        k1, k2 = sa[i-1], sa[i]
        (k1 <= m) == (k2 <= m) && continue
        k1, k2 = k1 > k2 ? (k2,k1) : (k1,k2)
        len = min(lcps[i], m-k1+1)
        len > 0 && push!(substrs, (k1,k2-m,len))
    end
    sort!(substrs, by=x->x[3], rev=true)

    checks = fill(false, m)
    data = []
    for (k1,k2,len) in substrs
        checks[k1] && continue
        for i = k1:k1+len-1
            checks[i] = true
        end
        push!(data, (k1,k2,len))
    end
    data
end
substrings(t1::String, t2::String) = substrings(collect(t1), collect(t2))

export longestsubstring
function longestsubstring{T}(t1::Vector{T}, t2::Vector{T})
    m = length(t1)
    text = copy(t1)
    append!(text, t2)
    sa = sais(text)
    lcps = lcparray(text, sa)
    r1, r2 = 0:0, 0:0
    for i = 2:length(text)
        k1, k2 = sa[i-1], sa[i]
        (k1 <= m) == (k2 <= m) && continue
        k1, k2 = k1 > k2 ? (k2,k1) : (k1,k2)
        len = min(lcps[i], m-k1+1)
        if length(r1) < len
            r1 = k1:k1+len-1
            r2 = (k2-m):(k2-m)+len-1
        end
    end
    r1, r2
end

end
