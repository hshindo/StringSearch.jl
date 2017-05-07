export diff

function diff{T}(t1::Vector{T}, t2::Vector{T})
    m = length(t1)
    text = copy(t1)
    append!(text, t2)
    sa = sais(text)


    buffer = []
    push!(buffer, (sa,1:length(t1),1:length(t2)))
    while !isempty(buffer)
        sa, r1, r2 = pop!(buffer)
        index, len = lcs(sa)

        filter(sa) do i
            any(r -> start(r) <= i <= last(r), (r1,r2))
        end
        push!(buffer)
    end
end

function lcs(sa::Vector{Int}, text::Vector, m::Int)
    lcps = lcparray(sa, text)
    maxlcp, maxk1, maxk2 = 0
    for i = 2:length(lcps)
        k1, k2 = sa[i-1], sa[i]
        (k1 <= m) == (k2 <= m) && continue
        k1, k2 = k1 > k2 ? (k2,k1) : (k1,k2)
        lcp = min(lcps[i], m-k1+1)
        if lcp > maxlcp
            maxlcp, maxk1, maxk2 = lcp, k1, k2-m
        end
    end
    k1, k2 = sa[maxi], sa[maxi-1]
    k1 > k2
    sa[maxi], sa[maxi-1], lcps[maxi]
end

type CommonSeqs
    indices1::Vector{Int}
    indices2::Vector{Int}
    length::Int
end

function substrings{T}(t1::Vector{T}, t2::Vector{T})
    m = length(t1)
    text = copy(t1)
    append!(text, t2)
    sa = sais(text)
    lcps = lcparray(text, sa)

    prevlcp = 0
    b = 2
    seqs = CommonSeqs[]
    for i = 2:length(sa)
        lcp = lcps[i]
        for k in (sa[i-1],sa[i])
            k <= m && (lcp = min(lcp,m-k+1))
        end
        if lcp != prevlcp || i == length(sa)
            i1 = Int[]
            i2 = Int[]
            for k in b-1:i-1
                sa[k] <= m ? push!(i1,sa[k]) : push!(i2,sa[k]-m)
            end
            !isempty(i1) && !isempty(i2) && push!(seqs,CommonSeqs(i1,i2,prevlcp))
            b = i
        end
        prevlcp = lcp
    end

    # Extract only maximal patterns
    sort!(seqs, by=x->x.length, rev=true)
    check = fill(false, length(text))
    filter(seqs) do seq
        any(i -> check[i], seq.indices1) && return false
        any(i -> check[i+m], seq.indices2) && return false
        for s in seq.indices1
            foreach(i -> check[i] = true, s:s+seq.length-1)
        end
        for s in seq.indices2
            foreach(i -> check[i+m] = true, s:s+seq.length-1)
        end
        return true
    end
end
substrings(t1::String, t2::String) = substrings(collect(t1), collect(t2))
