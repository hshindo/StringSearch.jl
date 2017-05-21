export align

type State
    sa
    text
    range1
    range2
end

function State(st::State, range1, range2)
    sepindex = length(st.range1) + 1
    text = st.text[range1]
    push!(text, st.text[sepindex])
    append!(text, st.text[range2])
    sa = sais(text)
    State(sa, text, range1+start(st.range1), range2+start(st.range2))
end

function align(t1::Vector{Int}, t2::Vector{Int})
    isvalid(r::Range) = !isempty(r) && start(r) > 0
    states = [(1:length(t1),1:length(t2))]
    done = Tuple{Int,Int}[]
    while !isempty(states)
        r1, r2 = pop!(states)
        lcs1, lcs2 = getlcs(t1[r1], t2[r2])
        isvalid(lcs1) || continue
        lcs1 += (start(r1)-1)
        lcs2 += (start(r2)-1)
        isvalid(lcs1) && isvalid(lcs2) && append!(done, zip(lcs1,lcs2))

        lefts = start(r1):start(lcs1)-1, start(r2):start(lcs2)-1
        rights = last(lcs1)+1:last(r1), last(lcs2)+1:last(r2)
        all(isvalid, lefts) && push!(states, lefts)
        all(isvalid, rights) && push!(states, rights)
    end
    sort!(done)
    done
end
function align(s1::String, s2::String)
    t1 = Int[Int(s1[i]) for i=1:length(s1)]
    t2 = Int[Int(s2[i]) for i=1:length(s2)]
    align(t1, t2)
end

function getlcs(t1::Vector{Int}, t2::Vector{Int}, minlen=1)
    m = length(t1)
    text = copy(t1)
    append!(text, t2)
    sa = sais(text)
    lcps = lcparray(sa, text)

    maxk1, maxk2, maxlcp = 0, 0, 0
    for i = 2:length(lcps)
        k1, k2 = sa[i-1], sa[i]
        (k1 <= m) == (k2 <= m) && continue
        k1, k2 = k1 > k2 ? (k2,k1) : (k1,k2)
        lcp = min(lcps[i], m-k1+1)
        if lcp > maxlcp
            maxk1, maxk2, maxlcp = k1, k2-m, lcp
        end
    end
    r = maxk1:maxk1+maxlcp-1, maxk2:maxk2+maxlcp-1
    maxlcp >= minlen ? r : (0:0,0:0)
end
