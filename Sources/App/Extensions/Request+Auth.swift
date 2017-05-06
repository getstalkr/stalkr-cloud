//
//  Request+Auth.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/6/17.
//
//

import HTTP
import Foundation

extension Request {
    
    var user: User? {
        get { return storage["user"] as? User }
        set { return storage["user"] = newValue }
    }
}
