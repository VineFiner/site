import Vapor
import VaporMySQL
import TLS

//let drop = Droplet(preparations:[Blog.self], providers: [VaporMySQL.Provider.self])

let drop = Droplet()
//try drop.addProvider(VaporMySQL.Provider.self)
//drop.preparations.append(Blog.self)

let config = try TLS.Config(mode: .server, certificates: .files(
    certificateFile: "/Users/oheroj/Ca/certificate.pem",
    privateKeyFile: "/Users/oheroj/Ca/key.pem",
    signature: .selfSigned
    
    ), verifyHost: true, verifyCertificates: true)

drop.get { req in
//    let query = try Blog.all()
//    return try query.makeNode().converted(to: JSON.self)
    return "Hello,world"
}


drop.get("/post") { req  in
    return JSON(["id":1,"name":"Oheroj","tell":"welcome"])
}

drop.run(servers: [
    "secure": ("0.0.0.0", 8088, .tls(config))
])


