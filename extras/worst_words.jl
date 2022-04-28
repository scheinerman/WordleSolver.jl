using WordleSolver, ProgressMeter

function multiplay(word::String, scorer::Function, reps::Int)
    return [auto_play(word, scorer = scorer, verbose = false) for _ = 1:reps]
end

"""
    scorer_step_table(scorer::Function=min_max_score, reps::Int=10)
Use the `scorer` to play all possible wordle words `reps` times each
and create a dictionary of the average number of steps to solve.
"""
function scorer_step_table(scorer::Function = min_max_score, reps::Int = 5)
    d = Dict{String,Float64}()
    PM = Progress(WordleSolver.NA)
    for w ∈ WordleSolver.ANS_LIST
        s = sum(multiplay(w, scorer, reps))
        d[w] = s / reps
        next!(PM)
    end
    return d
end


function worst(d::Dict{T,S}) where {T,S<:Real}
    m = maximum(values(d))
    return [w for w in keys(d) if d[w] == m]
end


"""
    worst_words(scorer::Function=min_max_score, reps::Int=5)

Find the words that scores the worst using scoring method `scorer`.
"""
function worst_words(scorer::Function = min_max_score, reps::Int = 5)
    d = scorer_step_table(scorer, reps)
    return worst(d)
end
