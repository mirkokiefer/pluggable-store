// Generated by CoffeeScript 1.3.3
(function() {
  var assert, assertEvent, assertEventsSerial, createMemoryStore, pipe, server, store1, _ref,
    __slice = [].slice;

  _ref = require('../lib/index'), server = _ref.server, pipe = _ref.pipe;

  assert = require('assert');

  createMemoryStore = server().memory;

  assertEvent = function(emitter, _arg, cb) {
    var event, expectedArgs;
    event = _arg[0], expectedArgs = _arg[1];
    return emitter.once(event, function() {
      var args, each, i, _i, _len;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      for (i = _i = 0, _len = expectedArgs.length; _i < _len; i = ++_i) {
        each = expectedArgs[i];
        assert.equal(args[i], each);
      }
      return cb();
    });
  };

  assertEventsSerial = function(emitter, events, cb) {
    var first, rest;
    if (events.length === 0) {
      return cb();
    } else {
      first = events[0], rest = 2 <= events.length ? __slice.call(events, 1) : [];
      return assertEvent(emitter, first, function() {
        return assertEventsSerial(emitter, rest, cb);
      });
    }
  };

  store1 = null;

  beforeEach(function() {
    return store1 = createMemoryStore();
  });

  describe('PluggableStore using Memory adapter', function() {
    describe('read/write', function() {
      it('should write and read an object sync', function() {
        store1.write('key1', 'value1');
        return assert.equal(store1.read('key1'), 'value1');
      });
      it('should write and read an object async', function(done) {
        return store1.write('key2', 'value2', function() {
          return store1.read('key2', function(err, res) {
            assert.equal(res, 'value2');
            return done();
          });
        });
      });
      it('should write and read multiple objects', function() {
        var data;
        data = [
          {
            key: 'mult1',
            value: 'multval1'
          }, {
            key: 'mult2',
            value: 'multval2'
          }
        ];
        store1.writeAll(data);
        assert.equal(store1.read('mult1'), 'multval1');
        return assert.equal(store1.read('mult2'), 'multval2');
      });
      it('should write and read multiple objects async', function(done) {
        var data;
        data = [
          {
            key: 'mult1',
            value: 'multval1'
          }, {
            key: 'mult2',
            value: 'multval2'
          }
        ];
        return store1.writeAll(data, function() {
          return store1.read('mult1', function(err, res) {
            assert.equal(res, 'multval1');
            return done();
          });
        });
      });
      return it('should delete values', function() {
        store1.write('key1', 'value1');
        assert.equal(store1.read('key1'), 'value1');
        store1.remove('key1');
        return assert.equal(store1.read('key1'), void 0);
      });
    });
    describe('events', function() {
      it('should trigger write event on write', function(done) {
        assertEventsSerial(store1, [['write', ['key3', 'value3']], ['written', ['key3', 'value3']]], done);
        return store1.write('key3', 'value3');
      });
      return it('should trigger read event on read', function(done) {
        assertEvent(store1, ['read', ['key3']], done);
        return store1.read('key3');
      });
    });
    return describe('pipe', function() {
      return it('should pipe the writes on one store to another', function() {
        var store2;
        store2 = createMemoryStore();
        pipe(store1, store2);
        store1.write('key4', 'value4');
        return assert.equal(store2.read('key4'), 'value4');
      });
    });
  });

}).call(this);
