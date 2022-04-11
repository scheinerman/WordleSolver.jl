export auto_play

"""
    auto_play(answer::String; scorer::Function = min_max_score, verbose::Bool = true)
    auto_play(; scorer::Function = min_max_score, verbose::Bool = true)
    auto_play(a::Int; scorer::Function = min_max_score)
    
Computer solves a Wordle puzzle without user inputs. The number of steps to solve is returned.

* In the first case, `answer` is a five-letter word given by the user. 
* In the second case, the five-letter word is randomly chosen by the computer.
* In the third case, an integer index into `ANS_LIST` is the input, and `verbose` is set to `false`.

The `scorcer` function is one of:
* `min_max_score`
* `entropy_score`
* `equi_score`

The first guess is chosen from the dictionary `FIRST_GUESS` depending on the `scorer` function.
"""
function auto_play(answer::String; scorer::Function = min_max_score, verbose::Bool = true)
    a = ANS_DICT[uppercase(answer)]  # this is the word we want to guess; throws an error if bad word

    stop = code_2_byte((2, 2, 2, 2, 2))
    history = Dict{Int,Byte}()

    g = FIRST_GUESS[scorer]
    if scorer == equi_score
        g = mod1(rand(Int), NG)
    end

    x = fast_wordle_score(g, a)
    history[g] = x
    if verbose
        wordle_print(g, x)
    end

    while x != stop
        possibles = filter_answers(history)
        g = best_guess(possibles, scorer)
        x = fast_wordle_score(g, a)
        if verbose
            wordle_print(g, x)
        end
        history[g] = x
    end
    return length(history)
end

function auto_play(; scorer::Function = min_max_score, verbose::Bool = true)
    a = mod1(rand(Int), NA)
    answer = ANS_LIST[a]
    auto_play(answer, scorer = scorer, verbose = verbose)
end


function auto_play(a::Int; scorer::Function = min_max_score)
    answer = ANS_LIST[a]
    auto_play(answer, scorer = scorer, verbose = false)

end

export score_all


"""
    score_all(scorer::Function = min_max_score)
Use the selected `scorer` function to solve all possible Wordle words 
once each and return a vector containing the number of steps for each 
solution. 
"""
function score_all(scorer::Function = min_max_score)
    result = zeros(Int, NA)
    PM = Progress(NA)
    for a = 1:NA
        result[a] = auto_play(a, scorer = scorer)
        next!(PM)
    end
    return result
end

export all_play

scorer_list = [min_max_score, entropy_score, L2_score, equi_score]

export all_play

"""
    all_play(word::String)
Compare all solving methods to solve for the word.
"""
function all_play(answer::String)
    for s in scorer_list
        println("\nSolving with $s")
        steps = auto_play(answer, scorer=s)
        println("Solution in $steps steps")
    end
end