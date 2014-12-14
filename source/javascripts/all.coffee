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
imagesPuff = 24

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

pushImagesIntoQueue = (response, tag) ->
    for result in response.responseData.results
        imageQueue.push {
            url: result.url
            width: result.width
            height: result.height
            tag: tag
            shown: false
        }

addImageIntoDOM = ->
    if imageQueue.length > 0
        imageIndex = Math.floor(Math.random() * imageQueue.length)
        #showing image
        $('.images-layer').append('<img class="image image-' + imageIndex + '" src="' + imageQueue[imageIndex].url + '"/>')
        $('.image-' + imageIndex).css('left', Math.floor(Math.random() * ($(window).width() - imageQueue[imageIndex].width)))
        $('.image-' + imageIndex).css('top', Math.floor(Math.random() * ($(window).height() - imageQueue[imageIndex].height)))
        $('.image-' + imageIndex).show()
        imageQueue[imageIndex].shown = true
        imagesOnTheDOM.push(imageQueue[imageIndex])
        imageQueue.splice(imageIndex, 1)
        removeImageFromDOMToQueue()

removeImageFromDOMToQueue = ->
    if imagesOnTheDOM >= imagesPuff || imageQueue < 3
        imageQueue.push(imagesOnTheDOM.shift())
        console.log(imageQueue.length, imagesOnTheDOM.length)

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




