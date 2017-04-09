//
//  CategoryController.swift
//  spider
//
//  Created by laijihua on 21/12/2016.
//
//


import Foundation
import HTTP
import Vapor

// 分类管理
final class CategoryController : BaseController {

    override func addRouters() {
        let group = drop.grouped("category")
        group.get("/", handler:indexView) // 列表 + 创建
        group.post("/", handler: createCategory)
        group.post("/update",Int.self, handler: updateCategory)
        group.get("/update", Category.self, handler:reUpdateCategory )
        group.post(Category.self,"/delete", handler: deleteCategory)
    }

    func indexView(request: Request) throws -> ResponseRepresentable {
        let categorys = try Category.all().makeNode()
        let parameters = try Node(node:["categorys":categorys])
        print(parameters)
        return try drop.view.make("blog/category", parameters)
    }

    func deleteCategory(request: Request, category: Category) throws -> ResponseRepresentable {
        try category.delete()
        return Response(redirect: "/category")
    }

    func createCategory(request: Request)throws -> ResponseRepresentable {
        guard let title = request.data["title"]?.string else {
            throw Abort.badRequest
        }
        var category = Category(title: title)
        try category.save()
        return Response(redirect: "/category")
    }

    func reUpdateCategory(request: Request, category: Category) throws -> ResponseRepresentable {
        let parmas = try Node(node: ["category": category.makeNode()])

        return try drop.view.make("blog/category_create", parmas)
    }

    func updateCategory(request: Request, id:Int) throws -> ResponseRepresentable {

        guard let title = request.data["title"]?.string else{
            throw Abort.badRequest
        }

        var category = try Category.find(id)
        category?.title = title
        try category?.save()
        
        return Response(redirect: "/category")
    }
    
}
