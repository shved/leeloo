//= require "jquery"
//= require "idle"

###
initial state and variables
speed could be: "slow", "fast", "faster"
###

speed = "fast"
tags = ["mandelbrot", "webpunk", "Кадыров"]
playing = true
interval = 2000
delay = 200

idleTimeout = 2500

imageQueue = []
imagesPuff = 20

imageShowTick = 0
uniqueImageId = 0

dirty = true

###
functions
###

Array.prototype.shuffle = ->
  i = this.length
  return if i == 0
  while (--i)
    j = Math.floor(Math.random() * (i + 1))
    temp = this[i]
    this[i] = this[j]
    this[j] = temp

fetchImagesByKeyword = (keyword) ->
  fetchGoogleImages keyword
  fetchInstagramImages keyword

setSpeed = (newSpeed) ->
  if newSpeed == "slow" or "fast" or "faster"
    $(".speed-control .selected").removeClass("selected")
    $(".speed-control").find("." + newSpeed).addClass("selected")
    switch newSpeed
      when "slow"
        interval = 4000
        $(".speed-control > .selected-bg").css({
          "left": "62px"
          "width": "82px"
        })
      when "fast"
        interval = 2000
        $(".speed-control > .selected-bg").css({
          "left": "160px"
          "width": "78px"
        })
      when "faster"
        interval = 1000
        $(".speed-control > .selected-bg").css({
          "left": "250px"
          "width": "96px"
        })
      else interval = 2000

    if playing
      clearInterval imageShowTick
      imageShowTick = setInterval addImageIntoDOM, interval

    speed = newSpeed

document.onIdle = ->
  $(".control").fadeOut(500, ->
  )

document.onBack = ->
  $(".control").fadeIn(500, ->
  )

tagHtml = (tagName) ->
  return "<div class=\"tag-item\"><p>#{ tagName }</p></div>"

addTag = ->
  tagName = $("#tags-input").val()
  tags.push tagName
  fetchImagesByKeyword tagName
  $(".container").append(tagHtml(tagName))
  $("#tags-input").val("")
  if tags.length == 1
    imageShowTick = setInterval addImageIntoDOM, interval
    $(".control > .play").hide()
    $(".control > .pause").show()
    playing = true

removeTag = (tagName) ->
  index = tags.indexOf(tagName)
  tags.splice index, 1
  if tags.length < 1
    clearInterval imageShowTick
    $(".control > .play").show()
    $(".control > .pause").hide()
    playing = false
    imageQueue = []
    tags = []
    $(".images-layer").empty()
  else
    imageQueue = $.grep(imageQueue, (image) ->
      return image.tag != tagName
      )
    $(".images-layer > ._#{ tagName }").remove()
    imageQueue.shuffle()

addImageIntoDOM = ->
  uniqueImageId += 1
  imageIndex = uniqueImageId % imageQueue.length
  if imageIndex == 0
    imageQueue.shuffle()
  $(".images-layer").append("<img class=\"_image _#{ imageQueue[imageIndex].tag }\" id=\"image-#{ uniqueImageId }\" src=\"#{ imageQueue[imageIndex].url }\" onerror=\"var newSrc=Math.floor(Math.random()*595); this.onerror=null; this.src='images/emoji/' + newSrc + '.png'; $(this).css({'height':'160px','width':'160px'});\"/>")
  image = $("#image-#{ uniqueImageId }")
  image.css({
    "left" : (Math.floor(Math.random() * ($(window).width() - imageQueue[imageIndex].width))) + randomGap(imageQueue[imageIndex].width)
    "top" : (Math.floor(Math.random() * ($(window).height() - imageQueue[imageIndex].height))) + randomGap(imageQueue[imageIndex].height)
    "width" : imageQueue[imageIndex].width
    "height" : imageQueue[imageIndex].height
    }).hide()
  setTimeout( ->
    image.show()
  , delay)
  if $(".images-layer > img").length > imagesPuff
    $(".images-layer > img:first").remove()

tagsInputBlink = ->
  $("#tags-input").css("background", "red")
  setTimeout( ->
    $("#tags-input").css("background", "blue")
  , 100)

randomGap = (value) ->
  return [-1, 1][Math.floor(Math.random()*2)] * (value * (Math.random()/6))

###
ajax requests stuff
###

pushImagesIntoQueue = (response, tag, source) ->
  switch source
    when "google"
      if response.responseData.results[0].url
        for result in response.responseData.results
          width = result.width
          height = result.height
          ratio = height / width
          if ($(window).width() < 800) || ($(window).height() < 800)
            maxW = $(window).width()
            maxH = $(window).height()
          else
            maxW = 800
            maxH = 800

          if (width > maxW) && (ratio <= 1)
            width = maxW
            height = width * ratio
          else if height > 800
            height = maxH
            width = height / ratio

          imageQueue.push {
            url: result.url
            width: width
            height: height
            tag: tag
          }
      imageQueue.shuffle()
    when "instagram"
      if response.data[0].images.standard_resolution.url
        for post in response.data
          imageQueue.push {
            url: post.images.standard_resolution.url
            width: 612
            height: 612
            tag: tag
          }
      imageQueue.shuffle()

###
google request
###

fetchGoogleImages = (keyword) ->
  reqURL = "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&imgsz=large&q=#{ keyword }"
  queries = [0, 8, 16, 24, 32, 40]
  queries.shuffle()
  $.map queries, (start) ->
    $.ajax
      url: reqURL
      dataType: "jsonp"
      success: (response) ->
        pushImagesIntoQueue response, keyword, "google"
      data:
        "start": start
        "safe": if dirty then "off" else "on"
      error:
        console.log('')

###
instagram request
###

fetchInstagramImages = (hashTag) ->
  clientId = "80603d73bec0476b828b34203b234dce"
  reqURL = "https://api.instagram.com/v1/tags/#{ hashTag }/media/recent?client_id=#{ clientId }"
  $.ajax
    url: reqURL
    dataType: "jsonp"
    success: (response) ->
      pushImagesIntoQueue response, hashTag, "instagram"
    data:
      count: 10
    error:
      console.log('')

###
main stuff
###

$(document).ready ->

  #setting up initial state

  $(".about").hide()

  if dirty
    $(".dirty-prompt").hide()
  else
    $(".safe-prompt").hide()

  setIdleTimeout idleTimeout

  if playing
    $(".control > .play").hide()
    imageShowTick = setInterval addImageIntoDOM, interval

  for tag in tags
    $(".container").append(tagHtml(tag))
    fetchImagesByKeyword tag

  setSpeed speed

  #setting up all event handlers

  #window visibility
  $(document).on("visibilitychange", ->
    if (document.hidden) && playing
      clearInterval imageShowTick
    if (not (document.hidden)) && playing
      imageShowTick = setInterval addImageIntoDOM, interval
  )

  #play/pause control
  $(".control").on("click", ->
    if playing == true
      $(".control > .play").show()
      $(".control > .pause").hide()
      playing = false
      clearInterval imageShowTick
    else if tags.length > 0
      $(".control > .play").hide()
      $(".control > .pause").show()
      playing = true
      imageShowTick = setInterval addImageIntoDOM, interval
    else if tags.length < 1
      tagsInputBlink()
    )

  #speed control
  $(".slow").on("click", ->
    setSpeed "slow"
  )

  $(".fast").on("click", ->
      setSpeed "fast"
    )

  $(".faster").on("click", ->
      setSpeed "faster"
    )

  #logo control
  $("#logo").on("click", ->
    $(".about").show();
  )

  $(".about").on("click", ".close-about", ->
    $(".about").hide();
  )

  #safe/dirty control
  $(".safe").on("click", ->
    dirty = false
    $(".images-layer").empty()
    imageQueue = []
    for tag in tags
      fetchImagesByKeyword tag
    $(".safe-prompt").css({
      "display": "none"
    })
    $(".dirty-prompt").css({
      "display": "block"
    })
    $(".tags-input").css({
      "background": "rgba(255, 255, 255, 0.3)"
    })
  )

  $(".dirty").on("click", ->
    dirty = true
    $(".images-layer").empty()
    imageQueue = []
    for tag in tags
      fetchImagesByKeyword tag
    $(".safe-prompt").css({
      "display": "block"
    })
    $(".dirty-prompt").css({
      "display": "none"
    })
    $(".tags-input").css({
      "background": "rgba(0, 0, 0, 0.3)"
    })
  )

  #keyboard controls on window
  $(window).on("keyup", (event) ->
    switch event.which
      when 27
        $(".about").hide()
      when 32
        if !$("#tags-input").is(":focus")
          if playing
            $(".control > .play").show()
            $(".control > .pause").hide()
            playing = false
            clearInterval imageShowTick
          else if tags.length > 0
            $(".control > .play").hide()
            $(".control > .pause").show()
            playing = true
            imageShowTick = setInterval addImageIntoDOM, interval
          else if tags.length < 1
            tagsInputBlink()
  )

  #adding new tag
  $(".add").on("click", ->
    if $("#tags-input").val()
      addTag()
      $(".tag-item").on("click", ->
        tagToRemove = $(this).children().first().html()
        removeTag tagToRemove
        $(this).remove()
      )
    else
      tagsInputBlink()
  )

  #adding new tag with keyboard
  $("#tags-input").on("keyup", (event) ->
    if event.which == 13 && $("#tags-input").val()
      addTag()
      $(".tag-item").on("click", ->
        tagToRemove = $(this).children().first().html()
        removeTag tagToRemove
        $(this).remove()
      )
    else if !$("#tags-input").val()
      tagsInputBlink()
    )

  #removing tag
  $(".tag-item").on("click", ->
    tagToRemove = $(this).children().first().html()
    removeTag tagToRemove
    $(this).remove()
  )