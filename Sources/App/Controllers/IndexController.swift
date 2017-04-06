//
//  IndexController.swift
//  spider
//
//  Created by laijihua on 04/01/2017.
//
//

import Vapor
import HTTP
import Fluent

final class IndexController : BaseController {

    override func addRouters() {
        drop.get("/",handler: indexView)
        drop.get("post", Post.self, handler: detailView)
    }

    func indexView(request: Request) throws -> ResponseRepresentable {
        var page = 1
        if let pageIndex = request.data["page"]?.int {
            page = pageIndex
        }

        let pageCount = 5 // 每页显示条数
        // 获取到总条数
        let postsCount = try Post.all().count;

        // 总页数
        let pageNum = postsCount / pageCount + 1;

        var hasNext = true //是否有下一页
        var hasPre = true // 是否有上一页

        if (page > pageNum) {
            page = pageNum
        }

        if (page < 1) {
            page = 1
        }

        if (page == pageNum) {
            hasNext = false
        }

        if (1 == page) {
            hasPre = false
        }


        if (page > pageNum || page == 0) {
            throw Abort.badRequest
        }

        // 获 limit 的第一个参数值, (1-1)*10=0, (2-1)*10
        let offset = (page - 1) * pageCount

        let querty = try Post.query()

        querty.limit = Limit(count: pageCount, offset: offset)

        let posts = try querty.all().makeNode()

//        let params = try Node(node:["hasNext":hasNext, "hasPre": hasPre, "posts": posts, "currentPage":page])
        let params = try Node(node:["posts": posts])
        print(params)
        return try drop.view.make("index", params)
    }

    func detailView(request: Request, post: Post) throws -> ResponseRepresentable {
        let params = try Node(node: ["post": post.makeNode()])
        return try drop.view.make("detail", params)
    }
}
