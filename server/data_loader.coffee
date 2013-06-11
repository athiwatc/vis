fs = Npm.require('fs')


#Meteor.method

#Remove old data
#SensorPosition.remove({})
#SensorData.remove({})

Meteor.methods {
  #Call everything the user wants to load a new data set
  update: (filename) ->
    check(filename, String)
    SensorPosition.remove({})
    data = fs.readFileSync(filename + '-pos.txt')
    pos = data.toString().split(/\r\n|\r|\n/g);
    for x in pos
      p = x.split(' ')
      SensorPosition.insert({name: p[0], x: parseInt(p[1]), y: parseInt(p[2])})


    SensorData.remove({})
    data = fs.readFileSync(filename + '-data.txt')
    events  = data.toString().split(/\r\n|\r|\n/g);
    for event in events
      x = event.split(' ')
      if x[0] == '0'
        SensorData.insert({type: 0, time: parseInt(x[1]), event: x[2], status: x[3]})
      else
        SensorData.insert({type: 1, time: parseInt(x[1]), sensor: x.splice(2)})
}
