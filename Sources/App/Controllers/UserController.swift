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
    
    /*func add(request: Request) throws -> ResponseRepresentable {
        
        guard let name = request.data["user"]?.string else {
            throw Abort.custom(status: Status.badRequest, message: "Missing username or password")
        }
        
        var user = User(name: name)
        
        try user.save()
        
        return try JSON(node: ["success": true])
    }
    
    func get(request: Request) throws -> ResponseRepresentable {
        
        return try JSON(node: User.all())
    }*/
    
    func register(request: Request) throws -> ResponseRepresentable {
        
        guard let username = request.data["username"]?.string else {
            throw Abort.custom(status: Status.badRequest, message: "Missing username or password")
        }
        
        guard let password = request.data["password"]?.string else {
            throw Abort.custom(status: Status.badRequest, message: "Missing username or password")
        }
        
        if let _ = try User.query().filter("username", username).first() {
            throw Abort.custom(status: Status.badRequest, message: "Username already in use")
        }
        
        var user = User(name: username, password: password)
        
        try user.save()
        
        return try JSON(node: ["success": true])
    }
    
    func login(request: Request) throws -> ResponseRepresentable {
        
        guard let username = request.data["username"]?.string else {
            throw Abort.custom(status: Status.badRequest, message: "Missing username or password")
        }
        
        guard let password = request.data["password"]?.string else {
            throw Abort.custom(status: Status.badRequest, message: "Missing username or password")
        }
        
        guard let user = try User.query().filter("username", username).filter("password", password).first() else {
            throw Abort.custom(status: Status.badRequest, message: "Wrong username or password")
        }
        
        return try JSON(node: ["success": true, "user": user.makeNode()])
    }
}
