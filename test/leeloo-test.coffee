###

{ speed,
  tags,
  playing,
  interval,
  delay,
  idleTimeout,
  imageQueue,
  imagesPuff,
  imageShowTick,
  uniqueImageClass,
  shuffle,
  fetchImagesByKeyword,
  setSpeed,
  addTag,
  removeTag,
  pushGoogleImagesIntoQueue,
  pushInstImagesIntoQueue,
  addImageIntoDOM,
  fetchGoogleImages,
  fetchInstagramImages
  } = require "../source/javascripts/all.coffee"

###

#should = require("chai").should()
should = chai.should()

Leeloo = require "../source/javascripts/all.coffee"

leeloo = new Leeloo('normal')

describe 'Leeloo', ->
  describe 'constructor', ->
    it 'should work with should' ->
      leeloo.speed.should.be.a('string')

describe 'Initial State', ->
  describe 'speed', ->
    it 'should be a string' ->
      speed.should.be.a('string')