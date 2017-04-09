

# A Blog Site step by step

[toc]

 **前提知识**：

 [Vapor社区文档](https://vapor.github.io/documentation/)


## 访问站点 [->](https://spider-site.herokuapp.com/blog/)

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

### Flexbox layout

[flexbox 布局知识要点](http://www.ruanyifeng.com/blog/2015/07/flex-grammar.html)

## 部署 Heroku 

在部署 Heroku 的时候，有这么些过程：

* 首先把之前的 `mysql`替换成 `postgresql` ,替换的目的是 `heroku` 有提供 200M 的`postgresql` 免费空间，这样就不需要买数据库了。

```swift
let package = Package(
    name: "spider",
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor:1),
//        .Package(url: "https://github.com/vapor/mysql-provider.git", majorVersion: 1, minor: 1),
        .Package(url: "https://github.com/czechboy0/cmark.swift.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/vapor/postgresql-provider.git", majorVersion: 1, minor: 1),
    ]
)
```

* 搭建本地的 `postgresql` 环境:

* 安装 `postgresql`

```sh
brew install postgresql
brew link postgresql
brew services start postgresql # 开启 postgresql 服务
brew services stop postgresql # 关闭 postgresql服务
```
其终端命令可以参考文尾章节`Postgresql常用命令`

* 运行配置 `Config/secrets/postgresql.json`

```json
{
    "host": "127.0.0.1",
    "user": "postgres",
    "password": "",
    "database": "test",
    "port": "5432"
}
```

>注意： `port` 最好为String, 之前有试过用 Int 会崩溃 

* 替换 `Provider`, 其余逻辑不变

```swift
//...
import VaporPostgreSQL

let drop = Droplet()

try drop.addProvider(VaporPostgreSQL.Provider.self)
//...
```

* 部署到 heroku 的时候，要保证两点
    * .gitignore 要进行对 `Config/secrets` 进行忽略，因为如果部署上去的话，相关配置会读取这里的配置，而这个配置只试用于本地
    * 配置 `Procfile` 文件，主要是配置端口和数据库

~~~
// Profile
web: App --env=production --workdir=./ --config:servers.default.port=$PORT --config:postgresql.url=$DATABASE_URL
~~~

> `$PORT` 这个值不要理睬，肯定可以接收到
> `$DATABASE_URL` 该值需要配置，如果你是根据视频中配置的，那么这个值你就按照视频中的来，不然请看后续步骤


* 如果你之前没有用过 Heroku , 那么你可以参考 [这里](https://github.com/vapor/example#heroku) or [视屏](https://videos.raywenderlich.com/screencasts/server-side-swift-with-vapor-deploying-to-heroku-with-postgresql)

* 如果你在线上有 heroku 数据库，那么你该这么用这个项目使用已有的数据库. `$DATABASE_URL` 到底是什么？ 





## Vapor + Docker(git) 

### 环境：

```
Docker version 1.12.1, build 6f9534c
Apple Swift version 3.0 (swiftlang-800.0.46.2 clang-800.0.38)
vap
```

这是个练手的项目，使用 Docker 技术进行环境分离， 采用了 `kitura-ubanutu` 镜像，搭建swift后台环境

### Docker 镜像安装

```sh 
docker pull ibmcom/kitura-ubuntu:latest
```

## 现实现功能

文章的 增 删 改 查
已可在线上访问

## 待解决问题

完善页面，美化文章列表 和 文章详情页
如果时间允许，添加 分类编辑逻辑

可能会遇到的难点：

markdown 文本不应该存放为 文本内容，应该是上传为 一个 md 文件
所以需要添加一个文件上传功能，返回一个 url

需要准备用户权限问题

sketch 设计出简要的 ui 设计稿！

用户的相关逻辑，文章暂时不支持 category 的

先将 UI 进行调整。 然后完成文章编辑样式， 用户登入登出逻辑

--------

## 辅助知识

### Postgresql 常用命令：

* 初始化数据库

```
initdb /usr/local/var/postgres -E utf8
```

上面指定 “/usr/local/var/postgres” 为 PostgreSQL 的配置数据存放目录，并且设置数据库数据编码是 utf8，更多配置信息可以 “initdb –help” 查看。

* 设置开机启动 Postgresql

```
ln -sfv /usr/local/opt/postgresql/*.plist ~/Library/LaunchAgents
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist
```

* 启动 postgresql

```
pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start
```

* 关闭

```
pg_ctl -D /usr/local/var/postgres stop -s -m fast
```

* 创建一个 PostgreSQL 用户

```
createuser username -P
#Enter password for new role
#Enter it again
```

上面的 username 是用户名，回车输入 2 次用户密码后即用户创建完成。更多用户创建信息可以 `createuser –help` 查看。

* 创建数据库

```
createdb dbname -O username -E UTF8 -e
```

上面创建了一个名为 dbname 的数据库，并指定 username 为改数据库的拥有者（owner），数据库的编码（encoding）是 UTF8，参数 “-e” 是指把数据库执行操作的命令显示出来。

* 连接数据库

```
psql -U username -d dbname -h 127.0.0.1
```

**数据库操作**

* 显示已创建的数据库

```sh
\l
```

在不连接进 PostgreSQL 数据库的情况下，也可以在终端上查看显示已创建的列表：
`psql -l`

* 连接数据库

```sh
\c dbname
```

* 显示数据库

```sh
\d
```

* 创建一个 test 表

```sh
CREATE TABLE test (id int, text VARCHAR(50));
```

* 插入一条记录

```sh
INSERT INTO test(id, text) VALUES(1, 'test');
```

* 查询数据

```sh
SELECT * FROM test WHERE id = 1;
```

* 更新记录：

```sh
UPDATE test SET text = 'aaaaaaaaaaaaa' WHERE id = 1;
```

* 删除指定的记录

```sh
DELETE FROM test WHERE id = 1;
```

* 删除表：

```sh
DROP TABLE test;
```

* 删除数据库：

```sh
DROP DATABASE dbname;
```

* 或者利用dropdb指令，在终端上删除数据库：

```sh
dropdb -U user dbname
```


## API 接口设计

### JSON 的格式的数据传输

* Number：整数或浮点数
* String：字符串
* Boolean：true 或 false
* Array：数组包含在方括号[]中
* Object：对象包含在大括号{}中
* Null：空类型

### 数据返回的数据结构约定

```
{
    code：0,
    message: "success",
    data: { key1: value1, key2: value2, ... }
}
```
* code: 返回码， 0 表示成功， 非0表示各种不同的数据
* message: 描述信息， 成功时返回“success”, 错误时则是错误信息
* data: 成功时返回的数据，类型为对象或数组

不同错误需要定义不同的返回码，属于客户端的错误和服务端的错误也要区分，比如1XX表示客户端的错误，2XX表示服务端的错误。example:

* 0：成功
* 100：请求错误
* 101：缺少appKey
* 102：缺少签名
* 103：缺少参数xx
* 200：服务器出错
* 201：服务不可用
* 202：服务器正在重启

### 接口版本的设计

* 数据的变化，比如增加了旧版本不支持的数据类型
* 参数的变化，比如新增了参数
* 接口的废弃，不在使用该接口了

为了适应这些变化，必须得做接口版本的设计。

1. 每个接口有各自的版本，一般为接口添加个 version 的参数
2. 整个接口系统有统一的版本，一般在 URL 中添加版本号，比如 http://api.domain.com/v2

大部分情况下会采用第一种方式，当某一个接口有变动时，在这个接口上叠加版本号，并兼容旧版本。App的新版本开发传参时则将传入新版本的 version。

要有一套完善的测试机制保证每次接口变更都能测试到所有相关层面


#### URL 签名算法

URL 签名是将请求参数串以及 APP 秘钥根据一定的签名算法生成的签名值，作为新的请求参数 
以提高访问过程中的防篡改性。

* 对除app_key以外的所有请求参数进行字典升序排列
* 将以上排序后的参数表进行字符串连接，如key1value1key2value2key3value3…keyNvalueN
将app_key、app_secret、timestamp依次添加到字符串末尾
用app_secret作为秘钥，对该字符串进行hmac_sha1计算并输出hex字符串即为签名

* 签名串获得后，将其作为sign参数附加到对应的URL中。

#### 基于 Token 的身份验证方法

* 客户端使用用户名跟密码请求登录
* 服务端收到请求，去验证用户名与密码
* 验证成功后，服务端会签发一个 Token，再把这个 Token 发送给客户端
* 客户端收到 Token 以后可以把它存储起来，比如放在 Cookie 里或者 Local Storage 里
* 客户端每次向服务端请求资源的时候需要带着服务端签发的 Token
* 服务端收到请求，然后去验证客户端请求里面带着的 Token，如果验证成功，就向客户端返回请求的数据








