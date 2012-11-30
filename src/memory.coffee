
class Memory
  constructor: () -> @data = {}
  created: (cb) -> cb null, true
  create: (cb) -> cb null
  remove: (cb) -> @data = {}; cb null
  write: (path, data, cb) -> @data[path] = data; cb null
  read: (path, cb) -> cb null, @data[path]
  remove: (path, cb) -> delete @data[path]; cb null
  keys: (cb) -> cb null, Object.keys @data

module.exports = Memory