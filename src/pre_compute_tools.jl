# These functions convert 5-tuples to/from Int16s

Byte = UInt8

"""
    code_2_byte(code::NTuple{5,Int})
Compress a Worlde result into a single byte.
"""
code_2_byte(code::NTuple{5,Int})::Byte = evalpoly(3, code)


"""
    byte_2_code(x)
Convert a (byte) into a 5-tuple, inverting the action of `code_2_byte`.
"""
byte_2_code(x::Integer) = Tuple(digits(x, base = 3, pad = five))


export all_pairs_compute, code_2_byte, byte_2_code

"""
    all_pairs_compute
Precompute a (compressed) Wordle score for all pairs of words.
"""
function all_pairs_compute()::Matrix{Byte}

    n_ans = length(ANS_LIST)
    n_guess = length(GUESS_LIST)
    M = zeros(Byte, n_guess, n_ans)

    PM = Progress(n_guess)
    for i = 1:n_guess
        a = GUESS_LIST[i]
        for j = 1:n_ans
            b = ANS_LIST[j]
            M[i,j] = code_2_byte(wordle_score(a, b))
        end
        next!(PM)
    end
    return M
end


