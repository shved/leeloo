//= require 'jquery'

###
initial state
speed could be: slow, normal, high
###

speed = 'normal'
tags = ['webpunk', 'Кадыров', 'mandelbrot']
state = 'play'

imageQueue = []
imagesOnTheDOM = []

lastShownImageTag = ''

###
functions
###
fetchImagesByKeyword = (keyword) ->
    fetchGoogleImages(keyword)

setSpeed = (newSpeed) ->
    if speed == 'slow' or 'normal' or 'high'
        $('#speed-control .selected').removeClass('selected')
        speed = newSpeed
        $('#speed-control').find('.' + speed).addClass('selected')

pushImagesIntoQueue = (response, keyword) ->
    for result in response.responseData.results
        imageQueue.push {
            url: result.url
            width: result.width
            height: result.height
            keyword: keyword
            shown: false
        }

addImageIntoDOM = ->
    if imageQueue.length > 0
        console.log(imageQueue.length)
        for image in imageQueue
            console.log
            if not image.shown
                $('.images-layer').append('<img class="image image-' + imageQueue.indexOf(image) + '" src="' + image.url + '"/>')
                $('.image-' + imageQueue.indexOf(image)).css('left', Math.floor(Math.random() * ($(window).width() - image.width)))
                $('.image-' + imageQueue.indexOf(image)).css('top', Math.floor(Math.random() * ($(window).height() - image.height)))
                $('.image-' + imageQueue.indexOf(image)).show()
                image.shown = true
                break
###
ajax requests stuff
###

###
google image search
###

fetchGoogleImages = (keyword) ->
    reqURL = 'http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&imgsz=large&q=' + keyword + '&safe=off'
    querys = [0, 8, 16]
    querys = [0]
    $.map(querys, (start) ->
        $.ajax {
            url: reqURL,
            dataType: "jsonp",
            success: (response) ->
                pushImagesIntoQueue(response, keyword)
            data: {
                    'start': start
                }
            })

###
main stuff
###
$(document).ready ->

    $('#speed-control').find('.' + speed).addClass('selected')
    $('.container').append()
    for tag in tags
        $('.container').append('<div class="tag-item"><p>' + tag + '</p><div class="remove"><div class="cross"><div class="cross-one"></div><div class="cross-two"></div></div></div></div>')
        fetchImagesByKeyword(tag)

    setInterval(addImageIntoDOM, 1000)

    $('.slow').on('click', ->
        leeloo.setSpeed('slow')
    )

    $('.normal').on('click', ->
        leeloo.setSpeed('normal')
    )

    $('.high').on('click', ->
        leeloo.setSpeed('high')
    )

    $('#about').on('click', ->
        $('.about').show();
    )

    $('.about').on('click', '.close-about', ->
        $('.about').hide();
    )




