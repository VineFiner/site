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
    var github: String

    init(name:String, email:String, github:String) {
        self.name = name
        self.email = email
        self.github = github
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        email = try node.extract("email")
        github = try node.extract("github")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "email": email,
            "github": github
        ])

    }
}

extension Author {
    func posts() throws -> Children<Post> {
        return try children()
    }
}

extension Author: Preparation {
    static func prepare(_ database: Database) throws {
        // 无语了都，居然不能这里设置
        try database.create("authors", closure: { (author) in
            author.id()
            author.string("name")
            author.string("email")
            author.string("github")
        })
    }

    // this will be run if vapor run prepare --revert is called.
    static func revert(_ database: Database) throws {
        try database.delete("authors")
    }
}
