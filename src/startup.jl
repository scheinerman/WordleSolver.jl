
include("guesses.jl")
include("answers.jl")


# list of possible answers
ANS_LIST = make_answers() # place to hold list of words so we only load it once

# list of allowable guesses
# GUESS_LIST = Set(ANS_LIST) ∪ Set(make_guesses()) |> collect |> sort

GUESS_LIST = vcat(ANS_LIST, make_guesses())


# reverse lookup dictionaries. Given a word, find where in the appropriate list
# to find that word.

ANS_DICT = Dict{String,Int}()
for j = 1:length(ANS_LIST)
    w = ANS_LIST[j]
    ANS_DICT[w] = j
end

NA = length(ANS_DICT)

@info "Answer dictionary has $NA entries"

GUESS_DICT = Dict{String,Int}()
for j = 1:length(GUESS_LIST)
    w = GUESS_LIST[j]
    GUESS_DICT[w] = j
end


NG = length(GUESS_DICT)
@info "Guess dictionary has $NG entries"


include("pre_compute_tools.jl")

@info "Precomputing for a minute"

SCORE_MATRIX = all_pairs_compute()
