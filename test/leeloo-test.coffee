###
should = require("chai").should()

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

speed.should.be.a('string')
speed.should.be.equal('normal')
###

expect = chai.expect

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

expect(speed).to.be.a("string")