# Vapor + Docker(git) 

## 环境：

```
Docker version 1.12.1, build 6f9534c
Apple Swift version 3.0 (swiftlang-800.0.46.2 clang-800.0.38)
vap
```

这是个练手的项目，使用 Docker 技术进行环境分离， 采用了 `kitura-ubanutu` 镜像，搭建swift后台环境

## Docker 镜像安装

```sh 
docker pull ibmcom/kitura-ubuntu:latest
```

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

## 待解决问题

在文章首页中，如何显示 markdown 文本， 思路如下：

`Leaf` 现已实现 `raw` 这个 tag 的实现，我们可以自定义个 `markdown` 且参考 raw 的实现来封装这个 tag.

任务计划完成时间: 2016.12.19 晚
