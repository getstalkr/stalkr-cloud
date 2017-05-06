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

let mws = (
    auth: AuthMiddleware(),
    date: DateMiddleware()
)

drop.group("user") { user in
    let controller = UserController()
    
    user.post("register", handler: controller.register)
    user.post("login", handler: controller.login)
    
    user.group(mws.auth) { authUser in
        authUser.post("jointeam", handler: controller.jointeam)
    }
}

drop.group("token") { token in
    
    let controller = TokenController()
    
    token.post("generate", handler: controller.generate)
}

drop.group("team") { team in
    
    let controller = TeamController()
    
    team.group(mws.auth) { authTeam in
        authTeam.post("create", handler: controller.create)
    }
    
    team.get("memberships", handler: controller.memberships)
}

drop.resource("posts", PostController())

drop.run()
