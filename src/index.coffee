
class PluggableStore extends require('eventemitter2').EventEmitter2
  constructor: ({@adapter, @adapterIsSync}) ->
  write: (key, value, cb) ->
    obj = this
    written = -> obj.emit 'written', key, value
    @emit 'write', key, value
    if @adapterIsSync
      res = @adapter.write key, value
      written()
      if cb then cb null, res else res
    else @adapter.write key, value, (err, res) ->
      written()
      cb err, res
  read: (key, cb) ->
    @emit 'read', key
    if @adapterIsSync
      res = @adapter.read key
      if cb then cb null, res else res
    else @adapter.read key, cb
  remove: (key, cb) -> @adapter.remove key, cb

pipe = (fromStore, toStore) ->
  fromStore.on 'write', (key, value) -> toStore.write key, value

wrapAdapter = (path, isSync) ->
  (args...) ->
    adapter = require path
    new PluggableStore adapter: new adapter(args...), adapterIsSync: isSync

module.exports =
  PluggableStore: PluggableStore
  browser: () ->
    localStorage: wrapAdapter('./localstore', true)
    memory: wrapAdapter('./memory', true)
  server: () ->
    fileSystem: wrapAdapter('./filesystem')
    memory: wrapAdapter('./memory', true)
  pipe: pipe