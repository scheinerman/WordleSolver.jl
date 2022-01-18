# Solve NY Times spelling bee puzzles

function load_all_words(file_name::String = "/usr/share/dict/words")::Set{String}
    F = open(file_name)
    wlist = readlines(F)

    S = Set{String}()

    for w in wlist
        if length(w) < 4 || any(isuppercase(c) for c in w)
            continue
        end
        push!(S, uppercase(w))
    end

    return S
end

function bee_filter(word::String, middle::Char, surround::String)::Bool
    if middle ∉ word 
        return false 
    end
    valids = surround * middle 
    return all(c ∈ valids for c ∈ word)
end


"""
    bee_solve('a', "bcdefg")
Find all words with 4 or more letters that must use `a`
and any of the letters in "bcdefg".
"""
function bee_solver(middle::Char, surround::String)::Set{String}
    wlist = load_all_words()
    middle = uppercase(middle)
    surround = uppercase(surround)

    Set(w for w ∈ wlist if bee_filter(w, middle, surround))
end

function bee_solver(middle::String, surround::String)::Set{String}
    if length(middle) != 1
        error("First argument should be a single character")
    end
    bee_solver(middle[1], surround)
end