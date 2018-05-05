Meteor.publish 'type', (type)->
    Docs.find 
        type:type