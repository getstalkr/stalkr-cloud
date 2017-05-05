import Vapor
import Fluent
import JWT

let drop = Droplet()

drop.get { req in
    return try drop.view.make("welcome", [
        "message": drop.localization[req.lang, "welcome", "title"]
        ])
}

let db = Database(MemoryDriver())

User.database = db
Post.database = db

drop.group("user") { user in
    let controller = UserController()
    
    user.post("register", handler: controller.register)
}

drop.group("token") { token in
    
    let controller = TokenController()
    
    token.post("generate", handler: controller.generate)
}

drop.resource("posts", PostController())

drop.run()
