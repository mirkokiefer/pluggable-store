
class PluggableStore
  constructor: ({@adapter, @adapterIsSync}) ->
  write: (key, value, cb) ->
    if @adapterIsSync
      res = @adapter.write key, value
      if cb then cb null, res else res
    else @adapter.write key, value, cb
  read: (key, cb) ->
    if @adapterIsSync
      res = @adapter.read key
      if cb then cb null, res else res
    else @adapter.read key, cb
  remove: (key, cb) -> @adapter.remove key, cb

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
