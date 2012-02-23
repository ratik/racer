expect = require 'expect.js'

module.exports = (AdapterSync) -> describe 'AdapterSync', ->

  it 'test get and set', ->
    adapterSync = new AdapterSync
    ver = 0
    expect(adapterSync.get()).to.specEql {}
    expect(adapterSync.version).to.equal ver

    adapterSync.set 'color', null, ++ver, null
    expect(adapterSync.get 'color').to.equal null
    expect(adapterSync.version).to.equal ver
    
    adapterSync.set 'color', 'green', ++ver, null
    expect(adapterSync.get 'color').to.equal 'green'
    expect(adapterSync.version).to.equal ver
    
    adapterSync.set 'info.numbers', first: 2, second: 10, ++ver, null
    expect(adapterSync.get 'info.numbers').to.specEql {first: 2, second: 10}
    expect(adapterSync.get()).to.specEql
        color: 'green'
        info:
          numbers:
            first: 2
            second: 10
    expect(adapterSync.version).to.equal ver
    
    adapterSync.set 'info', 'new', ++ver, null
    expect(adapterSync.get()).to.specEql {color: 'green', info: 'new'}
    expect(adapterSync.version).to.equal ver

  it 'speculative setting a nested path should not throw an error', ->
    adapterSync = new AdapterSync
    didErr = false
    try
      adapterSync.set 'nested.color', 'red', null, null
    catch e
      didErr = true
    expect(didErr).to.be.false

  it 'getting an unset path should return undefined', ->
    adapterSync = new AdapterSync
    ver = 0
    adapterSync.set 'info.numbers', {}, ver, null
    
    expect(adapterSync.get 'color').to.equal undefined
    expect(adapterSync.get 'color.favorite').to.equal undefined
    expect(adapterSync.get 'info.numbers.first').to.equal undefined

  it 'test del', ->
    adapterSync = new AdapterSync
    ver = 0
    adapterSync.set 'color', 'green', ver, null
    adapterSync.set 'info.numbers', first: 2, second: 10, ver, null
    adapterSync.del 'color', ver, null
    expect(adapterSync.get()).to.specEql
      info:
        numbers:
          first: 2
          second: 10
    
    adapterSync.del 'info.numbers', ver, null
    expect(adapterSync.get()).to.specEql {info: {}}
    
    # Make sure deleting something that doesn't exist isn't a problem
    adapterSync.del 'a.b.c', ++ver, null

    expect(adapterSync.version).to.equal ver

  it 'should be able to push a single value onto an undefined path', ->
    adapterSync = new AdapterSync
    ver = 0
    expect(adapterSync.get()).to.specEql {}
    adapterSync.push 'colors', 'green', ver, null
    expect(adapterSync.get 'colors').to.specEql ['green']

  it 'should be able to pop from a single member array path', ->
    adapterSync = new AdapterSync
    ver = 0
    expect(adapterSync.get()).to.specEql {}
    adapterSync.push 'colors', 'green', ver, null
    adapterSync.pop 'colors', ver, null
    expect(adapterSync.get 'colors').to.specEql []

  it 'should be able to push multiple members onto an array path', ->
    adapterSync = new AdapterSync
    ver = 0
    expect(adapterSync.get()).to.specEql {}
    adapterSync.push 'colors', 'green', ver, null
    adapterSync.push 'colors', 'red', 'blue', 'purple', ver, null
    expect(adapterSync.get 'colors').to.specEql ['green', 'red', 'blue', 'purple']

  it 'should be able to pop from a multiple member array path', ->
    adapterSync = new AdapterSync
    ver = 0
    adapterSync.push 'colors', 'red', 'blue', 'purple', ver, null
    adapterSync.pop 'colors', ver, null
    expect(adapterSync.get 'colors').to.specEql ['red', 'blue']

  it 'pop on a non array should throw a "Not an Array" error', ->
    adapterSync = new AdapterSync
    ver = 0
    adapterSync.set 'nonArray', '9', ver, null
    didThrowNotAnArray = false
    try
      adapterSync.pop 'nonArray', ver, null
    catch e
      expect(e.message).to.equal 'Not an Array'
      didThrowNotAnArray = true
    expect(didThrowNotAnArray).to.be.true

  it 'push on a non array should throw a "Not an Array" error', ->
    adapterSync = new AdapterSync
    ver = 0
    adapterSync.set 'nonArray', '9', ver, null
    didThrowNotAnArray = false
    try
      adapterSync.push 'nonArray', 5, 6, ver, null
    catch e
      expect(e.message).to.equal 'Not an Array'
      didThrowNotAnArray = true
    expect(didThrowNotAnArray).to.be.true


  it 'should be able to unshift a single value onto an undefined path', ->
    adapterSync = new AdapterSync
    ver = 0
    expect(adapterSync.get()).to.specEql {}
    adapterSync.unshift 'colors', 'green', ver, null
    expect(adapterSync.get 'colors').to.specEql ['green']

  it 'should be able to shift from a single member array path', ->
    adapterSync = new AdapterSync
    ver = 0
    expect(adapterSync.get()).to.specEql {}
    adapterSync.unshift 'colors', 'green', ver, null
    adapterSync.shift 'colors', ver, null
    expect(adapterSync.get 'colors').to.specEql []

  it 'should be able to unshift multiple members onto an array path', ->
    adapterSync = new AdapterSync
    ver = 0
    expect(adapterSync.get()).to.specEql {}
    adapterSync.unshift 'colors', 'red', 'blue', 'purple', ver, null
    expect(adapterSync.get 'colors').to.specEql ['red', 'blue', 'purple']

  it 'should be able to shift from a multiple member array path', ->
    adapterSync = new AdapterSync
    ver = 0
    expect(adapterSync.get()).to.specEql {}
    adapterSync.unshift 'colors', 'red', 'blue', 'purple', ver, null
    adapterSync.shift 'colors', ver, null
    expect(adapterSync.get 'colors').to.specEql ['blue', 'purple']

  it 'shift on a non array should throw a "Not an Array" error', ->
    adapterSync = new AdapterSync
    ver = 0
    adapterSync.set 'nonArray', '9', ver, null
    didThrowNotAnArray = false
    try
      adapterSync.shift 'nonArray', ver, null
    catch e
      expect(e.message).to.equal 'Not an Array'
      didThrowNotAnArray = true
    expect(didThrowNotAnArray).to.be.true

  it 'unshift on a non array should throw a "Not an Array" error', ->
    adapterSync = new AdapterSync
    ver = 0
    adapterSync.set 'nonArray', '9', ver, null
    didThrowNotAnArray = false
    try
      adapterSync.unshift 'nonArray', 5, 6, ver, null
    catch e
      expect(e.message).to.equal 'Not an Array'
      didThrowNotAnArray = true
    expect(didThrowNotAnArray).to.be.true

  it 'insert 0 on an undefined path should result in a new array', ->
    adapterSync = new AdapterSync
    ver = 0
    expect(adapterSync.get()).to.specEql {}
    adapterSync.insert 'colors', 0, 'yellow', ver, null
    expect(adapterSync.get 'colors').to.specEql ['yellow']

  it 'insert 0 on an empty array should fill the array with only those elements', ->
    adapterSync = new AdapterSync
    ver = 0
    adapterSync.set 'colors', [], ver, null
    adapterSync.insert 'colors', 0, 'yellow', ver, null
    expect(adapterSync.get 'colors').to.specEql ['yellow']

  it 'insert 0 in an array should act like a shift', ->
    adapterSync = new AdapterSync
    ver = 0
    adapterSync.set 'colors', ['yellow', 'black'], ver, null
    adapterSync.insert 'colors', 0, 'violet', ver, null
    expect(adapterSync.get 'colors').to.specEql ['violet', 'yellow', 'black']

  it 'insert the length of an array should act like a push', ->
    adapterSync = new AdapterSync
    ver = 0
    adapterSync.set 'colors', ['yellow', 'black'], ver, null
    adapterSync.insert 'colors', 2, 'violet', ver, null
    expect(adapterSync.get 'colors').to.specEql ['yellow', 'black', 'violet']

  it 'insert should be able to insert in-between an array with length >= 2', ->
    adapterSync = new AdapterSync
    ver = 0
    adapterSync.set 'colors', ['violet', 'yellow', 'black'], ver, null
    adapterSync.insert 'colors', 1, 'orange', ver, null
    expect(adapterSync.get 'colors').to.specEql ['violet', 'orange', 'yellow', 'black']


  it 'insert on a non-array should throw a "Not an Array" error', ->
    adapterSync = new AdapterSync
    ver = 0
    adapterSync.set 'nonArray', '9', ver, null
    didThrowNotAnArray = false
    try
      adapterSync.insert 'nonArray', 0, 'never added', ver, null
    catch e
      expect(e.message).to.equal 'Not an Array'
      didThrowNotAnArray = true
    expect(didThrowNotAnArray).to.be.true


  it 'test move of an array item to the same index', ->
    adapterSync = new AdapterSync
    ver = 0
    adapterSync.set 'colors', ['red', 'green', 'blue'], ver, null
    adapterSync.move 'colors', 1, 1, 1, ver, null
    expect(adapterSync.get 'colors').to.specEql ['red', 'green', 'blue']
  
  it 'test move of an array item from a negative index to the equivalent positive index', ->
    adapterSync = new AdapterSync
    ver = 0
    adapterSync.set 'colors', ['red', 'green', 'blue'], ver, null
    adapterSync.move 'colors', -1, 2, 1, ver, null
    expect(adapterSync.get 'colors').to.specEql ['red', 'green', 'blue']

  it 'test move of an array item from a positive index to the equivalent negative index', ->
    adapterSync = new AdapterSync
    ver = 0
    adapterSync.set 'colors', ['red', 'green', 'blue'], ver, null
    adapterSync.move 'colors', 0, -3, 1, ver, null
    expect(adapterSync.get 'colors').to.specEql ['red', 'green', 'blue']

  it 'test move of an array item to a later index', ->
    adapterSync = new AdapterSync
    ver = 0
    adapterSync.set 'colors', ['red', 'green', 'blue'], ver, null
    adapterSync.move 'colors', 0, 2, 1, ver, null
    expect(adapterSync.get 'colors').to.specEql ['green', 'blue', 'red']

  it 'test move of an array item to a later index, from negative', ->
    adapterSync = new AdapterSync
    ver = 0
    adapterSync.set 'colors', ['red', 'green', 'blue'], ver, null
    adapterSync.move 'colors', -3, 2, 1, ver, null
    expect(adapterSync.get 'colors').to.specEql ['green', 'blue', 'red']

  it 'test move of an array item to a later index, to negative', ->
    adapterSync = new AdapterSync
    ver = 0
    adapterSync.set 'colors', ['red', 'green', 'blue'], ver, null
    adapterSync.move 'colors', 0, -1, 1, ver, null
    expect(adapterSync.get 'colors').to.specEql ['green', 'blue', 'red']

  it 'test move of an array item to an earlier index', ->
    adapterSync = new AdapterSync
    ver = 0
    adapterSync.set 'colors', ['red', 'green', 'blue'], ver, null
    adapterSync.move 'colors', 2, 1, 1, ver, null
    expect(adapterSync.get 'colors').to.specEql ['red', 'blue', 'green']

  it 'test move of an array item to an earlier index, from negative', ->
    adapterSync = new AdapterSync
    ver = 0
    adapterSync.set 'colors', ['red', 'green', 'blue'], ver, null
    adapterSync.move 'colors', -1, 1, 1, ver, null
    expect(adapterSync.get 'colors').to.specEql ['red', 'blue', 'green']
  
  it 'test move of an array item to an earlier index, to negative', ->
    adapterSync = new AdapterSync
    ver = 0
    adapterSync.set 'colors', ['red', 'green', 'blue'], ver, null
    adapterSync.move 'colors', 2, -2, 1, ver, null
    expect(adapterSync.get 'colors').to.specEql ['red', 'blue', 'green']

  it 'move on a non-array should throw a "Not an Array" error', ->
    adapterSync = new AdapterSync
    ver = 0
    adapterSync.set 'nonArray', '9', ver, null
    didThrowNotAnArray = false
    try
      adapterSync.move 'nonArray', 0, 0, 1, ver, null
    catch e
      expect(e.message).to.equal 'Not an Array'
      didThrowNotAnArray = true
    expect(didThrowNotAnArray).to.be.true


  it 'test remove (from array)', ->
    adapterSync = new AdapterSync
    ver = 0
    expect(adapterSync.get()).to.specEql {}

    # on a defined non-array
    didThrowNotAnArray = false
    adapterSync.set 'nonArray', '9', ver, null
    try
      adapterSync.remove 'nonArray', 0, 3, ver, null
    catch e
      expect(e.message).to.equal 'Not an Array'
      didThrowNotAnArray = true
    expect(didThrowNotAnArray).to.be.true

    # on a non-empty array, with howMany to remove in-bounds
    adapterSync.set 'colors', ['red', 'yellow', 'orange'], ver, null
    adapterSync.remove 'colors', 0, 2, ver, null
    expect(adapterSync.get 'colors').to.specEql ['orange']
