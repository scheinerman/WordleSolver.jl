using WordleSolver, ProgressMeter

"""
    worst_word(scorer::Function=min_max_score, reps::Int=5)

Find the word that scores the worst using scoring method `scorer`.
"""
function worst_word(scorer::Function=min_max_score, reps::Int=5)
    d = Dict{String,Float64}()
    PM = Progress(WordleSolver.NA)
    worst_avg = 0.0
    worst_word = "XXXXX"
    @info "Finding most difficult wordle word using scorer $scorer"
    for w ∈ WordleSolver.ANS_LIST
        s = 0
        for _ = 1:reps
            s += auto_play(w, scorer=scorer, verbose=false)
        end
        avg_steps = s/reps
        if avg_steps > worst_avg
            worst_word = w 
            worst_avg = avg_steps
        end

        next!(PM)
    end
    return worst_word
end