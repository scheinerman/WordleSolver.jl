include(homedir() * "/.julia/dev/WordleSolver/extras/worst_words.jl")
reps = 10
T = make_all_tables(reps)
full_report(T)
