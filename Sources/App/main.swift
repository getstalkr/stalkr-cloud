import Vapor
import FluentProvider
import JWT
import StalkrCloud

let config = try Config()
try config.setup()

let drop = try Droplet(config)

try drop.run()
