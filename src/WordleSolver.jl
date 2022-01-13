module WordleSolver
using Random

export load_words, wordle_score

const five = 5


"""
    load_words(file_name="/usr/share/dict/words")
Read in all (lowercase) five letter words from a file and return them 
as a shuffled list (in uppercase).
"""
function load_words(file_name::String = "/usr/share/dict/words")::Vector{String}
    F = open(file_name)
    words = readlines(F)

    S = Set{String}()

    for w in words
        if length(w) != five
            continue
        end
        if any(isuppercase(c) for c in w)
            continue
        end
        push!(S, uppercase(w))
    end

    wlist = collect(S)
    wlist = wlist[randperm(length(wlist))]
    return wlist
end

"""
    wordle_score(guess, code)
Given two five letter words, return a five-tuple with the following meanings:
* `0` means that letter in `guess` does not appear in `code`.
* `1` means that letter in `guess` appears in `code`, but in another position.
* `2` means that latter in `guess` appears in `code` in that position. 
"""
function wordle_score(guess::String, code::String)::NTuple{five,Int}
    result = [0 for _ = 1:five]
    used = [false for _ = 1:five ]


    # find letters that match in position
    for i = 1:five
        if guess[i] == code[i]
            result[i] = 2
            used[i]= true
        end
    end

    # find letters that are correct, but in wrong position
    for i = 1:five
        for j = 1:five
            if i == j
                continue
            end
            if guess[i] == code[j] && result[i] == 0 && !used[j]
                result[i] = 1
                used[j] = true
            end
        end
    end


    return Tuple(result)
end


end # module
