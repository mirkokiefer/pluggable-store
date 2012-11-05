
class PluggableStore extends require('eventemitter2').EventEmitter2
  constructor: ({@adapter, @isSync}) ->
  write: (key, value, cb) ->
    obj = this
    written = -> obj.emit 'written', key, value
    @emit 'write', key, value
    if @isSync
      res = @adapter.write key, value
      written()
      if cb then cb null, res else res
    else @adapter.write key, value, (err, res) ->
      written()
      cb err, res
  read: (key, cb) ->
    @emit 'read', key
    if @isSync
      res = @adapter.read key
      if cb then cb null, res else res
    else @adapter.read key, cb
  remove: (key, cb) -> @adapter.remove key, cb
  readAll: (keys, cb) ->
    if @isSync
      res = (@read each for each in keys)
      if cb then cb null, res else res
    else
      obj = this
      async.map keys, ((each, cb) -> obj.read each, cb), cb
  writeAll: (keyValues, cb) ->
    if @isSync
      res = (@write key, value for {key, value} in keyValues)
      if cb then cb null, res else res
    else
      obj = this
      async.map keyValues, (({key, value}, cb) -> obj.write key, value, cb), cb
  removeAll: (keys, cb) ->
    if @isSync
      res = (@remove each for each in keys)
      if cb then cb null, res else res
    else
      obj = this
      async.map keys, ((each, cb) -> obj.remove each, cb), cb

pipe = (fromStore, toStore) ->
  fromStore.on 'write', (key, value) -> toStore.write key, value

wrapAdapter = (path, isSync) ->
  (args...) ->
    adapter = require path
    new PluggableStore adapter: new adapter(args...), isSync: isSync

module.exports =
  PluggableStore: PluggableStore
  browser: () ->
    localStorage: wrapAdapter('./localstore', true)
    memory: wrapAdapter('./memory', true)
  server: () ->
    fileSystem: wrapAdapter('./filesystem')
    memory: wrapAdapter('./memory', true)
  pipe: pipe