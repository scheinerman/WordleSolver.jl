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