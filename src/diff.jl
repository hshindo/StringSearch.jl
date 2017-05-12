export diff

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

function diff{T<:Integer}(t1::Vector{T}, t2::Vector{T})
    maxv = max(maximum(t1), maximum(t2))
    text = copy(t1)
    push!(text, maxv+T(1))
    append!(text, t2)
    sepindex = length(t1) + 1
    sa = sais(text)

    states = State[State(sa,text,1:length(t1),1:length(t2))]
    done = []
    while !isempty(states)
        st = pop!(states)
        r1, r2 = getlcs(st.sa, st.text, length(st.range1)+1)
        push!(done, (r1+start(st.range1)-1,r2+start(st.range2)-1))
        lefts = 1:start(r1)-1, 1:last(r2)-1
        rights = last(r1)+1:last(r1), last(r2)+1:last(r2)
        any(isempty, lefts) || push!(states, State(st,lefts...))
        any(isempty, rights) || push!(states, State(st,rights...))
    end
    done
end
function diff(s1::String, s2::String)
    t1 = Array{Int}(length(s1))
    for i = 1:length(t1)
        t1[i] = Int(s1[i])
    end
    t2 = Array{Int}(length(s2))
    for i = 1:length(t2)
        t2[i] = Int(s2[i])
    end
    diff(t1, t2)
end

function getlcs(sa::Vector{Int}, text::Vector, sepindex::Int)
    lcps = lcparray(sa, text)
    maxk1, maxk2, maxlcp = 0, 0, 0
    for i = 2:length(lcps)
        k1, k2 = sa[i-1], sa[i]
        (k1 < sepindex) == (k2 < sepindex) && continue
        k1, k2 = k1 > k2 ? (k2,k1) : (k1,k2)
        if lcps[i] > maxlcp
            maxk1, maxk2, maxlcp = k1, k2-sepindex, lcps[i]
        end
    end
    maxk1:maxk1+maxlcp-1, maxk2:maxk2+maxlcp-1
end
