import Vapor
import VaporMySQL

let drop = Droplet()

try drop.addProvider(VaporMySQL.Provider.self)
drop.preparations += Post.self
drop.preparations += Author.self
drop.preparations += Category.self
drop.preparations += Acronym.self

// 关闭页面缓存
(drop.view as? LeafRenderer)?.stem.cache = nil

// 也可以一个路由一个 App,如果是 blog , 建立一个 Blog 的项目，就用
// Blog 这个类来分发这个 VC 就好
let acronymController = AcronymController(droplet: drop)
let blogController = BlogController(droplet: drop)

drop.run()
