//= require 'jquery'
//= require 'idle'

###
initial state and variables
speed could be: 'slow', 'fast', 'faster'
###

dict = [
  'baroque',
  'minimalism',
  'tie dye',
  'kaleidoscope',
  'bhagavad gita',
  'ISIL',
  'Tolstoy',
  'Кадыров',
  'mandelbrot',
  'webpunk',
  'hunting knife',
  'starcraft brood war',
  'doom II',
  'hieronymus bosch',
  'indigo children',
  'butterfly',
  'Charles Manson',
  'atari',
  'armagetron',
  'Escher',
  'Psychic TV',
  'Liquid Sky',
  'acid',
  'ayahuasca',
  'kali',
  'AK-47',
  'virtual reality',
  'DARPA',
  'freemasonry',
  'ГУЛАГ',
  'lightning',
  'medieval engravings',
  'borges bibliothek',
  'adventure time',
  'Noel Fielding',
  'Varanasi',
  'stupa',
  'curiosity mars',
  'large hadron collider',
  'hubble',
  'тарковский фильмы',
  'lotus flower',
  'dinosaur',
  'tokyo',
  'ghost in the shell'
]

speed = 'fast'
tags = []
playing = true
interval = 2000

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
  fetchFlickrImages keyword
  fetchTumblrImages keyword

setSpeed = (newSpeed) ->
  if newSpeed == 'slow' or 'fast' or 'faster'
    $('.speed-control .selected').removeClass('selected')
    $('.speed-control').find('.' + newSpeed).addClass('selected')
    switch newSpeed
      when 'slow'
        interval = 4000
        $('.speed-control > .selected-bg').css({
          'left': '62px'
          'width': '82px'
        })
      when 'fast'
        interval = 2000
        $('.speed-control > .selected-bg').css({
          'left': '160px'
          'width': '78px'
        })
      when 'faster'
        interval = 1000
        $('.speed-control > .selected-bg').css({
          'left': '250px'
          'width': '96px'
        })
      else interval = 2000

    if playing
      pause(true)
      play(interval)

    speed = newSpeed

play = (speed = interval) ->
  imageShowTick = setInterval addImageIntoDOM, speed
  playing = true
  $('.control > .play').hide()
  $('.control > .pause').show()

pause = (silently = false) ->
  clearInterval imageShowTick
  $('.control > .play').show()
  $('.control > .pause').hide()
  if silently == false
    playing = false


convertUserTextIntoTag = (tag) ->
  return tag.split(' ').join('-').replace("'", '')

tagHtml = (tagName) ->
  return "<div class=\"tag-item\" id=\"tag-#{ convertUserTextIntoTag(tagName) }\"><p>#{ tagName }</p></div>"

addTag = ->
  tagName = $('#tags-input').val()
  tags.unshift tagName
  fetchImagesByKeyword tagName
  $('.container').prepend(tagHtml(tagName))
  $(".tag-item#tag-#{ convertUserTextIntoTag(tagName) }").on('click', ->
    tagToRemove = $(this).children().first().html()
    removeTag tagToRemove
    $(this).remove()
  )
  $('#tags-input').val('')
  if tags.length == 1
    $('.share').show()
    play(interval)

removeTag = (tagName) ->
  index = tags.indexOf(tagName)
  tags.splice(index, 1)
  if tags.length <= 0
    pause()
    imageQueue = []
    tags = []
    $('.images-layer').empty()
    $('.share').hide()
  else
    imageQueue = $.grep(imageQueue, (image) ->
      return image.tag != tagName
      )
    $(".images-layer > ._#{ convertUserTextIntoTag(tagName) }").remove()
    imageQueue.shuffle()

addImageIntoDOM = ->
  uniqueImageId += 1
  imageIndex = uniqueImageId % imageQueue.length
  if imageIndex == 0
    imageQueue.shuffle()
  $('.images-layer').append("<img class=\"_image _#{ convertUserTextIntoTag(imageQueue[imageIndex].tag) }\" id=\"image-#{ uniqueImageId }\" src=\"#{ imageQueue[imageIndex].url }\" onload=\"$(this).show();\" onerror=\"var newSrc=Math.floor(Math.random()*595); this.onerror=null; this.src='images/emoji/' + newSrc + '.png'; $(this).css({'height':'160px','width':'160px'});\"/>")
  image = $("#image-#{ uniqueImageId }")
  if imageQueue[imageIndex].width && imageQueue[imageIndex].height
    image.css({
      'left' : (Math.floor(Math.random() * ($(window).width() - imageQueue[imageIndex].width))) + randomGap(imageQueue[imageIndex].width)
      'top' : (Math.floor(Math.random() * ($(window).height() - imageQueue[imageIndex].height))) + randomGap(imageQueue[imageIndex].height)
      'width' : imageQueue[imageIndex].width
      'height' : imageQueue[imageIndex].height
      })
  else
    image.css({
      'left' : (Math.floor(Math.random() * ($(window).width() - 500))) + randomGap(500)
      'top' : (Math.floor(Math.random() * ($(window).height() - 300))) + randomGap(300)
      })
  if $('.images-layer > img').length > imagesPuff
    $('.images-layer > img:first').remove()

###
url params stuff
###

jQuery.extend getQueryParameters: (str) ->
  (str or document.location.search).replace(/(^\?)/, '').split('&').map(((n) ->
    n = n.split('=')
    @[n[0]] = n[1]
    this
  ).bind({}))[0]

getShareUrl = ->
  str = document.location.origin + '?tags=' + encodeURI(tags.join(',')) + '&dirty=' + dirty

###
helpers
###

document.onIdle = ->
  $('.control').fadeOut(500, ->
  )

document.onBack = ->
  $('.control').fadeIn(500, ->
  )

getRandomInitialTags = (dict, len) ->
  while tags.length < len
    index = Math.floor(Math.random() * dict.length)
    tags.push(dict[index])
    dict.splice index, 1
  return tags

tagsInputBlink = ->
  $('#tags-input').css('background', 'red')
  setTimeout( ->
    $('#tags-input').css('background', 'blue')
  , 100)

randomGap = (value) ->
  return [-1, 1][Math.floor(Math.random() * 2)] * (value * (Math.random() / 6))

shareHoverAnimation = ->
  $tagitems = $('.container > .tag-item')
  $tagitems.animate({
    width: '100px'
  }, 300).animate({
    height: '100px'
  }, 300)

###
ajax requests stuff
###

###
google request
###

fetchGoogleImages = (keyword) ->
  reqURL = "http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&imgsz=large&q=#{ keyword }"
  queries = [0, 8, 16, 24, 32, 40, 48]
  queries.shuffle()
  $.map queries, (start) ->
    $.ajax
      url: reqURL
      dataType: 'jsonp'
      success: (response) ->
        pushGoogleImagesIntoQueue response, keyword
      data:
        'start': start
        'safe': if dirty then 'off' else 'on'

pushGoogleImagesIntoQueue = (response, tag) ->
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

###
instagram request
###

fetchInstagramImages = (tag) ->
  hashTag = tag.replace(/\s+/g, '')
  clientId = "80603d73bec0476b828b34203b234dce"
  reqURL = "https://api.instagram.com/v1/tags/#{ hashTag }/media/recent?client_id=#{ clientId }"
  $.ajax
    url: reqURL
    dataType: 'jsonp'
    success: (response) ->
      pushInstagramImagesIntoQueue response, tag
    data:
      count: 20
      max_tag_id: Math.floor(Math.random() * 8)

pushInstagramImagesIntoQueue = (response, tag) ->
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
flickr request
###

fetchFlickrImages = (tag) ->
  if tag.indexOf(' ') >= 0
    tag = tag.slice(0, tag.indexOf(' '))
  reqURL = "https://api.flickr.com/services/feeds/photos_public.gne?tagmode=any&tags=#{ tag }&format=json&jsoncallback=?"
  $.getJSON(reqURL, (data) ->
    pushFlickrImagesIntoQueue data, tag
    )

pushFlickrImagesIntoQueue = (response, tag) ->
  if response.items[0].media.m
    for item in response.items
      url = item.media.m
      imageQueue.push {
        url: url.replace('_m', '')
        tag: tag
      }
    imageQueue.shuffle()

###
tumblr request
###

fetchTumblrImages = (tag) ->
  if tag.indexOf(' ') >= 0
    tag = tag.slice(0, tag.indexOf(' '))
  api_key = 'faCvJFK7FWT9jSl7BojKsIqNn5IenzHlPaQR0r1nanmQoBhlk6'
  reqURL = "http://api.tumblr.com/v2/tagged?tag=#{ tag }&limit=80&api_key=#{ api_key }"
  $.ajax
    url: reqURL
    dataType: 'jsonp'
    success: (response) ->
      pushTumblrImagesIntoQueue response, tag

pushTumblrImagesIntoQueue = (response_obj, tag) ->
  if response_obj.response[0]
    for response in response_obj.response
      if response.photos
        for photo in response.photos
          imageQueue.push {
            url: photo.alt_sizes[1].url
            width: photo.alt_sizes[1].width
            height: photo.alt_sizes[1].height
            tag: tag
          }
    imageQueue.shuffle()

###
main stuff
###

$(document).ready ->

  #setting up initial state

  queryParams = $.getQueryParameters()
  console.log(queryParams)

  if dirty == true
    $('.dirty-prompt').hide()
  else
    $('.safe-prompt').hide()

  if queryParams['']
    if queryParams['tags']
      tags = decodeURI(queryParams['tags']).split(',')
    if queryParams['dirty'] == 'false'
      dirty = false
      $('.safe-prompt').css({
        'display': 'none'
      })
      $('.dirty-prompt').css({
        'display': 'block'
      })
      $('.tags-input').css({
        'background': 'rgba(255, 255, 255, 0.3)'
      })
    else if queryParams['dirty'] == 'true'
      dirty = true
      $('.safe-prompt').css({
        'display': 'block'
      })
      $('.dirty-prompt').css({
        'display': 'none'
      })
      $('.tags-input').css({
        'background': 'rgba(0, 0, 0, 0.3)'
      })
  else
    tags = getRandomInitialTags(dict, 3)

  $('.about').hide()

  $('.share-url').hide()

  setIdleTimeout idleTimeout

  for tag in tags
    $('.container').prepend(tagHtml(tag))
    fetchImagesByKeyword tag

  if (document).hidden
    pause(true)
  else
    play(interval)

  #setting up all event handlers

  #window visibility
  $(document).on('visibilitychange', ->
    if (document.hidden) && playing
      pause(true)
    if (not (document.hidden))
      if playing
        play(interval)
      else if not playing
        console.log('you\'re lucky')
  )

  #play/pause control
  $('.control').on('click', ->
    if playing
      pause(false)
    else if tags.length > 0
      play(interval)
    else if tags.length < 1
      tagsInputBlink()
    )

  #speed control
  $('.slow').on('click', ->
    setSpeed 'slow'
  )

  $('.fast').on('click', ->
      setSpeed 'fast'
    )

  $('.faster').on('click', ->
      setSpeed 'faster'
    )

  #logo control
  $('#logo').on('click', ->
    $('.about').show()
    $('#bgvid').get(0).play()
    if playing
      pause(true)
  )

  $('.about').on('click', '.close', ->
    $('.about').hide()
    $('#bgvid').get(0).pause()
    if playing
      play(interval)
  )

  #safe/dirty control
  $('.safe').on('click', ->
    dirty = false
    $('.images-layer').empty()
    imageQueue = []
    for tag in tags
      fetchImagesByKeyword tag
    $('.safe-prompt').css({
      'display': 'none'
    })
    $('.dirty-prompt').css({
      'display': 'block'
    })
    $('.tags-input').css({
      'background': 'rgba(255, 255, 255, 0.3)'
    })
  )

  $('.dirty').on('click', ->
    dirty = true
    $('.images-layer').empty()
    imageQueue = []
    for tag in tags
      fetchImagesByKeyword tag
    $('.safe-prompt').css({
      'display': 'block'
    })
    $('.dirty-prompt').css({
      'display': 'none'
    })
    $('.tags-input').css({
      'background': 'rgba(0, 0, 0, 0.3)'
    })
  )

  #keyboard controls on window
  $(window).on('keyup', (event) ->
    switch event.which
      when 27
        if $('.about').is(':visible')
          $('.about').hide()
          $('#bgvid').get(0).pause()
          if playing
            play(interval)
        if $('.share-url').is(':visible')
          $('.share-url').hide()
      when 32
        if !$('#tags-input').is(':focus')
          if playing
            pause()
          else if tags.length > 0
            play(interval)
          else if tags.length < 1
            tagsInputBlink()
  )

  #share button
  $('.share').on({
    mouseenter: ->
      $('.container > .tag-item').addClass('animated-gradient-hover')
    mouseleave: ->
      $('.container > .tag-item').removeClass('animated-gradient-hover')
    click: ->
      $('.the-url').text(getShareUrl())
      $('.share-url').show()
  })

  $('.share-url').on('click', '.close', ->
    $('.share-url').hide()
  )

  #adding new tag
  $('.add').on('click', ->
    if $('#tags-input').val()
      addTag()
    else
      tagsInputBlink()
  )

  #adding new tag with keyboard
  $('#tags-input').on('keyup', (event) ->
    if event.which == 13 && $('#tags-input').val()
      addTag()
    else if !$('#tags-input').val()
      tagsInputBlink()
    )

  #removing tag
  $('.tag-item').on('click', ->
    tagToRemove = $(this).children().first().html()
    removeTag tagToRemove
    $(this).remove()
  )
