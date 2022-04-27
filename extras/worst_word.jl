using WordleSolver, ProgressMeter

function worst_steps(scorer::Function=min_max_score, reps::Int=10)
    d = Dict{String,Float64}()
    PM = Progress(WordleSolver.NA)
    worst_avg = 0.0
    worst_word = "XXXXX"
    for w ∈ WordleSolver.ANS_LIST
        s = 0
        for _ = 1:reps
            s += auto_play(w, scorer=scorer, verbose=false)
        end
        avg_steps = s/reps
        if avg_steps > worst_avg
            worst_word = w 
            worst_avg = avg
        end

        next!(PM)
    end
    return worst_word
end