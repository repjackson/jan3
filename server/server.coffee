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
    Docs._ensureIndex({ "$**": "text" })
)
Meteor.startup(() =>
    Meteor.users._ensureIndex({ "$**": "text" })
)
Meteor.startup(() =>
    Meteor.users._ensureIndex( { "username": 1 }, { unique: true } )
)


Accounts.onCreateUser (options, user)=>
    # console.log 'trying to update new user with options', options
    # console.log 'trying to update new user ', user
    
    edited_user = Object.assign({
        customer_jpid:options.customer_jpid
        franchisee_jpid:options.franchisee_jpid
        office_jpid:options.office_jpid
        roles:options.roles
    }, user)

    if options.profile
        edited_user.profile = options.profile
    return edited_user


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


SyncedCron.add({
        name: 'Update customers'
        schedule: (parser) ->
            # parser is a later.parse object
            parser.text 'every 6 hours'
        job: -> 
            Meteor.call 'get_recent_customers', (err, res)->
                if err then console.log err
                else
                    console.log 'update customers res:',res
    },{
        name: 'Update users'
        schedule: (parser) ->
            # parser is a later.parse object
            parser.text 'every 3 hours'
        job: -> 
            Meteor.call 'sync_ev_users', (err, res)->
                if err then console.log err
                else
                    console.log 'user sync res:',res
    },{
    },{
        name: 'Update franchisee'
        schedule: (parser) ->
            # parser is a later.parse object
            parser.text 'every 8 hours'
        job: -> 
            Meteor.call 'get_recent_franchisees', (err, res)->
                if err then console.log err
                else
                    console.log 'update franchisees res:',res
    },{
        name: 'Update office'
        schedule: (parser) ->
            # parser is a later.parse object
            parser.text 'every 6 hours'
        job: -> 
            Meteor.call 'get_recent_offices', (err, res)->
                if err then console.log err
                else
                    console.log 'update offices res:',res
    }
)


if Meteor.isProduction
    SyncedCron.start()

    
    
Docs.allow
    insert: (user_id, doc) -> user_id
    # update: (user_id, doc) -> doc.author_id is user_id or Roles.userIsInRole(user_id, 'admin')
    remove: (user_id, doc) -> 
        user = Meteor.users.findOne user_id
        doc.author_id is user_id or 'admin' in user.roles
    update: (user_id, doc) -> user_id
    # remove: (user_id, doc) -> user_id
