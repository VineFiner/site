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
import Sessions

// 用户管理
final class AuthorController : BaseController {

    override func addRouters() {
        let group = drop.grouped("author")
        group.get("login",  handler: loginIndexView)
        group.post("login", handler: login);
        group.get("regist", handler: registIndexView)
        group.get("logout",Author.self, handler: logout)
        group.post("regist", handler: regist)
        drop.get("/authors", handler: indexView)
    }

    func login(request: Request) throws -> ResponseRepresentable {
        guard let email = request.data["email"]?.string,
            let passwd = request.data["password"]?.string else{
            throw Abort.badRequest
        }

        guard let author = try Author.query().filter("email", contains:email).first() else {
            throw Abort.badRequest
        }

        if author.password.equals(any: passwd) {
            // 保存 session 
            let key = author.email
            try request.session().data[key] = Node.string(author.name)
            return Response(redirect: "/blog")
        } else {
            throw Abort.badRequest
        }
    }

    func logout(request:Request, author:Author) throws -> ResponseRepresentable {
        let key = author.email
        try request.session().data[key] = nil
        // how do?
        return "logout"
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
        return Response(redirect: "/author/login")
    }

    func loginIndexView(request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("blog/login")
    }

    func registIndexView(request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("blog/regist")
    }
}
