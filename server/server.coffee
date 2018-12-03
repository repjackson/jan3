Meteor.users.allow
    update: (userId, doc, fields, modifier) ->
        true
        # if userId and doc._id == userId
        #     true

# SyncedCron.config
#     log: true
#     collectionName: 'cron_history'
#     utc: false
#     collectionTTL: 17280

# if Meteor.isProduction
#     SyncedCron.add(
#         {
#             name: 'Update ticket escalations'
#             schedule: (parser) ->
#                 parser.text 'every 50 minutes'
#                 # so it catches 1 hour escalations
#             job: ->
#                 console.log 'running site escalation check'
#                 Meteor.call 'run_site_escalation_check', (err,res)->
#                     if err then console.error err
#         },{
#             name: 'Update customers'
#             schedule: (parser) ->
#                 parser.text 'every 3 hours'
#             job: ->
#                 console.log 'updating customers'
#                 Meteor.call 'update_customers', (err, res)->
#                     if err then console.error err
#         },{
#             name: 'Update users'
#             schedule: (parser) ->
#                 parser.text 'every 3 hours'
#             job: ->
#                 console.log 'updating users/3hrs'
#                 Meteor.call 'sync_ev_users', (err, res)->
#                     if err then console.error err
#         },{
#             name: 'Update franchisee'
#             schedule: (parser) ->
#                 parser.text 'every 3 hours'
#             job: ->
#                 console.log 'updating franchisee'
#                 Meteor.call 'update_franchisees', (err, res)->
#                     if err then console.error err
#         },{
#             name: 'Update office'
#             schedule: (parser) ->
#                 parser.text 'every 3 hours'
#             job: ->
#                 console.log 'updating office'
#                 Meteor.call 'update_offices', (err, res)->
#                     if err then console.error err
#         }
#     )


# if Meteor.isProduction
#     SyncedCron.start()

Meteor.methods
    raw_count: ->
        raw = Docs.rawCollection()
            # .distinct('author_id')
        dis = Meteor.wrapAsync raw.distinct, raw
        count = dis 'author_id'
        console.log count
        
        
    keys: ->
        start = Date.now()
        console.log 'starting keys'
        cursor = Docs.find({keys:$exists:false}, {limit:10000}).fetch()
        for doc in cursor
            keys = _.keys doc
            # console.log doc
            Docs.update doc._id,
                $set:keys:keys
            
            console.log "updated keys for doc #{doc._id}"
        stop = Date.now()
        
        diff = stop - start
        # console.log diff
        console.log moment(diff).format("HH:mm:ss:SS")
        
    key_count: ->
        start = Date.now()
        console.log 'starting key count'
        cursor = Docs.find({key_count:$exists:false}, {limit:30000}).fetch()
        for doc in cursor
            key_count = doc.keys.length
            Docs.update doc._id,
                $set:key_count:key_count
            
            console.log "updated key count for doc #{doc.type}, #{key_count}"
        stop = Date.now()
        
        diff = stop - start
        # console.log diff
        console.log moment(diff).format("HH:mm:ss:SS")
        
        

Docs.allow
    insert: (user_id, doc) -> user_id
    # update: (user_id, doc) -> doc.author_id is user_id or Roles.userIsInRole(user_id, 'admin')
    remove: (user_id, doc) ->
        user = Meteor.users.findOne user_id
        doc.author_id is user_id or 'dev' in user.roles
    update: (user_id, doc) -> user_id
    # remove: (user_id, doc) -> user_id
