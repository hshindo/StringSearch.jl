export align

struct State
    i1::Int
    j1::Int
    i2::Int
    j2::Int
    isfirst::Bool
end

isvalid(s::State) = s.i1 > 0 && s.i1 <= s.j1 && s.i2 > 0 && s.i2 <= s.j2

function match(t1::Vector{Int}, t2::Vector{Int})
    states = [State(1,length(t1),1,length(t2),true)]
    aligns = Tuple[]
    while !isempty(states)
        st = pop!(states)
        newst = getlcs(t1[st.i1:st.j1], t2[st.i2:st.j2], st.isfirst)
        isvalid(newst) || continue

        newst = (newst[1]+st.i1-1, newst.j1+st.i1-1, newst.i2+st.i2-1, newst.j2+st.i2-1)
        isvalid(newst) || continue
        push!(aligns, newst)

        left = State(st.i1, newst.i1-1, st.i2, newst.i2-1, false)
        right = State(newst.j1+1, st.j1, newst.j2+1, st.j2, true)
        isvalid(left) && push!(states, left)
        isvalid(right) && push!(states, right)
    end

    array = zeros(Int, length(t1))
    for a in aligns
        for i = 0:a.j1-a.i1
            array[a.i1+i] = a.i2 + i
        end
    end
    array
end

function align(t1::Vector{Int}, t2::Vector{Int})
    isvalid(st::NTuple{4,Int}) = st[1] > 0 && st[1] <= st[2] && st[3] > 0 && st[3] <= st[4]
    states = [((1,length(t1),1,length(t2)),true)]
    aligns = NTuple{4,Int}[]
    while !isempty(states)
        st,isfirst = pop!(states)
        newst = getlcs(t1[st[1]:st[2]], t2[st[3]:st[4]], isfirst)
        isvalid(newst) || continue

        newst = (newst[1]+st[1]-1, newst[2]+st[1]-1, newst[3]+st[3]-1, newst[4]+st[3]-1)
        isvalid(newst) || continue
        push!(aligns, newst)

        left = st[1], newst[1]-1, st[3], newst[3]-1
        right = newst[2]+1, st[2], newst[4]+1, st[4]
        isvalid(left) && push!(states, (left,false))
        isvalid(right) && push!(states, (right,true))
    end

    array = zeros(Int, length(t1))
    #dict = Dict{Int,Int}()
    for a in aligns
        for i = 0:a[2]-a[1]
            array[a[1]+i] = a[3] + i
            #dict[a[1]+i] = a[3]+i
        end
    end
    array
    #dict
end

function align(s1::String, s2::String)
    t1 = Int[Int(s1[i]) for i=1:length(s1)]
    t2 = Int[Int(s2[i]) for i=1:length(s2)]
    align(t1, t2)
end

function getlcs(t1::Vector{Int}, t2::Vector{Int}, isfirst::Bool, minlen=1)
    m = length(t1)
    text = copy(t1)
    append!(text, t2)
    sa = sais(text)
    lcps = lcparray(sa, text)

    maxinds, maxlcp = Int[], 0
    for i = 2:length(lcps)
        k1, k2 = sa[i-1], sa[i]
        (k1 <= m) == (k2 <= m) && continue
        lcp = min(lcps[i], m-min(k1,k2)+1)
        if lcp >= maxlcp
            lcp > maxlcp && (maxinds = Int[])
            push!(maxinds, i)
            maxlcp = lcp
        end
    end

    maxk1, maxk2 = 0, 0
    for i in maxinds
        k1, k2 = sa[i-1], sa[i]
        lcp = min(lcps[i], m-min(k1,k2)+1)
        for j = i-1:-1:2
            (sa[j-1] <= m) == (sa[i-1] <= m) || break
            lcps[j] < maxlcp && break
            if isfirst
                sa[j-1] < k1 && (k1 = sa[j-1])
            else
                sa[j-1] > k1 && (k1 = sa[j-1])
            end
        end
        for j = i+1:length(lcps)
            (sa[j] <= m) == (sa[i] <= m) || break
            lcps[j] < maxlcp && break
            if isfirst
                sa[j] < k2 && (k2 = sa[j])
            else
                sa[j] > k2 && (k2 = sa[j])
            end
        end
        k1, k2 = k1 > k2 ? (k2,k1) : (k1,k2)
        k2 -= m
        if isfirst
            if maxk1 == 0 || k1 < maxk1
                maxk1,maxk2 = k1,k2
            end
        else
            if maxk1 == 0 || k1 > maxk1
                maxk1,maxk2 = k1,k2
            end
        end
    end
    maxlcp >= minlen ? (maxk1,maxk1+maxlcp-1,maxk2,maxk2+maxlcp-1) : (0,0,0,0)
end

function getlcs2(t1::Vector{Int}, t2::Vector{Int}, isfirst::Bool, minlen=1)
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
        cond = isfirst ? lcp > maxlcp : lcp >= maxlcp
        cond || continue

        if cond
            maxk1, maxk2, maxlcp = k1, k2-m, lcp
        end
    end
    maxlcp >= minlen ? (maxk1,maxk1+maxlcp-1,maxk2,maxk2+maxlcp-1) : (0,0,0,0)
end
