//
//  AcronymController.swift
//  spider
//
//  Created by laijihua on 17/12/2016.
//
//

import HTTP
import Vapor
import VaporMySQL

final class AcronymController : BaseController {

    // 添加路由
    override func addRouters() {
        drop.get("version", handler: version)
        drop.get("til", handler: indexView)
        drop.post("til",handler: addAcronym)
        drop.post("til", Acronym.self, "delete", handler: deleteAcronym)
    }


    func indexView(request: Request) throws -> ResponseRepresentable {
        let acronyms = try Acronym.all().makeNode()
        let parameters = try Node(node: ["acronyms": acronyms])

        return try drop.view.make("index", parameters)

    }

    func addAcronym(request: Request) throws -> ResponseRepresentable {
        guard let short = request.data["short"]?.string, let long = request.data["long"]?.string else {
            throw Abort.badRequest
        }

        var acronym = Acronym(short: short, long: long)
        try acronym.save()
        return Response(redirect: "/til")

    }

    func deleteAcronym(request: Request, acronym:Acronym) throws -> ResponseRepresentable {
        try acronym.delete()
        return Response(redirect: "/til")
    }

    func version(request: Request) throws -> ResponseRepresentable {
        if let db = drop.database?.driver as? MySQLDriver {
            let version = try db.raw("select version()")
            return  try JSON(node: version)
        } else {
            return "No db Connection"
        }
    }

}
