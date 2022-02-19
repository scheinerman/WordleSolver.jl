module WordleSolver
using Random, ProgressMeter, Counters, Random

export hist_check, wordle_solver, wordle_play, wordle_score

export fast_wordle_score

const five = 5



"""
    wordle_score(guess, answer)
Given two five letter words, return a five-tuple with the following meanings:
* `0` means that letter in `guess` does not appear in `answer`.
* `1` means that letter in `guess` appears in `answer`, but in another position.
* `2` means that latter in `guess` appears in `answer` in that position. 

This assumes that `guess` and `answer` are valid five-letter words.
"""
function wordle_score(guess::String, code::String)::NTuple{five,Int}
    result = zeros(Int, five)
    used = zeros(Bool, five)


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

include("startup.jl")


function fast_wordle_score(guess::Int, answer::Int)::Byte
    return SCORE_MATRIX[guess, answer]
end

include("evaluation.jl")

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

    for t in result
        if t < 0 || t > 2
            error("Invalid tuple $result")
        end
    end

    return result
end



"""
    wordle_solver(scorer = min_max_score)
The computer guesses five-letter words and the human scores them. 
Scores are entered as a list of five comma-separated numbers with 
* 0 letter is not in the word
* 1 letter is in the word but in the wrong position
* 2 letter is in the word and in the right position

The optional parameter `scorer` is the name of a scoring function. 
Choices are:
    * `min_max_score` --- default
    * `entropy_score`
    * `equi_score`
"""
function wordle_solver(scorer::Function = min_max_score)
    history = Dict{Int,Byte}()
    stop = code_2_byte((2, 2, 2, 2, 2))

    bad_message = "\nYour entry is invalid. Please try again."

    first_guess::Bool = true

    while true
        alist = filter_answers(history)
        if length(alist) == 0    # something wrong; no possible answer
            println("I give up")
            print("What was your word? ")
            w = readline()
            w = uppercase(w)
            try
                x = ANS_DICT[w]
            catch
                println("$w is not a valid word")
                return
            end
            history_check(history, w)
            return
        end

        
        shuffle!(alist)
        g = 1

        if first_guess
            g = FIRST_GUESS[scorer]
            first_guess = false
        else
            g = best_guess(alist, scorer)
        end
        guess = GUESS_LIST[g]

        # get user input
        result = (0, 0, 0, 0, 0)
        while true
            println("\nI guess the word is $guess")
            print("Enter the result --> ")
            try
                result = read_tuple()
            catch
                println(bad_message)
                continue
            end
            break
        end
        x = code_2_byte(result)

        history[g] = code_2_byte(result)
        if x == stop
            steps = length(history)
            println("\nSuccess in $steps guesses!!")
            return
        end
    end
end

"""
    history_check(history,answer::String)
Check the user inputs saved in the dictionary `d` with the code word `code`.   
"""
function history_check(history::Dict{Int,Byte}, answer::String)
    answer = uppercase(answer)
    a = ANS_DICT[answer]  # code for answer  
    for g in keys(history)
        x = fast_wordle_score(g, a)
        if x != history[g]
            guess = GUESS_LIST[g]
            println("\bWhen I guessed $guess you entered $(byte_2_code(history[g]))")
            println("     but you should have entered $(byte_2_code(x))")
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
    idx = mod1(rand(Int), NA)
    code = ANS_LIST[idx]
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

include("solve_tools.jl")


@info "Compilation completed"

end # module
