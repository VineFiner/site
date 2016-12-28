import Vapor
import Fluent
import Foundation

final class Post: Model {
    var id: Node?
    var title: String
    var content: String
    var html: String
    var author_id: Node // 作者
    //TODO: 暂存
    init(title:String, content: String, authorId: Node) {
        self.title = title
        self.html = ""
        self.content = content
        self.author_id = authorId
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        title = try node.extract("title")
        content = try node.extract("content")
        author_id = try node.extract("author_id")
        html = try node.extract("html")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "title": title,
            "content": content,
            "author_id": author_id,
            "html": html
        ])
    }
}

extension Post {
    // 一对一， 父与子，
    func auther() throws -> Parent<Author> {
        return try parent(author_id)
    }

    func categorys() throws -> Siblings<Category> {
        return try siblings()
    }
}

extension Post: Preparation {
    static func prepare(_ database: Database) throws {
        // 无语了都，居然不能这里设置
        try database.create("posts", closure: { (post) in
            post.id()
            post.string("title")
            post.string("content")
            post.int("author_id")
            post.string("html")
        })
    }
    
    // this will be run if vapor run prepare --revert is called.
    static func revert(_ database: Database) throws {
        try database.delete("posts")
    }
}
