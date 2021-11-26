const _RAND_STR_ALPB = ['a':'z'; 'A':'Z'; '0':'9']

rand_str(n = 10) = join(rand(_RAND_STR_ALPB, n))