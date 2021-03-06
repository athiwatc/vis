window.canvasObject = []

#$('#canvas').css('background', 'url(/sample-pic.png)')

#When the template visualize is rendered
#The canvas will be drawn
Template.visualize.rendered = ->
  #Create the master canvas
  #This is where everything begins in the drawing phase
  window.canvas = oCanvas.create(
    canvas: "#canvas"
    fps: 1
  )

  #Create a parrent ellipse object for the child to clone it for faster speed and setting the object less times.
  window.ellipse = window.canvas.display.ellipse(
    x:100
    y:100
    radius: 15
    fill: "rgba(0,0,0,0.1)"
  )

  window.canvas.setLoop ->
    #Get the sensor at the current time
    #There should only be one sensor data at any giving time as it already been collapsed
    sensors = SensorData.findOne({type: 1, time: window.currentTime.unix()})
    #Just checking that there's a sensor at a current time
    if sensors?
      #Loop against all active sensor
      for sensor in sensors.sensor
        #Fetch the position of each sensorfrom the database
        pos = SensorPosition.findOne({name: sensor})
        if pos?

          #console.log pos #Logging
          #Clone the object from the parent to get faster speed
          e = window.ellipse.clone()
          #Set the positions
          e.x = pos.x
          e.y = pos.y

          #Add the object to the store
          window.canvasObject.push({e: e, count: 0})

          #Add the object to the canvas to prepare for fading
          window.canvas.addChild(e)

    window.canvasObject = _.filter(window.canvasObject, (canvasObject, index) ->
      window.canvasObject[index].count += 1
      #console.log window.canvasObject[index].count
      if canvasObject.count >= window.keep
        window.canvas.removeChild(canvasObject.e)
        return false
      else
        return true
    )
            
          

          #e.fill("rgba(0,0,0,1)")
          #window.canvasObject.unshift(e)
          #window.canvas.removeChild(window.canvasObject.pop()) while (window.canvasObject.length >= 50)

    window.currentTime.add 's', 1
    $('#currentTime').val(window.currentTime.toString())

Template.visualize.events {
  #Click start
  'click .start': ->
    #Disable the start button
    $('.start').attr("disabled", true)
    #Enable the stop button
    $('.stop').removeAttr("disabled")
    #Parse the value in the GUI into variables
    window.canvas.settings.fps = parseInt($('#speed').val())
    window.currentTime = moment($('#currentTime').val())
    window.keep = parseInt($('#keep').val())
    #Start the canvas timeline
    window.canvas.timeline.start()
  #Click stop
  'click .stop': ->
    #Disable the stop button
    $('.stop').attr("disabled", true)
    #Enable the start button
    $('.start').removeAttr("disabled")
    #Request a stop to the timeline
    #It might no be stop right away but that is not a problem
    window.canvas.timeline.stop()
  #Click reset
  'click .reset': ->
    window.canvas.reset()
  #Called when the new wants to load a new set of files
  'click #loadButton': ->
    #Remove the image from the canvas
    $('#canvas').css('background', 'url()')

    l = Ladda.create( document.querySelector( '#loadButton' ) )
    l.start()


    #Set the file prefix
    filename = $('#file').val()

    Session.set('file', filename)
    
    #Call the meteor on the server to load the set of files and when finish load up the background image to the canvas
    Meteor.call('update', filename, ->
      $('#canvas').css('background', 'url(/'+filename+'-pic.png)')
      l.stop()
    )
}

