let
    root = tempname()
    url = "bla.com"
    gl = GitLinks.GitLink(root, url)

    lf = GitLinks.lock_file(gl)

    # Test write and read
    lid1, ttag1 = GitLinks._write_lock_file(lf)
    lid2, ttag2 = GitLinks._read_lock_file(lf)

    @test lid1 == lid2
    @test ttag1 == ttag2

    # Test valid period
    vtime = 3.0
    lid3, ttag3 = GitLinks._write_lock_file(lf; vtime)
    @test !isempty(lid3)
    @test ttag3 > time()
    @test isfile(lf)

    @test GitLinks.has_lock(lf, lid3)

    lid4, ttag4 = GitLinks.get_lock(lf) # This must be taken
    @test isempty(lid4)
    @test ttag3 == ttag4
    
    sleep(2 * vtime) # expire lock

    @test !GitLinks.has_lock(lf, lid3)
    @test !isfile(lf) # has_lock must delete an invalid lock file

    vtime = 50.0
    lid4, ttag4 = GitLinks.get_lock(lf; vtime) # This must be free
    @test lid4 != lid3 # create a new lock
    @test ttag4 > ttag3 # create a new lock
    @test isfile(lf)

    # test wait
    lid5, ttag5 = GitLinks.get_lock(lf::String; tout = 2.0) # This must fail
    @test isempty(lid5)
    @test ttag4 == ttag5

    # Test release
    @test GitLinks.has_lock(lf, lid4)
    @test GitLinks.release_lock(lf, lid4)
    @test !GitLinks.has_lock(lf, lid4)
    @test !isfile(lf)

    # base.lock
    lock(gl) do
        # all this time the lock is taken
        for it in 1:10
            @test !GitLinks.has_lock(lf, "Not a lock id")
            sleep(0.2)
        end
    end
    @test !isfile(lf)

    # clear
    rm(root; recursive = true, force = true)
end