

# A Blog Site step by step

[toc]

 **前提知识**：

 [Vapor社区文档](https://vapor.github.io/documentation/)

## Model

* 博客 **Post**
* 分类 **Category**
* 作者 **Author**

| Model         | Releation | Vapor Releation |
|---------------|-----------|-----------------|
| Post-Author   | one-one   | Children(Parent)|
| Post-Category | many-many | Silbing         |


如何构建表间关系，-> [Vapor Relation](https://vapor.github.io/documentation/fluent/relation.html) 。

> 注： vapor 未提供数据库的其他 commond? 每次给表添加字段或者删除字段，how do?


## Controller:

将功能相关的 Router 放到一个控制器中进行管理， 因为每个控制器都需依赖 Droplet 这个实例，由于 这个实例是全局的，但是为了类的完备性和封装性，还是添加一个属性，故造就一个 BaseController 用于子类继承。

```swift
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
```

子类实现如下 ： 

```swift
final class BlogController : BaseController {

    override func addRouters() {
        let group = drop.grouped("blog")
        group.get("/", handler: indexView) // index
        group.post("/",handler: addPost)  // add
        group.get(Post.self, handler: postDetail)
        group.post(Post.self, "delete", handler: deletePost) //delete
        group.get("create", handler: createPost) // create 页面
    }

    func postDetail(request: Request, post: Post) throws -> ResponseRepresentable {
        let content = post.content
        let params = ["content": content]
        return try drop.view.make("blog/detail", params)
    }

    func createPost(request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("blog/create")
    }

    func deletePost(request: Request, post:Post) throws -> ResponseRepresentable {

        try post.delete()
        return Response(redirect: "/blog")
    }

    func addPost(request: Request) throws -> ResponseRepresentable {
        guard let title = request.data["title"]?.string,
            let content = request.data["content"]?.string,
        let category = request.data["category"]?.string else {
            throw Abort.badRequest
        }
        var post = Post(desc: content, title: title, content: content, category: category)
        try post.save()
        return Response(redirect: "/blog")
    }

    func indexView(request: Request) throws -> ResponseRepresentable {
        let posts = try Post.all().makeNode()
        let parameters = try Node(node: ["posts": posts])
        return try drop.view.make("blog/index", parameters);
    }
}
```

## View(Leaf)

* base.leaf 提供类似基类功能
* 在 main.swift 使用如下代码进行关闭页面缓存，改变 `leaf` 文件不需要要重新编译也可刷新到最新

```swift
// 关闭页面缓存
(drop.view as? LeafRenderer)?.stem.cache = nil
```

### suport markdown tag

思路来源于 `leaf` 内部的 `#raw()` 的实现。

```swift
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
```

`markdownToHTML` 依赖下面这个库提供：

```
.Package(url: "https://github.com/czechboy0/cmark.swift.git", majorVersion: 0, minor: 1)
```

在 `main.swift` 中注册这个类。

```
// register markdown tag: #markdown(content)
(drop.view as? LeafRenderer)?.stem.register(Markdown())
```

## 部署 Heroku （待做）

### 使用 PostgreSQL

### Vapor + Docker(git) 

#### 环境：

```
Docker version 1.12.1, build 6f9534c
Apple Swift version 3.0 (swiftlang-800.0.46.2 clang-800.0.38)
vap
```

这是个练手的项目，使用 Docker 技术进行环境分离， 采用了 `kitura-ubanutu` 镜像，搭建swift后台环境

#### Docker 镜像安装

```sh 
docker pull ibmcom/kitura-ubuntu:latest
```

## 现实现功能

文章的 增 删 改 查


## 待解决问题

完善页面，美化文章列表 和 文章详情页
如果时间允许，添加 分类编辑逻辑

可能会遇到的难点：

markdown 文本不应该存放为 文本内容，应该是上传为 一个 md 文件
所以需要添加一个文件上传功能，返回一个 url

需要准备用户权限问题

部署到 heroku 上

sketch 设计出简要的 ui 设计稿！





