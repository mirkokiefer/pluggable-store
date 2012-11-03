// Generated by CoffeeScript 1.3.3
(function() {
  var assert, server, store;

  server = require('../lib/index').server;

  assert = require('assert');

  store = server().memory();

  describe('PluggableStore using Memory adapter', function() {
    return describe('read/write', function() {
      it('should write and read an object sync', function() {
        store.write('path1', 'value1');
        return assert.equal(store.read('path1'), 'value1');
      });
      return it('should write and read an object async', function(done) {
        return store.write('path2', 'value2', function() {
          return store.read('path2', function(err, res) {
            assert.equal(res, 'value2');
            return done();
          });
        });
      });
    });
  });

}).call(this);