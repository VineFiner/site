import Vapor
import VaporPostgreSQL

let drop = Droplet()
// have error
//try drop.addProvider(VaporPostgreSQL.Provider.self)
//drop.preparations.append(Blog.self)

drop.get { req in
    return "Hello,world"
}


drop.get("/post") { req  in
    return JSON(["id":1,"name":"Oheroj","tell":"welcome"])
}

drop.run()


