
include("guesses.jl")
include("answers.jl")


# list of possible answers
ANS_LIST = make_answers() # place to hold list of words so we only load it once

# list of allowable guesses
GUESS_LIST = Set(ANS_LIST) ∪ Set(make_guesses()) |> collect |> sort


# reverse lookup dictionaries. Given a word, find where in the appropriate list
# to find that word.

ANS_DICT = Dict{String,Int}()
for j = 1:length(ANS_LIST)
    w = ANS_LIST[j]
    ANS_DICT[w] = j
end

@info "Answer dictionary has $(length(ANS_DICT)) entries"

GUESS_DICT = Dict{String,Int}()
for j = 1:length(GUESS_LIST)
    w = GUESS_LIST[j]
    GUESS_DICT[w] = j
end

@info "Guess dictionary has $(length(GUESS_DICT)) entries"


include("pre_compute_tools.jl")

@info "Precomputing for a minute"

SCORE_MATRIX = all_pairs_compute()
