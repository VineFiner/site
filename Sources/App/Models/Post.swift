import Vapor
import Fluent
import Foundation

final class Post: Model {
    var id: Node?
    var desc: String
    var title: String
    var category: String
    var content: String
    
    init(desc:String, title:String, content: String, category:String ) {
        self.desc = desc
        self.title = title
        self.content = content
        self.category = category
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        desc = try node.extract("desc")
        title = try node.extract("title")
        content = try node.extract("content")
        category = try node.extract("category")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "desc": desc,
            "title": title,
            "content": content,
            "category": category,
        ])
    }
}

extension Post: Preparation {
    static func prepare(_ database: Database) throws {
        // 无语了都，居然不能这里设置
        try database.create("posts", closure: { (post) in
            post.id()
            post.string("desc")
            post.string("title")
            post.string("content")
            post.string("category")
        })
    }
    
    // this will be run if vapor run prepare --revert is called.
    static func revert(_ database: Database) throws {
        try database.delete("posts")
    }
}
