//
//  File.swift
//  spider
//
//  Created by laijihua on 18/12/2016.
//
//

import Leaf
import cmark_swift

final class Markdown: BasicTag {
    
    let name = "markdown"

    func run(arguments: [Argument]) throws -> Node? {

        guard let content = arguments[0].value?.string else {
            return nil
        }

        let html = try markdownToHTML(content)

        return .string(html)
    }


}


