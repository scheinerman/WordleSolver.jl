function validate(a::Int, history::Dict{Int,Byte})::Bool
    for g in keys(history)
        if fast_wordle_score(g,a) != history[g]
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
    [a for a=1:NA if validate(a,history)]
end

export filter_answers, validate


function make_counts(g::Int, possibles::Vector{Int})::Counter{Byte}
    vals = [fast_wordle_score(g,a) for a in possibles]
    return counter(vals)
end

export make_counts

function min_max_score(g::Int, possibles::Vector{Int})::Int
    c = make_counts(g, possibles)
    return maximum(values(c))
end

function entropy_score(g::Int, possibles::Vector{Int})
    c = make_counts(g, possibles)
    return sum(x * log(x) for x in values(c))
end

"""
    best_guess(possibles, score_func)
Given a list of possible answers (given by `filter_answers`), return a best guess 
based on minimizing `score_func`.
"""
function best_guess(possibles::Vector{Int}, score_func::Function = min_max_score)
    best_g = 1
    best_s = score_func(best_g, possibles)
    for g = 1:NG
        s = score_func(g,possibles)
        if s < best_s 
            best_g = g 
            best_s = s
        end
    end
    return best_g
end

export best_guess, min_max_score, entropy_score
