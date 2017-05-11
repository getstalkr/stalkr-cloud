import Vapor
import FluentProvider
import JWT
import StalkrCloud

let config = try Config()

try config.addProvider(FluentProvider.Provider.self)
try config.addProvider(StalkrCloud.Provider.self)

let drop = try Droplet(config)

try drop.run()
