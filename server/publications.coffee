Meteor.publish 'type', (type, query=null, limit=100, sort_key='timestamp', sort_direction=-1, skip=0)->
    if query
        Docs.find {
            type: type
            $text: $search: query
        },{
            skip: skip
            limit:limit
            sort:"#{sort_key}":parseInt("#{sort_direction}")
        }
    else
        Docs.find {
            type:type
        },{
            skip: skip
            limit:limit
            sort:"#{sort_key}":parseInt("#{sort_direction}")
        }

        
Meteor.publish 'active_customers', (limit=100, sort_key='timestamp', sort_direction=-1, skip=0)->
    Docs.find {
        type:'customer'
    },{
        skip: skip
        limit:limit
        sort:"#{sort_key}":parseInt("#{sort_direction}")
    }

        



        
# Meteor.publish 'my_customer_account_doc', ->
#     if Meteor.user()
#         cust_id = Meteor.user().customer_jpid
#         cursor = Docs.find jpid:cust_id
#         cursor
        
Meteor.publish 'users_feed', (username, limit=100, sort_key='timestamp', sort_direction=-1, skip=0)->
    user = Meteor.users.findOne username:username
    Docs.find {
        type: 'event'
        author_id: user._id
    },{
            skip: skip
            limit:limit
            sort:"#{sort_key}":parseInt("#{sort_direction}")
        }
    
Meteor.publish 'all_users', (query, limit=100, sort_key='timestamp', sort_direction=-1, skip=0)->
    if query 
        Meteor.users.find {
            $text: $search: query
        },{
            skip: skip
            limit:limit
            sort:"#{sort_key}":parseInt("#{sort_direction}")
        }
    else
        Meteor.users.find {}, limit:10
    
    
    

# ReactiveTable.publish 'users', Meteor.users,'', {disablePageCountReactivity:true}
# # ReactiveTable.publish 'customers', Docs, {type:'customer', "ev.ACCOUNT_STATUS":'ACTIVE'}, {disablePageCountReactivity:true}
# # ReactiveTable.publish 'customers', Docs, {type:'customer',"ev.ACCOUNT_STATUS":'ACTIVE'}, {disablePageCountReactivity:true}
# ReactiveTable.publish 'events', Docs, {type:'event'}, {disablePageCountReactivity:false}
# ReactiveTable.publish 'franchisees', Docs, {type:'franchisee', "ev.ACCOUNT_STATUS":'ACTIVE'}, {disablePageCountReactivity:true}
# # ReactiveTable.publish 'incidents', Docs, {type:'incident'}, {disablePageCountReactivity:true}
# ReactiveTable.publish 'offices', Docs, {type:'office'}, {disablePageCountReactivity:true}
# ReactiveTable.publish 'special_services', Docs, {type:'special_service'}, {disablePageCountReactivity:true}
# ReactiveTable.publish 'services', Docs, {type:'service'}, {disablePageCountReactivity:true}
# ReactiveTable.publish 'jpids', Docs, {type:'jpid'}, {disablePageCountReactivity:true}
# ReactiveTable.publish 'search_history_docs', Docs, {type:'search_history_doc'}, {disablePageCountReactivity:true}


Meteor.publish 'child_docs', (doc_id, limit)->
    if limit
        Docs.find {parent_id:doc_id}, {limit:limit, sort:timestamp:-1}
    else
        Docs.find parent_id:doc_id
        
Meteor.publish 'parent_doc', (child_id)->
    child =  Docs.findOne child_id
    Docs.find
        _id: child.parent_id
        
        

# Meteor.publish 'users', ()->
#     Meteor.users.find()
    
publishComposite 'office', (office_id)->
    {
        find: -> Docs.find office_id
        # children: [
        #     # {
        #     #     # offices customers
        #     #     find: (office)-> 
        #     #         cursor = 
        #     #             Docs.find 
        #     #                 "ev.MASTER_LICENSEE":office.office_name
        #     #                 type:'customer'
        #     #         cursor
        #     #     children: [
        #     #         {
        #     #             find: (customer)-> 
        #     #                 cursor = 
        #     #                     Docs.find 
        #     #                         customer_jpid:customer.ev.ID
        #     #                         type:'incident'
        #     #                 cursor
            
        #     #         }
        #     #     ]
        #     # }
        #     # {
        #     #     find: (office)-> 
        #     #         Docs.find 
        #     #             incident_office_name:office.office_name
        #     #             type:'incident'
        #     # }
        #     # {
        #     #     find: (doc)-> Docs.find _id:doc.parent_id
        #     # }
        # ]
    }
        
Meteor.publish 'has_key', (key)->
    Docs.find "ev.#{key}": $exists: true
    # Docs.find "ev.FRANCH_NAME": $exists: true
        
        
Meteor.publish 'has_key_value', (key, value)->
    Docs.find "ev.#{key}": value
    # Docs.find "ev.FRANCH_NAME": $exists: true
        
        
# admin counters        
        
# Meteor.publish 'office_counter_publication', ->
#     Counts.publish this, 'office_counter', Docs.find({type:'office'})
#     return undefined
    
# Meteor.publish 'incident_counter_publication', ->
#     Counts.publish this, 'incident_counter', Docs.find({type:'incident'})
#     return undefined
        
# Meteor.publish 'franchisee_counter_publication', ->
#     Counts.publish this, 'franchisee_counter', Docs.find({type:'franchisee'})
#     return undefined
        
# Meteor.publish 'customer_counter_publication', ->
#     Counts.publish this, 'customer_counter', Docs.find({type:'customer'})
#     return undefined
        
        
        
# office subsections

Meteor.publish 'office_customers', (office_doc_id, query, limit=100, sort_key='timestamp', sort_direction=-1, skip=0)->    
    office_doc = Docs.findOne office_doc_id
    if query
        Docs.find {
            "ev.MASTER_LICENSEE": office_doc.ev.MASTER_LICENSEE
            type: "customer"
            $text: $search: query
        },{
            skip: skip
            limit:limit
            sort:"#{sort_key}":parseInt("#{sort_direction}")
        }
    else
        Docs.find {
            "ev.MASTER_LICENSEE": office_doc.ev.MASTER_LICENSEE
            type: "customer"
        },{
            skip: skip
            limit:limit
            sort:"#{sort_key}":parseInt("#{sort_direction}")
        }



Meteor.publish 'office_incidents', (office_doc_id, query, limit=100, sort_key='timestamp', sort_direction=-1, skip=0)->
    office_doc = Docs.findOne office_doc_id
    if query 
        Docs.find {
            incident_office_name: office_doc.ev.MASTER_LICENSEE
            type: "incident"
            $text: $search: query
        },{
            skip: skip
            limit:limit
            sort:"#{sort_key}":parseInt("#{sort_direction}")
        }
    else
        Docs.find {
            incident_office_name: office_doc.ev.MASTER_LICENSEE
            type: "incident"
        },{
            skip: skip
            limit:limit
            sort:"#{sort_key}":parseInt("#{sort_direction}")
        }
    
# Meteor.publish 'office_incidents', (office_doc_id, query, limit=100, sort_key='timestamp', sort_direction=-1, skip=0)->
#     office_doc = Docs.findOne office_doc_id
#     if query 
#         Docs.find {
#             incident_office_name: office_doc.ev.MASTER_LICENSEE
#             type: "incident"
#             $text: $search: query
#         }
#     else
#         Docs.find {
#             incident_office_name: office_doc.ev.MASTER_LICENSEE
#             type: "incident"
#         }
    
Meteor.publish 'office_franchisees', (office_doc_id, query, limit=100, sort_key='timestamp', sort_direction=-1, skip=0)->
    office_doc = Docs.findOne office_doc_id
    if query 
        Docs.find {
            type: "franchisee"
            $text: $search: query
            "ev.ACCOUNT_STATUS": 'ACTIVE'
            "ev.MASTER_LICENSEE": office_doc.ev.MASTER_LICENSEE
        },{
            skip: skip
            limit:limit
            sort:"#{sort_key}":parseInt("#{sort_direction}")
        }
    else
        Docs.find {
            type: "franchisee"
            "ev.ACCOUNT_STATUS": 'ACTIVE'
            "ev.MASTER_LICENSEE": office_doc.ev.MASTER_LICENSEE
        },{
            skip: skip
            limit:limit
            sort:"#{sort_key}":parseInt("#{sort_direction}")
        }
    
Meteor.publish 'office_employees', (office_doc_id, query, limit=100, sort_key='public', sort_direction=-1, skip=0)->
    office_doc = Docs.findOne office_doc_id
    if query 
        Meteor.users.find {
            "profile.office_name": office_doc.ev.MASTER_LICENSEE
            $text: $search: query
        },{
            skip: skip
            limit:limit
            sort:"#{sort_key}":parseInt("#{sort_direction}")
        }
    else
        Meteor.users.find {
            "profile.office_name": office_doc.ev.MASTER_LICENSEE
        },{
            skip: skip
            limit:limit
            sort:"#{sort_key}":parseInt("#{sort_direction}")
        }
    
    
Meteor.publish 'static_office_employees', (office_doc_id)->
    office_doc = Docs.findOne office_doc_id
    Meteor.users.find
        "profile.office_name": office_doc.ev.MASTER_LICENSEE
    
    
# Meteor.publish 'my_conversations',() ->
#     Docs.find
#         type: 'conversation'
#         participant_ids: $in: [Meteor.userId()]
    
    
    
    
Meteor.publish 'my_customer_incidents', (query, limit=100, sort_key='timestamp', sort_direction=-1, skip=0)->    
    user = Meteor.user()
    if user and user.customer_jpid
        # customer_doc = Docs.findOne "ev.ID":user.customer_jpid
        if query
            Docs.find {
                customer_jpid: user.customer_jpid
                type: 'incident'
                $text: $search: query
            },{
                skip: skip
                limit:limit
                sort:"#{sort_key}":parseInt("#{sort_direction}")
            }
        else
            Docs.find {
                customer_jpid: user.customer_jpid
                type: 'incident'
            },{
                skip: skip
                limit:limit
                sort:"#{sort_key}":parseInt("#{sort_direction}")
            }
publishComposite 'docs', (selected_tags, type, limit=100, sort_key='timestamp', sort_direction=-1, skip=0)->
    {
        find: ->
            self = @
            match = {}
            if type then match.type = type
            Docs.find match,
                limit:20
        children: [
            {
                find: (doc)-> Meteor.users.find _id:doc.author_id
            }
            {
                find: (doc)-> Docs.find _id:doc.parent_id
            }
        ]
    }


publishComposite 'incidents', (level, limit=100, sort_key='timestamp', sort_direction=-1, skip=0)->
    {
        find: ->
            self = @
            # match.current_level = parseInt(level)
            Docs.find {
                type:'incident' 
            },{
                skip: skip
                limit:limit
                sort:"#{sort_key}":parseInt("#{sort_direction}")
            }
        children: [
            {
                find: (doc)-> Meteor.users.find _id:doc.author_id
            }
            {
                find: (doc)-> Docs.find _id:doc.parent_id
            }
            {
                find: (doc)-> Meteor.users.find _id:$in:doc.assigned_to
            }
        ]
    }
    
    
    
    

Meteor.publish 'users_docs',(username) ->
    user = Meteor.users.findOne username:username
    Docs.find({author_id: user._id}, {limit:20})
    
Meteor.publish 'user_events',(username) ->
    user = Meteor.users.findOne username:username
    Docs.find({
        author_id: user._id
        type:'event'
        }, {limit:20})
    
Meteor.publish 'my_profile', ->
    Meteor.users.find @userId,
        fields:
            tags: 1
            profile: 1
            username: 1
            published: 1
            image_id: 1
            customer_jpid:1
            franchisee_jpid:1
            office_jpid:1


Meteor.publish 'user', (username)->
    Meteor.users.find username:username,
        fields:
            profile: 1
            username: 1
            ev:1
            published:1
            customer_jpid:1
            franchisee_jpid:1
            office_jpid:1
            
Meteor.publish 'user_profile', (user_id)->
    Meteor.users.find user_id,
        fields:
            profile: 1
            username: 1
            ev:1
            published:1
            customer_jpid:1
            franchisee_jpid:1
            office_jpid:1
            

Meteor.publish 'office_by_franchisee', (franch_id)->
    franch_doc = Docs.findOne franch_id
    if franch_doc.ev
        found = Docs.find
            type:'office'
            "ev.MASTER_OFFICE_NAME":franch_doc.ev.MASTER_LICENSEE
        return found
        
        
        
# user connected accounts 
Meteor.publish 'my_customer_account', ->
    user = Meteor.user()
    if user and user.customer_jpid
        Docs.find
            "ev.ID": user.customer_jpid
            type:'customer'
        
Meteor.publish 'my_franchisee', ->
    user = Meteor.user()
    if user and user.franchisee_jpid
        Docs.find
            "ev.ID": user.franchisee_jpid
            type:'franchisee'
        
Meteor.publish 'my_office', ->
    user = Meteor.user()
    if user 
        if user.customer_jpid
            customer_doc = Docs.findOne
                "ev.ID": user.customer_jpid
                type:'customer'
            Docs.find
                "ev.MASTER_LICENSEE": customer_doc.ev.MASTER_LICENSEE
                type:'office'
        if user.office_jpid
            Docs.find
                "ev.ID": user.office_jpid
                type:'office'

        
Meteor.publish 'my_special_services', ->
    user = Meteor.user()
    if user.customer_jpid
        customer_doc = Docs.findOne
            "ev.ID": user.customer_jpid
            type:'customer'
            # grandparent office
        Docs.find {
            type:'special_service'
            "ev.CUSTOMER": customer_doc.ev.CUST_NAME
        }
    
Meteor.publish 'my_office_contacts', ()->    
    user = Meteor.user()
    if user
        if 'customer' in user.roles
            if user.customer_jpid
                customer_doc = Docs.findOne
                    "ev.ID": user.customer_jpid
                    type:'customer'
                    # grandparent office
                Meteor.users.find {
                    "profile.office_name": customer_doc.ev.MASTER_LICENSEE
                }
        
        
publishComposite 'doc', (id)->
    {
        find: -> Docs.find id
        children: [
            {
                find: (doc)-> Meteor.users.find _id:doc.author_id
            }
            {
                find: (doc)-> Docs.find _id:doc.referenced_office_id
            }
            {
                find: (doc)-> Docs.find _id:doc.referenced_customer_id
            }
            {
                find: (doc)-> Docs.find _id:doc.parent_id
            }
        ]
    }
    
    
publishComposite 'incident', (id)->
    {
        find: -> Docs.find id
        children: [
            {
                find: (incident)-> Meteor.users.find _id:incident.author_id
            }
            {
                find: (incident)-> 
                    # customer doc
                    Docs.find
                        type:'customer'
                        "ev.ID": incident.customer_jpid

            }
            {
                find: (incident)-> 
                    Docs.find
                        "ev.ID": incident.office_jpid
                        type:'office'

            }
            # {
            #     find: (incident)-> Docs.find _id:doc.referenced_customer_id
            # }
            {
                find: (incident)-> 
                    Docs.find 
                        type:'feedback_response'
                        parent_id:incident._id
                        
            }
        ]
    }

publishComposite 'me', ()->
    {
        find: -> 
            Meteor.users.find @userId
        children: [
            {
                find: (user)-> 
                    # users customer account
                    if user.profile 
                        if user.customer_jpid
                            Docs.find
                                "ev.ID": user.customer_jpid
                                type:'customer'
                        if user.office_jpid
                            Docs.find
                                "ev.ID": user.office_jpid
                                type:'office'
                            
                # children: [
                #     # {
                #     #     find: (customer)-> 
                #     #         # parent incidents
                #     #         Docs.find
                #     #             customer_jpid: customer.jpid
                #     #             type:'incident'
                #     # }
                #     # {
                #     #     find: (customer)-> 
                #     #         # parent franchisee
                #     #         Docs.find
                #     #             franchisee: customer.franchisee
                #     #             type:'franchisee'
                #     # }
                #     # {
                #     #     find: (customer)-> 
                #     #         # special services
                #     #         Docs.find
                #     #             "ev.CUSTOMER": customer.cust_name
                #     #             type:'special_service'
                #     # }
                #     # {
                #     #     find: (customer)-> 
                #     #         # grandparent office
                #     #         Docs.find
                #     #             # "ev.MASTER_LICENSEE": customer.ev.MASTER_LICENSEE
                #     #             type:'office'
                #     #     # children: [
                #     #     #     {
                #     #     #         find: (office)-> 
                #     #     #             # offices users
                #     #     #             # Meteor.users.find
                #     #     #             #     "profile.office_name": office.ev.MASTER_OFFICE_NAME
                #     #     #     }
                #     #     # ]
                #     # }
                # ]    
            }
        ]
    }
Meteor.publish 'comments', (doc_id)->
    Docs.find
        parent_id: doc_id
        type:'comment'



Meteor.publish 'people_list', (conversation_id) ->
    conversation = Docs.findOne conversation_id
    Meteor.users.find
        _id: $in: conversation.participant_ids



# Meteor.publish 'conversation_messages', (conversation_id) ->
#     Docs.find
#         type: 'message'
#         conversation_id: conversation_id


# publishComposite 'participant_ids', (selected_theme_tags, selected_participant_ids)->
    
#     {
#         find: ->
#             self = @
#             match = {}
#             match.type = 'conversation'
#             if selected_theme_tags.length > 0 then match.tags = $all: selected_theme_tags
#             if selected_participant_ids.length > 0 then match.participant_ids = $in: selected_participant_ids
#             match.published = true
            
#             cloud = Docs.aggregate [
#                 { $match: match }
#                 { $project: participant_ids: 1 }
#                 { $unwind: "$participant_ids" }
#                 { $group: _id: '$participant_ids', count: $sum: 1 }
#                 { $match: _id: $nin: selected_participant_ids }
#                 { $sort: count: -1, _id: 1 }
#                 { $limit: 20 }
#                 { $project: _id: 0, text: '$_id', count: 1 }
#                 ]
        
        
            
#             # author_objects = []
#             # Meteor.users.find _id: $in: cloud.
        
#             cloud.forEach (participant_ids) ->
#                 self.added 'participant_ids', Random.id(),
#                     text: participant_ids.text
#                     count: participant_ids.count
#             self.ready()
        
#         # children: [
#         #     { find: (doc) ->
#         #         Meteor.users.find 
#         #             _id: doc.participant_ids
#         #         }
#         #     ]    
#     }            
    
    
# Meteor.publish 'conversations', (selected_theme_tags, selected_participant_ids, view_published)->

#     self = @
#     match = {}
#     if selected_theme_tags.length > 0 then match.tags = $all: selected_theme_tags
#     if view_published is true
#         match.published = 1
#         if selected_participant_ids.length > 0 then match.participant_ids = $in: selected_participant_ids
#     else if view_published = false
#         match.published = -1
#         selected_participant_ids.push Meteor.userId()
#         match.participant_ids = $in: selected_participant_ids
#     # if view_mode
#     #     if view_mode is 'mine'
#     #         match
#     #         match.participant_ids = $in: [Meteor.userId()]
#     # else
#         # if selected_participant_ids.length > 0 then match.participant_ids = $in: selected_participant_ids
            
            
#     match.type = 'conversation'
    
#     cursor = Docs.find match
#     return cursor

# publishComposite 'group_docs', (group_id)->
#     {
#         find: -> Docs.find group_id: group_id
#         children: [
#             {
#                 find: (doc)-> Docs.find _id: doc.parent_id
#                 children: [
#                     { 
#                         find: (doc)-> Docs.find _id: doc.parent_id 
#                         children: [
#                             { find: (doc)-> Docs.find _id: doc.parent_id }
#                         ]
#                     }
#                     {
#                         find: (doc)->
#                             Meteor.users.find
#                                 _id: doc.author_id
#                     }
#                 ]
#             }
#             {
#                 find: (doc)->
#                     Meteor.users.find
#                         _id: doc.author_id
#             }

#         ]
#     }
    
# Meteor.publish 'userStatus', ->
#     Meteor.users.find { 'status.online': true }, 
#         fields: 
#             points: 1
#             tags: 1
            
            
            
# Meteor.publish 'user_status_notification', ->
#     Meteor.users.find('status.online': true).observe
#         added: (id) ->
#         removed: (id) ->


Meteor.publish 'office_by_id', (office_jpid)->
    Docs.find
        type:'office'
        "ev.ID": office_jpid
        
Meteor.publish 'customer_by_id', (customer_jpid)->
    Docs.find
        type:'customer'
        "ev.ID": customer_jpid

Meteor.publish 'franchisee_by_id', (franchisee_jpid)->
    Docs.find
        type:'franchisee'
        "ev.ID": franchisee_jpid



Meteor.publish 'service_child_requests', (service_id)->
    Docs.find
        type:'service_request'
        service_id:service_id
        
        
Meteor.publish 'query', (query)->
    result = Meteor.call 'query_db', query
    return result
    
    
    
Meteor.publish 'offices', (name_filter='', limit=100, sort_key='timestamp', sort_direction=-1, skip=0)->
    int_direction = parseInt sort_direction
    int_skip = parseInt skip
    int_limit = parseInt limit
    Docs.find({
        type: 'office'
        "ev.MASTER_LICENSEE": {$regex:"#{name_filter}", $options: 'i'}
        },{
            skip: int_skip
            limit:int_limit
            sort:"#{sort_key}":int_direction
        })
        
# publishComposite 'cart', ->
#     {
#         find: ->
#             Docs.find
#                 type: 'cart_item'
#                 author_id: @userId            
#         children: [
#             { find: (cart_item) ->
#                 Docs.find cart_item.parent_id
#                 }
#             ]    
#     }            
    

Meteor.publish 'selected_users', (doc_id, key)->
    doc = Docs.findOne doc_id
    Meteor.users.find(_id: $in: doc["#{key}"])
