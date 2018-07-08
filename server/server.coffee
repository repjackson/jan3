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


SyncedCron.add
    name: 'Crunch some important numbers for the marketing department'
    schedule: (parser) ->
        # parser is a later.parse object
        parser.text 'every 2 hours'
    job: -> 
        Meteor.call 'update_escalation_statuses', (err,res)->
            

    
    
Docs.allow
    insert: (user_id, doc) -> true
    # update: (user_id, doc) -> doc.author_id is user_id or Roles.userIsInRole(user_id, 'admin')
    # remove: (user_id, doc) -> doc.author_id is user_id or Roles.userIsInRole(user_id, 'admin')
    update: (user_id, doc) -> true
    remove: (user_id, doc) -> 'admin' in Meteor.user().roles
