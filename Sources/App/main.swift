import Vapor
import Fluent
import VaporPostgreSQL
import Sessions

let drop = Droplet()

try drop.addProvider(VaporPostgreSQL.Provider.self)
drop.preparations += Post.self
drop.preparations += Author.self
drop.preparations += Category.self
drop.preparations += Acronym.self
drop.preparations += Pivot<Post, Category>.self // 多对多
drop.preparations += Session.self
drop.preparations += Pivot<Author,Session>.self

let memory = MemorySessions()
let sessions = SessionsMiddleware(sessions: memory)
drop.middleware.append(sessions)

// 关闭页面缓存
(drop.view as? LeafRenderer)?.stem.cache = nil

// register markdown tag: #markdown(content)
(drop.view as? LeafRenderer)?.stem.register(Markdown())

let indexController = IndexController(droplet: drop)
// 也可以一个路由一个 App,如果是 blog , 建立一个 Blog 的项目，就用
// Blog 这个类来分发这个 VC 就好
let blogController = BlogController(droplet: drop)
let authorController = AuthorController(droplet: drop)
let categoryController = CategoryController(droplet: drop)

// 接口 API
let apiController = ApiController(droplet: drop)

drop.run()
