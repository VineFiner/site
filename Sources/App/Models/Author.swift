//
//  Author.swift
//  spider
//
//  Created by laijihua on 17/11/2016.
//
//

import Foundation
import Fluent
import Vapor

final class Author : Model {

    var id: Node?
    var name: String
    var email: String
    var github: String?
    var password: String

    init(name:String, email:String, github:String?, password: String) {
        self.name = name
        self.email = email
        self.github = github
        self.password = password
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        email = try node.extract("email")
        github = try node.extract("github")
        password = try node.extract("password")
        
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "email": email,
            "github": github,
            "password": password
        ])

    }
}

extension Author {
    func posts() throws -> Children<Post> {
        return  children()
    }

    func session() throws -> Children<Session> {
        return children()
    }
}

extension Author: Preparation {
    static func prepare(_ database: Database) throws {
        // 无语了都，居然不能这里设置
        try database.create("authors", closure: { (author) in
            author.id()
            author.string("name")
            author.string("email")
            author.string("github", optional:true)
            author.string("password")
        })
    }

    // this will be run if vapor run prepare --revert is called.
    static func revert(_ database: Database) throws {
        try database.delete("authors")
    }
}
