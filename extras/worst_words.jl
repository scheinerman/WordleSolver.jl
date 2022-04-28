using WordleSolver, ProgressMeter

"""
    scorer_step_table(scorer::Function=min_max_score, reps::Int=10)
Use the `scorer` to play all possible wordle words `reps` times each
and create a dictionary of the average number of steps to solve.
"""
function scorer_step_table(scorer::Function = min_max_score, reps::Int = 5)
    d = Dict{String,Float64}()
    PM = Progress(WordleSolver.NA)
    for w ∈ WordleSolver.ANS_LIST
        s = 0
        for _ = 1:reps
            s += auto_play(w, scorer = scorer, verbose = false)
        end
        d[w] = s / reps
        next!(PM)
    end
    return d
end

"""
    worst_words(scorer::Function=min_max_score, reps::Int=5)

Find the words that scores the worst using scoring method `scorer`.
"""
function worst_words(scorer::Function = min_max_score, reps::Int = 5)
    d = scorer_step_table(scorer, reps)
    m = maximum(values(d))
    return [w for w in WordleSolver.ANS_LIST if d[w] == m]
end
