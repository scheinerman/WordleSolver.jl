function validate(a::Int, history::Dict{Int,Byte})::Bool
    for g in keys(history)
        if fast_wordle_score(g, a) != history[g]
            return false
        end
    end
    return true

end

"""
    filter_answers(history::Dict{Int,Byte})::Vector{Int}
Return a list of indices into ANS_LIST of words that could be valid given the history
"""
function filter_answers(history::Dict{Int,Byte})::Vector{Int}
    [a for a = 1:NA if validate(a, history)]
end

export filter_answers, validate

"""
    make_counts(g::Int, possibles::Vector{Int})
Given a guess `g` and a list of possible answers `possibles`
create a `Counter` that shows how often each score occurs.
"""
function make_counts(g::Int, possibles::Vector{Int})::Counter{Byte}
    vals = [fast_wordle_score(g, a) for a in possibles]
    return counter(vals)
end

export make_counts

# These are three scoring functions to evaluate a list of possible 

"""
    min_max_score(g, possibles)
This score is the largest count returned by `make_counts`.
"""
function min_max_score(g::Int, possibles::Vector{Int})::Int
    c = make_counts(g, possibles)
    return maximum(values(c))
end

"""
    entropy_score(g, possibles)
This is the sum of `x * log(x)` where `x` is a counter value
returned by `make_counts`.
"""
function entropy_score(g::Int, possibles::Vector{Int})
    c = make_counts(g, possibles)
    return sum(x * log(x) for x in values(c))
end

"""
    equi_score(g, possibles)
Always return `1`. This treats all guesses the same.
"""
equi_score(g::Int, possibles::Vector{Int}) = 1

"""
    best_guess(possibles, score_func)
Given a list of possible answers (given by `filter_answers`), return a best guess 
based on minimizing `score_func`.
"""
function best_guess(possibles::Vector{Int}, score_func::Function = min_max_score)
    glist = shuffle(collect(1:NG))

    best_g = first(possibles)
    best_s = score_func(best_g, possibles)


    for g in glist
        s = score_func(g, possibles)
        if s < best_s
            best_g = g
            best_s = s
        end
    end
    return best_g
end

export best_guess, min_max_score, entropy_score, equi_score


FIRST_GUESS = Dict{Function,Int}()
# @info "Precomputing first guesses"

FIRST_GUESS[min_max_score] = 9730
FIRST_GUESS[equi_score] = 1
FIRST_GUESS[entropy_score] = 10846


function make_first_guesses()
    for f in [min_max_score, entropy_score, equi_score]
        g = best_guess(collect(1:NA), f)
        FIRST_GUESS[f] = g
        guess = GUESS_LIST[g]
        @info "First guess for $f is $guess"
    end
end

export make_first_guesses
