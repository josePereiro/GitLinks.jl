# GitLinks

[![Build Status](https://github.com/josePereiro/GitLinks.jl/workflows/CI/badge.svg)](https://github.com/josePereiro/GitLinks.jl/actions)
[![Coverage](https://codecov.io/gh/josePereiro/GitLinks.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/josePereiro/GitLinks.jl)

Allows to synchronize folders using `git` automatically.

## Basic usage

> NOTE: Many of this methods returns `true` if the operation was successful. Also, all of them will block the link's `lock`.

In order to create a link you need to specify a `remote_url` and a `root_dir`.

```julia
using GitLinks

# test config
verbose = false

# test root (change this to move the test env)
test_root = joinpath(@__DIR__, "gl-testroot")
link_root = joinpath(test_root, "gl-link")

# Create a test upstream repo
remote_url, remote_dir = create_local_upstream(test_root; verbose);

# Create a link object
gl = GitLink(link_root, remote_url)

# init the link (it'll attemp to pull)
instantiate(gl; verbose)

# ls link_root
println("ls link_root")
readdir(link_root) .|> println;
# ls link_root
# .gl-local-state
# .gl-repo

```

The method `instantiate` will create the file structure of the link.
Note that the `link_root` is not the repository's root folder.
The repo is located at `link_root/.gl-repo` and can be access using `repo_dir(gl)`.
The folder `link_root/.gl-local-state` will contain files for local use like event tokens, etc.

The main goal of the link is to perform reliable synchronization operations between the local link and the remote.
The remote copy of the repo is considered the "real" one, so it will never be forced directly, instead, the local copy must be sync (`hard pull`), then modified, and then upload (`soft push`).

**hard pull**: It will fetch and reset the local copy. If it fail, the local repo is deleted and then clone (`--deep=1`) back.
**soft push**: It will try to make a simple `push` to the remote. If it fail, the local repo is deleted.

The package export several functions:

**`download`**: make a `hard pull` to overwrite the local copy with the remote.

```julia
download(gl; verbose) do wdir
    @assert repo_dir(gl) == wdir
    println("ls wdir")
    readdir(wdir) .|> println;
end
# ls wdir
# .git
# .gl-glob-state
# README.md
```

The working directory can be access using `repo_dir(gl)`.
After the `hard pull` succeeded a callback can be called on the working dir.
The `wdir/.gl-glob-state` folder is used to store global files like signals, dummies, etc.

**`upload_wdir`**: download and then make a `soft push` to remote.

```julia
upload_wdir(gl; verbose) do wdir
    # here you modify wdir
    write(joinpath(wdir, "testfile.txt"), "Hola mundo") # new file
    println("ls wdir")
    readdir(wdir) .|> println;
end
# ls wdir
# .git
# .gl-glob-state
# README.md
# testfile.txt
```
Note that a `testfile.txt` has being created

**`upload_stage`**: download, merge the `stage_dir`, and then make a `soft push` to remote.

This method is use to accumulate changes and then push them all at once.

```julia
upload_stage(gl::GitLink; verbose) do stdir
    # here you modify the stage
    @assert stage_dir(gl) == stdir
    write(joinpath(stdir, "testfile.txt"), "Hola mundo")
    println("ls stdir")
    readdir(stdir) .|> println;
end
# ls stdir
# testfile.txt
```

You can access the stage folder using `stage_dir(gl)`.
If the changes take a while, you can use the method `stage` to modify the stage folder and then upload it.
This helps to reduce the number of communications between the repos.

```julia
stage(gl::GitLink) do stdir
    # here you modify the stage dir
    @assert stage_dir(gl) == stdir
    for i in 1:5
        # several changes
        write(joinpath(stdir, "testfile$i.txt"), "Hola mundo")
    end
    println("ls stdir")
    readdir(stdir) .|> println;
end
# ls stdir
# testfile.txt
# testfile1.txt
# testfile2.txt
# testfile3.txt
# testfile4.txt
# testfile5.txt

upload_stage(gl; verbose)
```

We can check all the changes.

```julia
download(gl; verbose) do wdir
    @assert repo_dir(gl) == wdir
    println("ls wdir")
    readdir(wdir) .|> println;
end
# ls wdir
# .git
# .gl-glob-state
# README.md
# testfile.txt
# testfile1.txt
# testfile2.txt
# testfile3.txt
# testfile4.txt
# testfile5.txt
```


### Utils

**`has_connection`**: returns if the link has connection with the remote or not

## Server

> NOTE: Many of this methods returns `true` if the operation was successful. Also, all of them will block the link's `lock`.

By using `run_sync_loop`, you can run a loop which will `pull/merge stage/push` continuously, so another thread/process can listen the `wdir` (using `readwdir`) or write (using `stage`) in the stage to upload.

### Utils

**`ping`**: test is there are any server listening to the same link.

```julia
# run a server
@async run_sync_loop(gl; niters = 10, verbose = false);

# run a 'client'
clien_root = joinpath(test_root, "client")
clien_gl = GitLink(clien_root, remote_url)

# ping
ping(clien_gl; verbose = true)
# [ Info: Sending ping signal
# [ Info: Ping signal sended
# [ Info: Waiting for response...
# [ Info: Ping 1 succeded, time: 8.62(s)
# [ Info: Ping 2 succeded, time: 3.22(s)
# [ Info: Ping 3 succeded, time: 3.2(s)
# [ Info: Ping 4 succeded, time: 4.28(s)
# [ Info: Ping 5 succeded, time: 3.21(s)
# [ Info: Ping 6 succeded, time: 3.21(s)
# [ Info: Ping 7 succeded, time: 4.27(s)
# [ Info: Time out, total time: 45.2(s)
```

## TODO

- Add `GitLink` configuration system (ex: `TOML` files)

- More configurable `git` CLI utils
- Use `libgit2` (in addition to CLI) for `git` operations (help wanted)
- Add a log system (fetchable)
