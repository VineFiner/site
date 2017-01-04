//
//  IndexController.swift
//  spider
//
//  Created by laijihua on 04/01/2017.
//
//

import Vapor
import HTTP

final class IndexController : BaseController {

    override func addRouters() {
        drop.get("/",handler: indexView)
        drop.get("post", Post.self, handler: detailView)
    }

    func indexView(request: Request) throws -> ResponseRepresentable {
        let posts = try Post.all().makeNode()
        let params = try Node(node: ["posts": posts])
        return try drop.view.make("index", params)
    }

    func detailView(request: Request, post: Post) throws -> ResponseRepresentable {
        let params = try Node(node: ["post": post.makeNode()])
        return try drop.view.make("detail", params)

    }
}
