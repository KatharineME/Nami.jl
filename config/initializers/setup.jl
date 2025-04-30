#function update!(di, se = 1800)
#
#    while true
#
#      println(readdir(di; join=true))
#
#        rm.(readdir(di; join = true), recursive = true)
#
#        sleep(se)
#
#        @info "update $di one done"
#        
#        println("update $di one done")
#
#    end
#
#end
#
#
#println("$(readdir())")
#
#@async update!("public/upload", 10)
#
#println("end of setup")
