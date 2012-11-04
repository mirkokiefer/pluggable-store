
{server} = require '../lib/index'
assert = require 'assert'

store = server().memory()

assertEvent = (emitter, [event, expectedArgs], cb) ->
  emitter.on event, (args...) ->
    for each, i in expectedArgs
      assert.equal args[i], each
    cb()

assertEventsSerial = (emitter, events, cb) ->
  if events.length == 0 then cb()
  else
    [first, rest...] = events
    assertEvent emitter, first, -> assertEventsSerial emitter, rest, cb

describe 'PluggableStore using Memory adapter', () ->
  describe 'read/write', () ->
    it 'should write and read an object sync', () ->
      store.write 'path1', 'value1'
      assert.equal store.read('path1'), 'value1'
    it 'should write and read an object async', (done) ->
      store.write 'path2', 'value2', () ->
        store.read 'path2', (err, res) ->
          assert.equal res, 'value2'
          done()
  describe 'events', ->
    it 'should trigger write event on write', (done) ->
      assertEventsSerial store, [
        ['write', ['path3', 'value3']]
        ['written', ['path3', 'value3']]
      ], done
      store.write 'path3', 'value3'
    it 'should trigger read event on read', (done) ->
      assertEvent store, ['read', ['path3']], done
      store.read 'path3'