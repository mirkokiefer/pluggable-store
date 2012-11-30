
assert = require 'assert'
{contains} = require 'underscore'

tests = (storeFun) -> () ->
  describe 'read/write', () ->
    testData = [{key: 'mult1', value: 'multval1'}, {key: 'mult2', value: 'multval2'}]
    store = null
    beforeEach (done) ->
      store = storeFun()
      store.ensureStore done
    afterEach (done) -> store.removeStore done

    it 'should write and read an object', (done) ->
      store.write 'key2', 'value2', () ->
        store.read 'key2', (err, res) ->
          assert.equal res, 'value2'
          done()
    it 'should write and read multiple objects', (done) ->
      store.writeAll testData, ->
        store.read 'mult1', (err, res) ->
          assert.equal res, 'multval1'
          done()
    it 'should delete values', ->
      store.write 'key1', 'value1', ->
        store.remove 'key1', ->
          store.read 'key1', (err, res) ->
            assert.equal res, undefined
    it 'should return all keys', ->
      store.writeAll testData, ->
        store.keys (err, keys) ->
          assert.ok contains(keys, key) for {key} in testData
          assert.equal keys.length, testData.length

module.exports = tests