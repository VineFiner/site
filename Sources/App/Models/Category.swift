//
//  Category.swift
//  spider
//
//  Created by laijihua on 10/12/2016.
//
//

import Vapor
import Fluent

final class Category : Model {

    var id: Node?
    var title: String

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        title = try node.extract("title")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "title": title,
            ])
    }
}

// 多对多
extension Category {
    func posts() throws -> Siblings<Post> {
        return try siblings()
    }
}

extension Category: Preparation {
    static func prepare(_ database: Database) throws {
        // 无语了都，居然不能这里设置
        try database.create("categorys", closure: { (category) in
            category.id()
            category.string("title")
        })
    }

    // this will be run if vapor run prepare --revert is called.
    static func revert(_ database: Database) throws {
        try database.delete("categorys")
    }
}
