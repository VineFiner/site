import Vapor


let drop = Droplet()


drop.get { req in
//    let query = try Blog.all()
//    return try query.makeNode().converted(to: JSON.self)
    return "Hello,world"
}


drop.get("/post") { req  in
    return JSON(["id":1,"name":"Oheroj","tell":"welcome"])
}

drop.run()


