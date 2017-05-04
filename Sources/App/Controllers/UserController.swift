//
//  UserController.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/4/17.
//
//

import HTTP
import Vapor
import Foundation

class UserController {

  func add(request: Request) throws -> ResponseRepresentable {

    guard let name = request.data["user"]?.string else {
      throw Abort.custom(status: Status.badRequest, message: "Missing username or password")
    }

    var user = User(name: name)

    try user.save()

    return try JSON(node: ["success": true])
  }
    
    func get(request: Request) throws -> ResponseRepresentable {
        
        return try JSON(node: User.all())
    }
}
