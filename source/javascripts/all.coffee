//= require 'jquery'

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

    $('#about').on('click', ->
        $('.about').show();
    )

    $('.about').on('click', '.close-about', ->
        $('.about').hide();
    )




