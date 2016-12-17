//
//  BaseController.swift
//  spider
//
//  Created by laijihua on 17/12/2016.
//
//

import HTTP
import Vapor

// 基类
class BaseController {
    let drop: Droplet

    init(droplet: Droplet) {
        drop = droplet
        addRouters()
    }

    // to sub vc ovviride
    func addRouters(){

    }
}
