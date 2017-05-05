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
Team.database = db
TeamMembership.database = db
Post.database = db

drop.group("user") { user in
    let controller = UserController()
    
    user.post("register", handler: controller.register)
    user.post("login", handler: controller.login)
    user.post("jointeam", handler: controller.jointeam)
}

drop.group("token") { token in
    
    let controller = TokenController()
    
    token.post("generate", handler: controller.generate)
}

drop.group("team") { token in
    
    let controller = TeamController()
    
    token.post("create", handler: controller.create)
    
    token.get("list", handler: controller.list)
}

drop.resource("posts", PostController())

drop.run()
