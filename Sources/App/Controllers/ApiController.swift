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
import Hash
import Fluent

let EmptyString = ""



// 现在我们使用同一的 Secret 和 Key
// 按照常理来说，这些都是通过用户申请后来的，每个请求都携带 Key, 通过 key 来判断是否有 api 的访问权限，并且查询到 secret.
// 签名算法

//            对除app_key以外的所有请求参数进行字典升序排列
//            将以上排序后的参数表进行字符串连接，如key1value1key2value2key3value3…keyNvalueN
//            将app_key、app_secret、timestamp依次添加到字符串末尾
//            用app_secret作为秘钥，对该字符串进行hmac_sha1计算并输出hex字符串即为签名
let SessionSecret = "9XNNXe66zOlSassjSKD5gry9BiN61IUEi8IpJmjBwvU07RXP0J3c4GnhZR3GKhMHa1A="

let SessionKey = "siteoheroj"

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

        let verfi = v1.grouped(VerifyMiddleware())
        let userGroup = verfi.grouped("user")
        userGroup.post("login", handler: login)
        userGroup.post("register",handler: register)

    }





    func register(request: Request) throws -> ResponseRepresentable {

        guard let email = request.data["email"]?.string else {
            return try returnErrJson(code: 1, message:"邮箱为空")
        }

        guard let name = request.data["name"]?.string else {
            return try returnErrJson(code: 2, message: "名字为空")
        }

        guard let password = request.data["password"]?.string else {
            return try returnErrJson(code: 3, message:"密码为空")
        }

        if let _ = try Author.query().filter("email", contains:email).first()  {
            return try returnErrJson(code: 4, message: "用户已存在")
        }

        var user = Author(name: name, email: email, github: nil, password: password)
        try user.save()

        let ret = try ["user": user].makeNode()
        return try returnSucJson(data: ret)
    }


    /// 用户登入
    func login(request: Request) throws -> ResponseRepresentable {
        guard let email = request.data["email"]?.string else {
            return try returnErrJson(code: 1, message:"邮箱为空")
        }

        guard let password = request.data["password"]?.string else {
            return try returnErrJson(code: 2, message:"密码为空")
        }

        guard let author = try Author.query().filter("email", contains:email).first() else {
            return try returnErrJson(code: 3, message: "用户不存在")
        }

        if author.password.equals(any: password) { // 用户登入成功

            guard let author_id = author.id else {
                return  try returnErrJson(code: 5, message: "该用户账号 id 不正确")
            }

            // 生成 AccessToken
            // MD5(userid+pwd+time)
            var nowTime = String(Date().timeIntervalSince1970)
            let accessToken = try drop.hash.make(email+password+nowTime)
            nowTime = String(Date().timeIntervalSince1970)
            let refreshToken = try drop.hash.make(email + nowTime)

            // 将旧的删除, 为什么没数据？？？
//            print(try Session.all().makeNode())
//            print(try Pivot<Author, Session>.all().makeNode())
            try Session.query().filter("author_id", author_id).first()?.delete()
            try Pivot<Author, Session>.query().filter("author_id", author_id).first()?.delete()

            var session = Session(accessToken: accessToken, refreshToken: refreshToken, author_id: author_id)
            try session.save()

            var pivot = Pivot<Author, Session>(author, session)
            try pivot.save()

            let ret = try ["accessToken": accessToken,
                       "refreshToken":refreshToken,
                       "user": author].makeNode()
            // 用户登入，返回用户信息
            return try returnSucJson(data: ret)

        } else {
            return try returnErrJson(code: 4, message: "密码错误")
        }
    }

    // MARK: 下面这些可以放到一个公共类中
    // 返回错误码信息
    func returnErrJson(code: Int, message:String) throws -> JSON {
        return try returnJson(code: code, message: message, data:[:].makeNode())
    }

    /// 返回正确的数据
    func returnSucJson(data: Node) throws -> JSON {
        return try returnJson(code: 0, data: data)
    }

    // 统一返回的接口格式
    func returnJson(code: Int, message: String = "success", data: Node) throws -> JSON {
        return try JSON(node: [
            "data": data,
            "code": code,
            "message": message
        ])
    }
}

final class VerifyMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        if verify(request: request) { // 验证数据是否被篡改
            return try next.respond(to: request)
        } else {
            throw Abort.custom(
                status: .badRequest,
                message: "Sorry, 你传输的数据不安全!!!数据签名失败"
            )
        }
    }

    func verify(node: Node?, sign: String = "") -> String {
        guard let node = node else {
            return ""
        }
        var optStr = sign
        switch node {
        case let .array(tmps):
            tmps.forEach({ (no) in
                optStr += verify(node: no)
            })
        case let .object(obj):
            // 升序
            let tmp = obj.sorted(by: { (t1, t2) -> Bool in
                return t1.0 < t2.0
            })
            tmp.forEach({ (op) in
                optStr += op.key + "=" + verify(node: op.value) + "&"
            })
        case let .string(str):
            optStr += str

        case let .number(num):
            optStr += "\(num)"

        default: // 其他待处理
            optStr += ""
        }
        do {
            let retStr = try drop.hash.make(optStr + SessionKey, key: SessionSecret)
            return retStr
        } catch {
            return ""
        }
    }

    func verify(request: Request) -> Bool {
        guard let query = request.query else {
            return false
        }
        let sign = verify(node: query)
        if let rsign = request.data["sign"]?.string {
            if rsign == sign {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
}
