Meteor.users.allow
    update: (userId, doc, fields, modifier) ->
        true
        # # console.log 'user ' + userId + 'wants to modify doc' + doc._id
        # if userId and doc._id == userId
        #     # console.log 'user allowed to modify own account'
        #     true

Cloudinary.config
    cloud_name: 'facet'
    api_key: Meteor.settings.cloudinary_key
    api_secret: Meteor.settings.cloudinary_secret


Meteor.publish 'incidents', ->
    Incidents.find {}
        
Meteor.publish 'incident', (i_id)->
    Incidents.find i_id
        
        
Meteor.publish 'facet_doc', (tags)->
    split_array = tags.split ','
    Docs.find
        tags: split_array
        
Meteor.publish 'users', ()->
    Meteor.users.find()
    
    
    