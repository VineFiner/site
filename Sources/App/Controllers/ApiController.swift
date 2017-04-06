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

// 接口类
// 返回的数据结构
//
//{
//    code：0,
//    message: "success",
//    data: { key1: value1, key2: value2, ... }
//}


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
            "name":name,
            "message": "api/v1"
            ])
    }


}
