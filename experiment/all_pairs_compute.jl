using WordleSolver, ProgressMeter, Multisets, Counters


# These functions convert 5-tuples to/from Int16s

code_2_int(code::NTuple{5,Int})::Int16 = evalpoly(3, code)
int_2_code(x::Integer) = Tuple(digits(x, base = 3))

"""
    all_pairs_compute
Precompute a (compressed) Wordle score for all pairs of words.
"""
function all_pairs_compute()::Dict{Tuple{String,String},Int16}
    wlist = load_words()
    nw = length(wlist)
    table = Dict{Tuple{String,String},Int16}()

    PM = Progress(nw)
    for i = 1:nw
        a = wlist[i]
        for j = 1:nw
            b = wlist[j]
            table[a, b] = code_2_int(WordleSolver.wordle_score(a, b))
        end
        next!(PM)
    end
    return table
end

"""
    split_size(word, table)

Given a `word` as a possible guess, determine the worst-case scenario
for using that `word` as a first guess in Wordle. Higher results are worse.
"""
function split_size(word::String, table::Dict{Tuple{String,String},Int16})
    wlist = load_words()
    vals = [table[word, w] for w in wlist]
    c = counter(vals)

    return maximum(values(c))
end

function best_first_guess(table::Dict{Tuple{String,String},Int16})
    wlist = load_words()
    best_word = first(wlist)
    best_val  = split_size(best_word, table)

    PM = Progress(length(wlist))

    for word in wlist
        val = split_size(word, table)
        if val < best_val 
            best_val = val
            best_word = word 
        end
        next!(PM)
    end

    return best_word
end
