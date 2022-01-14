module WordleSolver
using Random

export load_words, wordle_solver

export wordle_score, read_tuple, wordle_validate

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
    used = [false for _ = 1:five]


    # find letters that match in position
    for i = 1:five
        if guess[i] == code[i]
            result[i] = 2
            used[i] = true
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

"""
    read_tuple
Read in characters from the keyboard and parse them into a 5-tuple of integers.
If the input isn't parsed as a 5-tuple of `Int`s, then throw an error.
Returns the 5-tuple.
"""
function read_tuple()::NTuple{five,Int}
    str = readline()
    parsed = Base.Meta.parse(str)
    result = eval(parsed)
    return result
end

"""
    wordle_validate(guess, history)
See if the word `guess` is consistent with the results we previously seen.
"""
function wordle_validate(guess::String, history::Dict{String,NTuple{five,Int}})::Bool
    if length(history) == 0
        return true
    end

    for code in keys(history)
        if wordle_score(code, guess) != history[code]
            return false
        end
    end

    return true
end


function wordle_solver(words::Vector{String})
    hist = Dict{String,NTuple{five,Int}}()

    bad_message = "\nYour entry is invalid. Please try again."

    for g in words
        if wordle_validate(g, hist)
            result = ""
            while true
                println("\nI guess the word is $g")
                print("Enter the result --> ")
                try
                    result = read_tuple()
                    for x in result 
                        if x>2 || x<0
                            println(bad_message)
                            continue 
                        end
                    end
                    break
                catch
                    println(bad_message)
                end
            end
            if result == Tuple(2 for _ in 1:five)
                steps = length(hist) + 1
                println("\nSuccess in $steps guesses!!")
                return 
            end 
            hist[g] = result
        end
    end
    println("\nI give up. Dumping history.")
    hist_dump(hist)
    return 
end

wordle_solver() = wordle_solver(load_words())


function hist_dump(hist::Dict{String, NTuple{five,Int}})
    for word in sort(collect(keys(hist)))
        reply = hist[word]
        println("$word --> $reply")
    end
end


end # module
