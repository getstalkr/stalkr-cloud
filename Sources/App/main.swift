import Vapor
import Fluent

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

  user.post("add", handler: controller.add)
  user.get("get", handler: controller.get)
}

drop.resource("posts", PostController())

drop.run()
