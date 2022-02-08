module WordleSolver
using Random, ProgressMeter

export hist_check, wordle_solver, wordle_play, wordle_score

include("guesses.jl")
include("answers.jl")
const five = 5


ANS_LIST = make_answers() # place to hold list of words so we only load it once
ANS_SET = Set(ANS_LIST)

GUESS_SET = Set(make_guesses()) ∪ ANS_SET 
GUESS_LIST = sort(collect(GUESS_SET))



"""
    wordle_score(guess, answer)
Given two five letter words, return a five-tuple with the following meanings:
* `0` means that letter in `guess` does not appear in `answer`.
* `1` means that letter in `guess` appears in `answer`, but in another position.
* `2` means that latter in `guess` appears in `answer` in that position. 

This assumes that `guess` and `answer` are valid five-letter words.
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

include("pre_compute_tools.jl")

println("Precomputing for a minute")
SCORE_MATRIX = all_pairs_compute()


function fast_wordle_score(guess::String, answer::String)::NTuple{five,Int}
    return byte_2_code(SCORE_MATRIX[guess,answer])
    # try
    #     b = SCORE_TABLE[guess,answer]
    # catch
    #     # if guess ∉ GUESS_SET
    #     #     println("$guess is not a valid guess word")
    #     # end
    #     # if answer ∉ ANS_LIST
    #     #     println("$answer is not a valid hidden word")
    #     # end
    #     error("Bad word pair ($guess,$answer)")
    # end
    # return byte_2_code(b)
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
function wordle_solver()
    hist = Dict{String,NTuple{five,Int}}()
    nw = length(ANS_LIST)
    words = ANS_LIST[randperm(nw)]

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

        wordle_print(w, result)

        println("Score = $result")
        if w == code
            break
        end
    end
    println("\nSolved in $count steps")
    return
end

function wordle_play()
    ww = ANS_LIST
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
