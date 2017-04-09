//
//  Session.swift
//  spider
//
//  Created by laijihua on 08/04/2017.
//
//

import Vapor
import Fluent
import Foundation

//用户鉴权方面则打算采用Token方式。用户登录之后分配一个accessToken和一个refreshToken，accessToken用于发起用户请求，refreshToken用于更新accessToken。accessToken会设置有效期，可以设为24小时。而用户退出登录之后，accessToken和refreshToken都将作废。重新登录之后会分配新的accessToken和refreshToken。

final class Session: Model {

    var id: Node?
    var author_id: Node
    var accessToken: String
    var refreshToken: String
    var accessTokenValiadTime: Int
    var refreshTokenValiadTime: Int

    init(accessToken:String, refreshToken:String, author_id:Node) {
        self.author_id = author_id
        self.accessToken = accessToken
        self.refreshToken = refreshToken

        // accessToken 1天的失效时间
        // refreshToken 30天的失效实现
        let currentDate = Date()
        let oneDate = currentDate.addingTimeInterval(24 * 60 * 60)
        let monthDate = currentDate.addingTimeInterval(24 * 60 * 60 * 30)
        self.accessTokenValiadTime = Int(oneDate.timeIntervalSince1970)
        self.refreshTokenValiadTime = Int(monthDate.timeIntervalSince1970)
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        author_id = try node.extract("author_id")
        accessToken = try node.extract("accesstoken")
        refreshToken = try node.extract("refreshtoken")
        accessTokenValiadTime = try node.extract("accesstokenvaliadtime")
        refreshTokenValiadTime = try node.extract("refreshtokenvaliadtime")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "author_id": author_id,
            "accessToken": accessToken,
            "refreshToken": refreshToken,
            "accessTokenValiadTime": accessTokenValiadTime,
            "refreshTokenValiadTime": refreshTokenValiadTime
            ])
    }
}

extension Session {
    func author() throws -> Parent<Author> {
        return try parent(author_id)
    }
}

extension Session: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("sessions", closure: { (session) in
            session.id()
            session.int("author_id")
            session.string("accesstoken")
            session.string("refreshtoken")
            session.int("accesstokenvaliadtime")
            session.int("refreshtokenvaliadtime")
        })
    }

    // this will be run if vapor run prepare --revert is called.
    static func revert(_ database: Database) throws {
        try database.delete("sessions")
    }
}
