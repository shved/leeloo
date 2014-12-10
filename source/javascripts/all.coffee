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

    fetchImagesByKeyword: (keyword) ->


    setSpeed: (newSpeed) ->
        if @speed == 'slow' or 'normal' or 'high'
            $('#speed-control .selected').removeClass('selected')
            @speed = newSpeed
            $('#speed-control').find('.' + @speed).addClass('selected')

    startCarousel: ->
        console.log('started')
        fetchGoogleImagesByKeyword('webpunk')

###
ajax requests declarations
###

###
google image search
###

fetchGoogleImagesByKeyword = (keyword) ->
    reqURL = 'http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&imgsz=large&q=' + keyword + '&safe=off&start=0'
    $.ajax({
    url: reqURL,
    jsonp: "callback",
    dataType: "jsonp",
    data: {
        q: "select title,abstract,url from search.news where query=\"cat\"",
        format: "json"
    },

    // Work with the response
    success: function( response ) {
        console.log( response ); // server response
    }
});


###
main stuff
###
$(document).ready ->

    leeloo = new Leeloo(speed, tags, state)
    leeloo.startCarousel()

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




