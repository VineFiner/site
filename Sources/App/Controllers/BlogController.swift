//
//  BlogController.swift
//  spider
//
//  Created by laijihua on 17/12/2016.
//
//

import HTTP
import Vapor
import cmark_swift

final class BlogController : BaseController {

    override func addRouters() {
        let group = drop.grouped("blog")
        group.get("/", handler: indexView) // index
        group.post("/",handler: addPost)  // add
        group.get(Post.self, handler: postDetail)
        group.post(Post.self, "delete", handler: deletePost) //delete
        group.get("create", handler: createPost) // create 页面
        group.get("update", Post.self, handler:rePost)
        group.post("update", Int.self, handler: updatePost)
    }

    func postDetail(request: Request, post: Post) throws -> ResponseRepresentable {
        let content = post.content
        let params = ["content": content]
        return try drop.view.make("blog/detail", params)
    }

    func updatePost(request: Request, id:Int) throws -> ResponseRepresentable {
        guard let title = request.data["title"]?.string,
            let content = request.data["content"]?.string,
            let category = request.data["category"]?.string else {
                throw Abort.badRequest
        }
        var post = try Post.find(id)
        post?.title = title
        post?.category = category
        post?.content = content
        try post?.save()
        return Response(redirect: "/blog")

    }

    func rePost(request: Request, post: Post) throws -> ResponseRepresentable {
        let params = ["post": post]
        return try drop.view.make("blog/create", params)
    }

    func createPost(request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("blog/create")
    }

    func deletePost(request: Request, post:Post) throws -> ResponseRepresentable {

        try post.delete()
        return Response(redirect: "/blog")
    }

    func addPost(request: Request) throws -> ResponseRepresentable {
        guard let title = request.data["title"]?.string,
            let content = request.data["content"]?.string,
        let category = request.data["category"]?.string else {
            throw Abort.badRequest
        }
        var post = Post(desc: content, title: title, content: content, category: category)
        try post.save()
        return Response(redirect: "/blog")
    }

    func indexView(request: Request) throws -> ResponseRepresentable {
        let posts = try Post.all().makeNode()
        let parameters = try Node(node: ["posts": posts])
        return try drop.view.make("blog/index", parameters);
    }
}
