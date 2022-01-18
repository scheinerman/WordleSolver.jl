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


"""
    make_split_table(table)
Make a table of split sizes.
"""
function make_split_table(table::Dict{Tuple{String,String},Int16})
    stable = Dict{String,Int}()
    wlist = load_words()
    nw = length(wlist)
    PM = Progress(nw)
    for word in wlist 
        stable[word] = split_size(word, table)
        next!(PM)
    end
    return stable
end

function sorted_split_table(table::Dict{Tuple{String,String},Int16})
    sp_tab = make_split_table(table)
    wlist = load_words()
    sp_vector = [ (w, sp_tab[w]) for w in wlist ]

    function LT(p1, p2)
        if p1[2] < p2[2]
            return true
        end
        return false
    end

    return sort(sp_vector; lt = LT)

end



"""
    best_first_guess(table)

Compute an optimal first guess for Wordle that minimizes the largest 
number of words that may be possible after that guess.

Here `table = all_pairs_compute();`
"""
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


function best_first_guess()
    println("Computing all pairs table.")
    table = all_pairs_compute()
    return best_first_guess(table)
end