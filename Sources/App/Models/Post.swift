import Vapor
import Fluent
import Foundation

final class Blog: Model {
    var id: Node?
    var desc: String
    var title: String
    var url: String
    var thumb: String
    var category: String
    
    init(desc:String, title:String,url:String, thumb: String, category:String ) {
        self.desc = desc
        self.title = title
        self.url = url
        self.thumb = thumb
        self.category = category
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        desc = try node.extract("desc")
        title = try node.extract("title")
        url = try node.extract("url")
        thumb = try node.extract("thumb")
        category = try node.extract("category")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "desc": desc,
            "title": title,
            "url": url,
            "thumb": thumb,
            "category": category,
        ])
    }
}

extension Blog: Preparation {
    static func prepare(_ database: Database) throws {
        // 无语了都，居然不能这里设置blogs
        try database.create("blogs", closure: { (post) in
            post.id()
            post.string("title")
            post.string("desc")
            post.string("url")
            post.string("thumb")
            post.string("category")
        })
    }

    static func revert(_ database: Database) throws {
        try database.delete("blogs")
    }
}
