
class Memory
  constructor: () -> @data = {}
  write: (path, data) -> @data[path] = data
  read: (path) -> @data[path]
  remove: (path) -> delete @data[path]

module.exports = Memory