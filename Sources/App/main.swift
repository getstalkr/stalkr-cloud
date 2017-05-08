import Vapor
import FluentProvider
import JWT

let drop = try Droplet()

let db = Database(try MemoryDriver())

User.database = db
Team.database = db
TeamMembership.database = db
Post.database = db

try User.prepare(db)
try Team.prepare(db)
try TeamMembership.prepare(db)
try Post.prepare(db)

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

try drop.run()
