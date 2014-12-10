//= require 'jquery'

###
initial state
speed could be: slow, normal, high
###

speed = 'normal'
tags = ['webpunk', 'Кадыров', 'mandelbrot']
state = 'play'

###
declarations
###
class Leeloo
    constructor: (@speed='normal', @tags=['webpunk', 'Кадыров', 'mandelbrot'], @state='play') ->
        $('#speed-control').find('.' + @speed).addClass('selected')
        $('.about').hide()
        $('.container').append()
        for tag in tags
            $('.container').append('<div class="tag-item"><p>' + tag + '</p><div class="remove"><div class="cross"><div class="cross-one"></div><div class="cross-two"></div></div></div></div>')
            this.fetchImagesByKeyword(tag)

    fetchImagesByKeyword: (keyword) ->
        fetchGoogleImages(keyword)


    setSpeed: (newSpeed) ->
        if @speed == 'slow' or 'normal' or 'high'
            $('#speed-control .selected').removeClass('selected')
            @speed = newSpeed
            $('#speed-control').find('.' + @speed).addClass('selected')

imageQueue = []

pushImagesIntoQueue = (response) ->
    for result in response.responseData.results
        imageQueue.push {
            url: result.url
            width: result.width
            height: result.height
        }
    for image in imageQueue
        $('.images-layer').append('<img class="image image-' + imageQueue.indexOf(image) + '" src="' + image.url + '"/>')
        $('.image-' + imageQueue.indexOf(image)).css('left', Math.floor(Math.random() * ($(window).width() - image.width)))
        $('.image-' + imageQueue.indexOf(image)).css('top', Math.floor(Math.random() * ($(window).height() - image.height)))

###
ajax requests stuff
###

###
google image search
###

fetchGoogleImages = (keyword) ->
    reqURL = 'http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&imgsz=large&q=' + keyword + '&safe=off'
    querys = [0, 8, 16]
    $.map(querys, (start) ->
        $.ajax {
            url: reqURL,
            dataType: "jsonp",
            success: (response) ->
                pushImagesIntoQueue(response)
            data: {
                    'start': start
                }
            })

###
main stuff
###
$(document).ready ->

    leeloo = new Leeloo(speed, tags, state)

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




