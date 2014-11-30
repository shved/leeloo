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

    setSpeed: (newSpeed) ->
        if @speed == 'slow' or 'normal' or 'high'
            $('#speed-control .selected').removeClass('selected')
            @speed = newSpeed
            $('#speed-control').find('.' + @speed).addClass('selected')

    imageQueue: {

    }

class Image
    constructor: (@url, @position) ->

###
main stuff
###
$(document).ready ->
    console.log('start')

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




