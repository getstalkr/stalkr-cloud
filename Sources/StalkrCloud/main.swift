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
try Role.prepare(db)
try RoleAssignment.prepare(db)
try Post.prepare(db)

try User(name: "admin", password: "123456").save()
try User.withName("admin")?.assign(role: try Role.withName("user")!)
try User.withName("admin")?.assign(role: try Role.withName("admin")!)

let auth = (
    user: AuthMiddleware(roleNames: ["user"]),
    admin: AuthMiddleware(roleNames: ["admin"])
)

drop.group("user") { user in
    let controller = UserController()
    
    user.post("register", handler: controller.register)
    user.post("login", handler: controller.login)
    
    user.group(auth.user) { authUser in
        authUser.post("jointeam", handler: controller.jointeam)
    }
}

drop.group("token") { token in
    
    let controller = TokenController()
    
    token.post("generate", handler: controller.generate)
}

drop.group("team") { team in
    
    let controller = TeamController()
    
    team.group(auth.user) { authTeam in
        authTeam.post("create", handler: controller.create)
    }
    
    team.get("memberships", handler: controller.memberships)
}

drop.group("role") { role in
    
    let controller = RoleController()
    
    role.get("roles", handler: controller.roles)
    role.get("assignments", handler: controller.assignments)
    
    role.group(auth.admin) { authAdmin in
        authAdmin.post("assign", handler: controller.assign)
    }
}
drop.resource("posts", PostController())

try drop.run()
