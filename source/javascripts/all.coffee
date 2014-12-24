//= require 'jquery'

###
initial state
speed could be: slow, normal, high
###

speed = 'normal'
tags = ['небо', 'Кадыров', 'mandelbrot']
playing = true
interval = 1000

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
        speed = newSpeed
        $('.speed-control').find('.' + speed).addClass('selected')

pushImagesIntoQueue = (response, tag) ->
    for result in response.responseData.results
        imageQueue.push {
            url: result.url
            width: result.width
            height: result.height
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
    reqURL = 'http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&imgsz=medium&q=' + keyword + '&safe=off'
    querys = [0, 8, 16]
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

    $('.speed-control').find('.' + speed).addClass('selected')
    for tag in tags
        $('.container').append('<div class="tag-item"><p>' + tag + '</p><div class="remove"><div class="cross"><div class="cross-one"></div><div class="cross-two"></div></div></div></div>')
        fetchImagesByKeyword(tag)

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

    $('.slow').on('click', ->
        setSpeed('slow')
    )

    $('.normal').on('click', ->
        setSpeed('normal')
    )

    $('.high').on('click', ->
        setSpeed('high')
    )

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