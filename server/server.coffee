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


Meteor.startup(() =>
  Docs._ensureIndex({ "$**": "text" });
  Meteor.users._ensureIndex({ "$**": "text" });
)




SyncedCron.config
    log: true
    logger: null
    collectionName: 'cron_history'
    utc: false
    collectionTTL: 17280



SyncedCron.add
    name: 'Update incident escalations'
    schedule: (parser) ->
        # parser is a later.parse object
        parser.text 'every 1 hour'
    job: -> 
        Meteor.call 'update_escalation_statuses', (err,res)->
            if err then console.log err
            # else
                # console.log 'res:',res


SyncedCron.add
    name: 'Update ny customers'
    schedule: (parser) ->
        # parser is a later.parse object
        parser.text 'every 6 hours'
    job: -> 
        Meteor.call 'sync_ny_customers', (err, res)->
            if err then console.log err
            else
                console.log 'res:',res
            
            

# SyncedCron.start()

    
    
Docs.allow
    insert: (user_id, doc) -> user_id
    # update: (user_id, doc) -> doc.author_id is user_id or Roles.userIsInRole(user_id, 'admin')
    # remove: (user_id, doc) -> doc.author_id is user_id or Roles.userIsInRole(user_id, 'admin')
    update: (user_id, doc) -> user_id
    remove: (user_id, doc) -> user_id
