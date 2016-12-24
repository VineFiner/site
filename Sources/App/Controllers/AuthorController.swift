//
//  AuthorController.swift
//  spider
//
//  Created by laijihua on 21/12/2016.
//
//

import Foundation
import HTTP
import Vapor

// 用户管理
final class AuthorController : BaseController {

    override func addRouters() {
        let group = drop.grouped("author")
        group.get("login", handler: loginIndexView)
        group.get("regist", handler: registIndexView)
        group.post("regist", handler: regist)
        drop.get("/authors", handler: indexView)

    }

    func indexView(request: Request) throws -> ResponseRepresentable {
        let authors = try Author.all().makeNode()
        let parmas = try Node(node: ["authors": authors])

        return try drop.view.make("/blog/author", parmas)


    }

    func regist(request: Request) throws -> ResponseRepresentable {
        guard let email = request.data["email"]?.string,
            let passwd = request.data["password"]?.string,
            let name = request.data["name"]?.string else {
                throw Abort.badRequest
        }

        let github = request.data["github"]?.string
        
        var author = Author(name: name, email: email, github: github, password: passwd)
        try author.save()

        return Response(redirect: "/authors")

    }

    func loginIndexView(request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("blog/login")
    }

    func registIndexView(request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("blog/regist")
    }
}
