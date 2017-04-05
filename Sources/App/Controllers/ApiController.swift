//
//  ApiController.swift
//  spider
//
//  Created by laijihua on 28/03/2017.
//
//

import Foundation
import Vapor
import HTTP

let EmptyString = ""

final class ApiController : BaseController {

    override func addRouters() {
        let v1 = drop.grouped("api/v1")
        // 返回字符串
        v1.get("/") { (request) -> ResponseRepresentable in
            return "Hellow, world"
        }

        v1.get("user", handler: userIndex)
    }

    // 返回 JSON
    func userIndex(request: Request) throws -> ResponseRepresentable {
        let name = request.data["name"]?.string ?? EmptyString
        return try JSON(node: [
            "version":"1.0",
            "name":name
            ])
    }


}
