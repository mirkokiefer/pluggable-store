
{server} = require '../lib/index'
assert = require 'assert'

store = server().memory()

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