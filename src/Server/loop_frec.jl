# TODO: Connect with GitLink config
const _MIN_LOOP_FREC = 3.0
const _MAX_LOOP_FREC = 60.0

const _LOOP_FREC_KEY = :loop_frec_key
loop_frec(gl::GitLink) = clamp(
    get!(gl, _LOOP_FREC_KEY, _MIN_LOOP_FREC), 
    _MIN_LOOP_FREC, _MAX_LOOP_FREC
)

loop_frec!(gl::GitLink, val) = set!(gl, _LOOP_FREC_KEY, clamp(float(val), _MIN_LOOP_FREC, _MAX_LOOP_FREC))
add_loop_frec!(gl::GitLink, val) = loop_frec!(gl, loop_frec(gl) + val)