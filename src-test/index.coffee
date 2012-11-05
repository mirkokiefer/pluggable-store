
{server, pipe} = require '../lib/index'
assert = require 'assert'
createMemoryStore = server().memory

assertEvent = (emitter, [event, expectedArgs], cb) ->
  emitter.once event, (args...) ->
    for each, i in expectedArgs
      assert.equal args[i], each
    cb()

assertEventsSerial = (emitter, events, cb) ->
  if events.length == 0 then cb()
  else
    [first, rest...] = events
    assertEvent emitter, first, -> assertEventsSerial emitter, rest, cb

store1 = null

beforeEach -> store1 = createMemoryStore()

describe 'PluggableStore using Memory adapter', () ->
  describe 'read/write', () ->
    it 'should write and read an object sync', () ->
      store1.write 'key1', 'value1'
      assert.equal store1.read('key1'), 'value1'
    it 'should write and read an object async', (done) ->
      store1.write 'key2', 'value2', () ->
        store1.read 'key2', (err, res) ->
          assert.equal res, 'value2'
          done()
    it 'should write and read multiple objects', ->
      data = [{key: 'mult1', value: 'multval1'}, {key: 'mult2', value: 'multval2'}]
      store1.writeAll data
      assert.equal store1.read('mult1'), 'multval1'
      assert.equal store1.read('mult2'), 'multval2'
    it 'should write and read multiple objects async', (done) ->
      data = [{key: 'mult1', value: 'multval1'}, {key: 'mult2', value: 'multval2'}]
      store1.writeAll data, ->
        store1.read 'mult1', (err, res) ->
          assert.equal res, 'multval1'
          done()
    it 'should delete values', ->
      store1.write 'key1', 'value1'
      assert.equal store1.read('key1'), 'value1'
      store1.remove 'key1'
      assert.equal store1.read('key1'), undefined
  describe 'events', ->
    it 'should trigger write event on write', (done) ->
      assertEventsSerial store1, [
        ['write', ['key3', 'value3']]
        ['written', ['key3', 'value3']]
      ], done
      store1.write 'key3', 'value3'
    it 'should trigger read event on read', (done) ->
      assertEvent store1, ['read', ['key3']], done
      store1.read 'key3'
  describe 'pipe', ->
    it 'should pipe the writes on one store to another', ->
      store2 = createMemoryStore()
      pipe store1, store2
      store1.write 'key4', 'value4'
      assert.equal store2.read('key4'), 'value4'