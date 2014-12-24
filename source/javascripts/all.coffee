//= require 'jquery'

###
initial state
speed could be: slow, normal, high
###

speed = 'normal'
tags = ['webpunk', 'Кадыров', 'mandelbrot', 'Путин', 'мотоцикл', 'нож']
state = 'play'

imageQueue = []
imagesOnTheDOM = []
imagesPuff = 20

uniqueImageClass = 0

###
functions
###
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
            shown: false
        }

addImageIntoDOM = ->
    if imageQueue.length > 2
        imageIndex = Math.floor(Math.random() * imageQueue.length)
        uniqueImageClass += 1
        #showing image
        $('.images-layer').append('<img class="image image-' + uniqueImageClass + '" src="' + imageQueue[imageIndex].url + '"/>')
        $('.image-' + uniqueImageClass).css('left', Math.floor(Math.random() * ($(window).width() - imageQueue[imageIndex].width)))
        $('.image-' + uniqueImageClass).css('top', Math.floor(Math.random() * ($(window).height() - imageQueue[imageIndex].height)))
        $('.image-' + uniqueImageClass).show()
        imageQueue[imageIndex].shown = true
        imagesOnTheDOM.push(imageQueue[imageIndex])
        imageQueue.splice(imageIndex, 1)
        removeImageFromDOMToQueue()

removeImageFromDOMToQueue = ->
    if (imagesOnTheDOM.length >= imagesPuff) || (imageQueue < 4)
        $('.images-layer > img:first').remove()
        if imagesOnTheDOM[0].tag in tags
            imagesOnTheDOM[0].shown = false
            imageQueue.push(imagesOnTheDOM.shift())

###
ajax requests stuff
###

###
google image search
###

fetchGoogleImages = (keyword) ->
    reqURL = 'http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&imgsz=medium&q=' + keyword + '&safe=off'
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

    $('.speed-control').find('.' + speed).addClass('selected')
    for tag in tags
        $('.container').append('<div class="tag-item"><p>' + tag + '</p><div class="remove"><div class="cross"><div class="cross-one"></div><div class="cross-two"></div></div></div></div>')
        fetchImagesByKeyword(tag)

    setInterval(addImageIntoDOM, 1000)

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

    $('.add').on('click', (event) ->
        event.stopPropagation()
        event.preventDefault()
        if $('.tags-input').val()
            newTag = $('.tags-input').val()
            tags.push(newTag)
            $('.container').append('<div class="tag-item"><p>' + newTag + '</p><div class="remove"><div class="cross"><div class="cross-one"></div><div class="cross-two"></div></div></div></div>')
            $('.tags-input').val('')
            fetchImagesByKeyword(newTag)
    )

    $('.remove').on('click', ->
        removedTag = $(this).prev().html()
        index = tags.indexOf(removedTag)
        console.log tags, removedTag
        if index > 1
            tags.splice(index, 1)
        imageQueue = $.grep(imageQueue, (image) ->
            return image.tag != removedTag
        )
        $(this).parent().remove()
    )