export record!, new_history, print_history, guess


"""
    record!(h, word, code)
Record the outcome of guessing `word` in the history object `h`. Here `code`
is a five-tuple with the following meanings:
* `0` means this letter is not in the word (gray)
* `1` means this letter is in the word but in the wrong position (yellow)
* `2` means this letter is correct and in the correct position (green)
Colors are as shown in the online Wordle game.

The argument `h` is initialized like this: `h = new_history()`.
"""
function record!(history::Dict{Int,Byte}, word::String, code::NTuple{five,Int})
    w = GUESS_DICT[uppercase(word)]
    c = code_2_byte(code)
    history[w] = c
    guess(history)
end

"""
    new_history()
Start a new solving session by creating a history object. Optional argument is a 
scoring function (`min_max_score` is the default).
"""
function new_history(scorer::Function = min_max_score)
    h = Dict{Int,Byte}()
    g = FIRST_GUESS[scorer]
    guess = GUESS_LIST[g]
    println("Suggest you try \"$guess\"")
    return h
end


"""
    print_history(h)
Prints out the history object `h` in color.
"""
function print_history(history::Dict{Int, Byte})
    for w in keys(history)
        wordle_print(w, history[w])
    end
end

"""
    guess(history, scorer = min_max_score)
Provide a guess to try in solving Wordle. Automatically called by 
`record!`.
"""
function guess(history::Dict{Int,Byte}, scorer = min_max_score)
    possibles = filter_answers(history)
    if length(possibles) == 0
        println("I give up. No solution possible.")
        return
    end
    guess = GUESS_LIST[best_guess(possibles, scorer)]
    return guess
end

