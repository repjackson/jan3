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


Meteor.publish 'delta', ->
    Docs.find {
        type:'delta'
    }, {limit:1}


# facet macro to find documents
# facet micro to view into/manipulate docs



Meteor.methods
    fo: ->
        delta = Docs.findOne
            type:'delta'
            author_id: Meteor.userId()

        built_query = { keys: {$exists:true} }

        filter_keys = []
        
        facets = [
            {
                key:'keys'
                type:'array'
                primitive:'array'
            }
        ]

        
        # include existing filter selections
        if delta.active_facets
            for key in delta.active_facets
                filter_list = delta["filter_#{key}"]
                if filter_list
                    built_query["#{key}"] = $all: filter_list
    
        # need to normalize list of existing filters
        # so normalizing keys in the fo method, ~abstracting my own server code
        
        # for filter in facets
        #     unless filter.key in filter_keys
        #         filter_keys.push filter.key

        for facet in facets
            filter_list = delta["filter_#{facet.key}"]
            if filter_list and filter_list.length > 0
                if facet.primitive is 'array'
                    # need auto discovery, even for user_ids, thats the intelligence, not just primitive detection.  so this section will evolve.
                    built_query["#{facet.key}"] = $all: filter_list
                else
                    built_query["#{facet.key}"] = $in: filter_list
            else
                Docs.update delta._id,
                    $set: "filter_#{facet.key}":[]


        total = Docs.find(built_query).count()
        # maybe this references keys_return?
        for key in delta.keys_return
            values = []
            local_return = []
            
            # field type detection 
            example_doc = Docs.findOne({"#{facet.key}":$exists:true})
            example_value = example_doc?["#{facet.key}"]
            primitive = typeof example_value

            if primitive
                test_calc = Meteor.call 'agg', built_query, primitive, key
            else
                console.log 'no primitive', facet, 'key:', key
            Docs.update {_id:delta._id},
                { $set:"#{facet.key}_return":test_calc }
                , ->

        results_cursor = Docs.find built_query 

        result_ids = []
        for result in results_cursor.fetch()
            result_ids.push result._id


        Docs.update {_id:delta._id},
            {$set:
                total: total
                result_ids:result_ids
            }, ->
        return true


    agg: (query, type, key)->
        console.log query
        console.log type
        options = {
            explain:false
            }
            
        # intelligence
        if type in ['array','multiref']
            pipe =  [
                { $match: query }
                { $project: "#{key}": 1 }
                { $unwind: "$#{key}" }
                { $group: _id: "$#{key}", count: $sum: 1 }
                { $sort: count: -1, _id: 1 }
                { $limit: 20 }
                { $project: _id: 0, name: '$_id', count: 1 }
            ]
        else
            pipe =  [
                { $match: query }
                { $project: "#{key}": 1 }
                { $group: _id: "$#{key}", count: $sum: 1 }
                { $sort: count: -1, _id: 1 }
                { $limit: 20 }
                { $project: _id: 0, name: '$_id', count: 1 }
            ]

        agg = Docs.rawCollection().aggregate(pipe,options)

        res = {}
        if agg
            agg.toArray()