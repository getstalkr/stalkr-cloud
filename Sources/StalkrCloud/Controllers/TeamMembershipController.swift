//
//  TeamMembershipController.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/16/17.
//
//

import HTTP
import Vapor
import Foundation

class TeamMembershipController {
    
    let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func addRoutes() {
        drop.group("teammembership") {
            $0.group(AuthMiddleware.user) {
                $0.post("create", handler: create)
            }
            
            $0.get ("get", handler: get)
        }
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        guard let _userid = request.headers["userid"]?.uint else {
            throw Abort(Status.badRequest, metadata: "missing userid")
        }
        
        guard let _teamid = request.headers["teamid"]?.uint else {
            throw Abort(Status.badRequest, metadata: "missing teamid")
        }
        
        guard let team   = try Team.find(_teamid),
              let teamid = team.id else {
            throw Abort(Status.badRequest, metadata: "team not found")
        }
        
        guard let user   = try User.find(_userid),
              let userid = user.id else {
            throw Abort(Status.badRequest, metadata: "user not found")
        }
        
        if try TeamMembership.first(with: [("teamid", teamid),
                                           ("userid", userid)]) != nil {
            throw Abort(Status.badRequest, metadata: "team membership already exists")
        }
        
        try TeamMembershipBuilder.build {
            $0.teamid = teamid
            $0.userid = userid
        }?.save()
        
        return JSON(["success": true])
    }
    
    func get(request: Request) throws -> ResponseRepresentable {

        var query = try TeamMembership.makeQuery()
        
        if let _userid = request.headers["userid"]?.uint,
           let  userid = try User.find(_userid)?.id {
            query = try query.filter([("userid", userid)])
        }
        
        if let _teamid = request.headers["teamid"]?.uint,
           let  teamid = try Team.find(_teamid)?.id {
            query = try query.filter([("teamid", teamid)])
        }

        return try query.all().makeJSON()
    }
}
