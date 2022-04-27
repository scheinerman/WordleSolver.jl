using WordleSolver, ProgressMeter

function compute_average_steps(scorer::Function=min_max_score, reps::Int=10)
    d = Dict{String,Float64}()
    PM = Progress(WordleSolver.NA)
    for w ∈ WordleSolver.ANS_LIST
        s = 0
        for _ = 1:reps
            s += auto_play(w, scorer=scorer, verbose=false)
        end
        d[w] = s / reps
        next!(PM)
    end
    return d
end