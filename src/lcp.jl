"""
    Kasai's algorithm for linear-time construction of LCP array from Suffix Array
"""
function lcparray{T}(text::Vector{T}, sa::Vector{Int})
    n = length(text)
    lcps = similar(sa)
    rank = similar(sa)
    for i = 1:n
        rank[sa[i]] = i
    end

    lcp = 0
    for i = 1:n
        rank[i] > 1 || continue
        j = sa[rank[i]-1]
        while i+lcp <= n && j+lcp <= n && text[i+lcp] == text[j+lcp]
            lcp += 1
        end
        lcps[rank[i]] = lcp
        lcp > 0 && (lcp -= 1)
    end
    lcps[1] = 0
    lcps
end
