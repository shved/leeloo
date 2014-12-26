//= require 'jquery'

###
initial state
speed could be: slow, normal, high
###

speed = 'normal'
tags = ['небо', 'Кадыров', 'mandelbrot']
playing = true
interval = 2000

imageQueue = []
imagesPuff = 20

imageShowTick = 0

uniqueImageClass = 0

###
functions
###

Array.prototype.shuffle = ->
    i = this.length
    if (i == 0)
        return
    while (--i)
        j = Math.floor(Math.random() * (i + 1))
        temp = this[i]
        this[i] = this[j]
        this[j] = temp

fetchImagesByKeyword = (keyword) ->
    fetchGoogleImages(keyword)

setSpeed = (newSpeed) ->
    if newSpeed == 'slow' or 'normal' or 'high'
        $('.speed-control .selected').removeClass('selected')
        $('.speed-control').find('.' + newSpeed).addClass('selected')
        switch newSpeed
            when 'slow' then interval = 4000
            when 'normal' then interval = 2000
            when 'high' then interval = 1000
            else interval = 2000
        clearInterval(imageShowTick)
        imageShowTick = setInterval(addImageIntoDOM, interval)
        speed = newSpeed


pushImagesIntoQueue = (response, tag) ->
    for result in response.responseData.results
        width = result.width
        height = result.height
        ratio = height / width
        if ($(window).width() < 600) || ($(window).height() < 600)
            maxW = $(window).width()
            maxH = $(window).height()
        else
            maxW = 600
            maxH = 600

        if (width > maxW) && (ratio <= 1)
                width = maxW
                height = width * ratio
            else if height > 600
                height = maxH
                width = height / ratio

        imageQueue.push {
            url: result.url
            width: width
            height: height
            tag: tag
        }
    imageQueue.shuffle()


addImageIntoDOM = ->
    uniqueImageClass += 1
    imageIndex = uniqueImageClass % imageQueue.length
    if imageIndex == 0
        imageQueue.shuffle()
    $('.images-layer').append('<img class="image image-' + uniqueImageClass + '" src="' + imageQueue[imageIndex].url + '"/>')
    $('.image-' + uniqueImageClass).css('left', Math.floor(Math.random() * ($(window).width() - imageQueue[imageIndex].width)))
    $('.image-' + uniqueImageClass).css('top', Math.floor(Math.random() * ($(window).height() - imageQueue[imageIndex].height)))
    $('.image-' + uniqueImageClass).css('width', imageQueue[imageIndex].width)
    $('.image-' + uniqueImageClass).css('height', imageQueue[imageIndex].height)
    $('.image-' + uniqueImageClass).show()
    if $('.images-layer > img').length > imagesPuff
        $('.images-layer > img:first').remove()

###
ajax requests stuff
###

###
google image search
###

fetchGoogleImages = (keyword) ->
    reqURL = 'http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&imgsz=large&q=' + keyword + '&safe=off'
    querys = [0, 8, 16, 24]
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

    if playing
        $('.control > .play').hide()
        imageShowTick = setInterval(addImageIntoDOM, interval)

    setSpeed(speed)

    for tag in tags
        $('.container').append('<div class="tag-item"><p>' + tag + '</p><div class="remove"><div class="cross"><div class="cross-one"></div><div class="cross-two"></div></div></div></div>')
        fetchImagesByKeyword(tag)

    #play/pause control
    $('.control').on('click', ->
        if playing == true
            $('.control > .play').show()
            $('.control > .pause').hide()
            playing = false
            clearInterval(imageShowTick)
        else
            $('.control > .play').hide()
            $('.control > .pause').show()
            playing = true
            imageShowTick = setInterval(addImageIntoDOM, interval)

    )

    #speed control
    $('.slow').on('click', ->
        setSpeed('slow')
    )

    $('.normal').on('click', ->
        setSpeed('normal')
    )

    $('.high').on('click', ->
        setSpeed('high')
    )

    #'about' control
    $('#about').on('click', ->
        $('.about').show();
    )

    $('.about').on('click', '.close-about', ->
        $('.about').hide();
    )

    #add new tag
    $('.add').on('click', (event) ->
        event.stopPropagation()
        event.preventDefault()
        if $('.tags-input').val()
            newTag = $('.tags-input').val()
            tags.push(newTag)
            if tags.length == 1
                imageShowTick = setInterval(addImageIntoDOM, interval)
            $('.container').append('<div class="tag-item"><p>' + newTag + '</p><div class="remove"><div class="cross"><div class="cross-one"></div><div class="cross-two"></div></div></div></div>')
            $('.tags-input').val('')
            fetchImagesByKeyword(newTag)
    )

    #add new tag with keyboard
    $('.tags-input').on('keyup', (event) ->
        if event.which == 13 && $('.tags-input').val()
            newTag = $('.tags-input').val()
            tags.push(newTag)
            if tags.length == 1
                imageShowTick = setInterval(addImageIntoDOM, interval)
            $('.container').append('<div class="tag-item"><p>' + newTag + '</p><div class="remove"><div class="cross"><div class="cross-one"></div><div class="cross-two"></div></div></div></div>')
            $('.tags-input').val('')
            fetchImagesByKeyword(newTag)
    )

    #remove tag
    $('.remove').on('click', ->
        event.stopPropagation()
        event.preventDefault()
        removedTag = $(this).prev().html()
        index = tags.indexOf(removedTag)
        if index > -1
            tags.splice(index, 1)
            if tags.length < 1
                clearInterval(imageShowTick)
                imageQueue = []
            else
                imageQueue = $.grep(imageQueue, (image) ->
                    return image.tag != removedTag
                    )
                imageQueue.shuffle()
        $(this).parent().remove()
    )