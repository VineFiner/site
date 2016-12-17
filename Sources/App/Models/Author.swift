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

    init(name:String) {
        self.name = name
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name
        ])

    }
}
extension Author: Preparation {
    static func prepare(_ database: Database) throws {
        // 无语了都，居然不能这里设置
        try database.create("authors", closure: { (author) in
            author.id()
            author.string("name")
        })
    }

    // this will be run if vapor run prepare --revert is called.
    static func revert(_ database: Database) throws {
        try database.delete("authors")
    }
}
