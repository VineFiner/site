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
    }

    func loginIndexView(request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("blog/login")
    }
}
