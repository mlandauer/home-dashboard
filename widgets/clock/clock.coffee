class Dashing.Clock extends Dashing.Widget

  ready: ->
    setInterval(@startTime, 500)

  startTime: =>
    today = new Date()

    h = today.getHours()
    m = today.getMinutes()
    s = today.getSeconds()
    m = @formatTime(m)
    s = @formatTime(s)
    # Don't want to use a 24 hour clock
    h = if h < 13 then h else h - 12
    @set('time', h + ":" + m)
    @set('date', today.toDateString())

  formatTime: (i) ->
    if i < 10 then "0" + i else i
