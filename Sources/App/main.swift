import Vapor
import Fluent

let drop = Droplet()

drop.get { req in
  return try drop.view.make("welcome", [
    "message": drop.localization[req.lang, "welcome", "title"]
  ])
}

drop.database = Database(MemoryDriver())

User.database = drop.database
Post.database = drop.database

drop.group("user") { user in
  let controller = UserController()

  user.post("add", handler: controller.add)
  user.get("get", handler: controller.get)
}

drop.resource("posts", PostController())

drop.run()
