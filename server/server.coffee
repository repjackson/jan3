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


        
Meteor.publish 'facet_doc', (tags)->
    split_array = tags.split ','
    Docs.find
        tags: split_array
        
Meteor.publish 'users', ()->
    Meteor.users.find()
    
    
    
Docs.allow
    insert: (user_id, doc) -> true
    # update: (user_id, doc) -> doc.author_id is user_id or Roles.userIsInRole(user_id, 'admin')
    # remove: (user_id, doc) -> doc.author_id is user_id or Roles.userIsInRole(user_id, 'admin')
    update: (user_id, doc) -> true
    remove: (user_id, doc) -> 'admin' in Meteor.user().roles
