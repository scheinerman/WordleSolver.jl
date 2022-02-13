@everywhere using WordleSolver, Distributed


"""
    parallel_score_all(scorer, reps)
Use the scoring method `scorer` to solve all possible Wordle puzzles
`reps` times each. Return the average number of guesses (averaged over all
repetitions and possible words).

Start up with `julia -p 8` (or whatever number of processors available).
Then `include("parallel_score_all.jl")`.
"""
function parallel_score_all(scorer::Function, reps::Int = 1)
    NA = WordleSolver.NA
    total = 0
    for k = 1:reps
        @info "Round $k of $reps"
        subtotal = @distributed (+) for a = 1:NA
            auto_play(a, scorer = scorer)
        end
        total += subtotal
    end
    return total / (reps * NA)
end
