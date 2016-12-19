//
//  File.swift
//  spider
//
//  Created by laijihua on 18/12/2016.
//
//

import Leaf
import cmark_swift

extension Leaf {

}

final class Markdown: Tag {
    
    let name = "markdown"

    func run(stem: Stem, context: Context, tagTemplate: TagTemplate, arguments: [Argument]) throws -> Node? {
        guard let string = arguments.first?.value?.string else { return nil }
        let html = try markdownToHTML(string)
        let unescaped = html.bytes
        return .bytes(unescaped)
    }

    func shouldRender(stem: Stem, context: Context, tagTemplate: TagTemplate, arguments: [Argument], value: Node?) -> Bool {
        return true
    }
}


