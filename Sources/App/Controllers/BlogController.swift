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
import Fluent

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
            let content = request.data["content"]?.string else {
                throw Abort.badRequest
        }
        var post = try Post.find(id)
        post?.title = title
        post?.content = content
        try post?.save()
        return Response(redirect: "/blog")

    }

    func rePost(request: Request, post: Post) throws -> ResponseRepresentable {
        let category_id = try post.categorys().first()
        let categorys = try Category.all().makeNode()
        // TODO: 应该是一对多的关系哇。
        let params = try Node(node:["post": post,
                                    "category_id": category_id,
                                    "categorys": categorys])
        return try drop.view.make("blog/create", params)
    }

    func createPost(request: Request) throws -> ResponseRepresentable {
        let categorys = try Category.all().makeNode()
        let params = try Node(node:["categorys": categorys])
        return try drop.view.make("blog/create", params)
    }

    func deletePost(request: Request, post:Post) throws -> ResponseRepresentable {

        try post.delete()
        return Response(redirect: "/blog")
    }

    func addPost(request: Request) throws -> ResponseRepresentable {
        guard let title = request.data["title"]?.string,
            let content = request.data["content"]?.string,
        let category_id = request.data["category"]?.int else {
            throw Abort.badRequest
        }
        guard let category = try Category.find(category_id) else {
            throw Abort.badRequest
        }
        var post = Post(title: title, content: content, authorId: 1)
        try post.save()

        var pivot = Pivot<Category, Post>(category, post)
        try pivot.save()
        return Response(redirect: "/blog")
    }

    func indexView(request: Request) throws -> ResponseRepresentable {
        let posts = try Post.all().makeNode()
        let parameters = try Node(node: ["posts": posts])
        return try drop.view.make("blog/index", parameters)
    }
}
