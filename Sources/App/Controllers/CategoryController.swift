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
        group.get("/", handler:userIndexView)
    }

    func userIndexView(request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("blog/author")
    }
    
}
