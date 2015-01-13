should = require("chai").should()

Leeloo = require "../source/javascripts/all.coffee"

leeloo = new Leeloo('normal')

describe 'Leeloo', ->
  describe 'speed', ->
    it 'should be a string', ->
      leeloo.speed.should.be.a('string')
  describe 'stop', ->
    it 'should return true', ->
      leeloo.stop.should.be.true