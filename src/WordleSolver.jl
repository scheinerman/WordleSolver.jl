module WordleSolver
using Random

export hist_check, wordle_solver, wordle_play, load_words

const five = 5

stanford_source = homedir() * "/.julia/dev/WordleSolver/src/stanford-words.txt"
unix_source = "/usr/share/dict/words"
wordle_answers = homedir() * "/.julia/dev/WordleSolver/src/wordle-answers.txt"

WORD_LIST = Vector{String}()  # place to hold list of words so we only load it once

"""
    validate_word(word::String)
Filter for reading dictionary from disk. Make sure words are 
five letters long, standard character set, and all lower case.
"""
function validate_word(word::String)::Bool 
    if length(word) != five 
        return false
    end
    if any(isuppercase(c) for c in word)
        return false 
    end
    if any( c<'a' || c>'z' for c in word)
        return false
    end
    return true
end


"""
    load_words(file_name)
Read in all (lowercase) five letter words from a file and return them 
as a shuffled list (in uppercase).
"""
function load_words(file_name::String = wordle_answers)::Vector{String}
    if length(WORD_LIST) > 0
        return WORD_LIST 
    end

    F = open(file_name)
    wlist = readlines(F)

    # S = Set{String}()

    for w in wlist
        if validate_word(w)
            push!(WORD_LIST, uppercase(w))
        end
    end

    return WORD_LIST
    
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

"""
    wordle_solver
The computer guesses five-letter words and the human scores them. 
Scores are entered as a list of five comma-separated numbers with 
* 0 letter is not in the word
* 1 letter is in the word but in the wrong position
* 2 letter is in the word and in the right position
"""
function wordle_solver(words::Vector{String})
    hist = Dict{String,NTuple{five,Int}}()
    nw = length(words)
    words = words[randperm(nw)]

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
                        if x > 2 || x < 0
                            println(bad_message)
                            continue
                        end
                    end
                    break
                catch
                    println(bad_message)
                end
            end
            if result == Tuple(2 for _ = 1:five)
                steps = length(hist) + 1
                println("\nSuccess in $steps guesses!!")
                return
            end
            hist[g] = result
        end
    end
    println("\nI give up.")
    return hist
end

wordle_solver() = wordle_solver(load_words())

"""
    hist_check(d,code)
Check the user inputs saved in the dictionary `d` with the code word `code`.   
"""
function hist_check(hist::Dict{String,NTuple{five,Int}}, code::String)
    code = uppercase(code)
    for word in sort(collect(keys(hist)))
        reply = hist[word]
        result = wordle_score(word, code)
        if reply != result
            println("For my guess $word you said $reply but it should have been $result")
        end
    end
end


"""
    read_word
Read a word from the keyboard. Return the pair `(w,valid)`
where `w` is the uppercase version of the input and `valid`
is `true` if `w` is a five-letter string of characters from 
`A` to `Z`. We don't check if `w` is in a dictionary.
"""
function read_word()::Tuple{String,Bool}
    w = readline()
    valid = true
    w = uppercase(w)

    if w == "?"
        return w, true     # special case to escape
    end

    if length(w) != five
        valid = false
    end
    for c in w
        if c < 'A' || c > 'Z'
            valid = false
        end
    end
    return w, valid
end


"""
    wordle_play
The human tries to guess the secret word.
"""
function wordle_play(code::String)
    code = uppercase(code)
    count = 0
    while true
        count += 1
        w = "ABCDE"
        while true
            print("\nEnter your guess: ")
            w, valid = read_word()
            if valid
                break
            end
            println("Your input $w is not a valid $five-letter word. Please try again.")
        end

        if w == "?"
            println("The code word is $code")
            return
        end

        result = wordle_score(w, code)

        wordle_print(w,result)

        println("Score = $result")
        if w == code
            break
        end
    end
    println("\nSolved in $count steps")
    return
end

function wordle_play()
    ww = load_words()
    nw = length(ww)
    idx = mod1(rand(Int), nw)
    code = ww[idx]
    wordle_play(code)
end


function present_score(word::String, score::NTuple{five,Int})
    for c in word
        print("$c ")
    end
    println()

    symbols = "-+*"
    for t in score
        print(symbols[t+1], " ")
    end
    println()
end
include("wordle_print.jl")

include("auto_play.jl")


end # module
