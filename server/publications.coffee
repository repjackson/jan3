Meteor.publish 'type', (type, query=null, limit=100, sort_key='timestamp', sort_direction=1, skip=0)->
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

        

        
Meteor.publish 'block_docs', (
    block_doc_id, 
    tags
    filter_key=null, 
    filter_value=null, 
    query=null, 
    limit=10, 
    sort_key='timestamp', 
    sort_direction=1, 
    skip=0,
    status
    page_jpid)->
        console.log 'block_doc_id', block_doc_id
        block = Docs.findOne block_doc_id
        page_doc = Docs.findOne "ev.ID":page_jpid
        match = {}
        match.type = block.children_doc_type
        if tags.length > 0 then match.tags = $all: tags
        if status then match["ev.ACCOUNT_STATUS"] = "ACTIVE"
        if query then match["$text"] = "$search":query
        # console.log limit
        console.log 'initial filter',filter_value
        calculated_value =
            switch filter_value
                # user
                when "{current_user_customer_jpid}" 
                    Meteor.user().customer_jpid
                when "{current_user_office_jpid}" 
                    Meteor.user().office_jpid
                when "{current_user_franchisee_jpid}" 
                    Meteor.user().franchisee_jpid
                when "{current_user_customer_name}"
                    found_customer = Docs.findOne
                        type:'customer'
                        "ev.ID":Meteor.user().customer_jpid
                    found_customer.ev.CUST_NAME
                when "{current_user_office_name}"
                    found_office = Docs.findOne
                        type:'office'
                        "ev.ID":Meteor.user().office_jpid
                    found_office.ev.MASTER_LICENSEE
                when "{current_user_franchisee_name}"
                    found_franchisee = Docs.findOne
                        type:'franchisee'
                        "ev.ID":Meteor.user().franchisee_jpid
                    found_franchisee.ev.FRANCHISEE
                # page
                when "{current_page_jpid}" 
                    page_jpid
                when "{current_page_customer_name}"
                    if page_doc
                        console.log page_doc.ev.CUST_NAME
                        page_doc.ev.CUST_NAME
                when "{current_page_office_name}"
                    page_doc.ev.MASTER_LICENSEE
                when "{current_page_franchisee_name}"
                    if page_doc.ev.FRANCHISEE.length > 0
                        console.log 'returning page franch name', page_doc.ev.FRANCHISEE
                        page_doc.ev.FRANCHISEE
                    if page_doc.ev.FRANCHISEE.length is 0
                        console.log 'stopping blank franch query', page_doc.ev.FRANCHISEE
                        @stop()
                else filter_value
        if filter_key and calculated_value then match["#{filter_key}"] = calculated_value
        console.log 'calc value', calculated_value
        console.log 'match',match
        console.log 'prelimit', limit
        if -1 > limit > 100
            limit = 100
        console.log 'limit', limit
    
        Docs.find match,{
            skip: skip
            limit:limit
            sort:"#{sort_key}":parseInt("#{sort_direction}")
        }
            

Meteor.publish 'assigned_to_users', (incident_doc_id)->
    incident_doc = Docs.findOne incident_doc_id
    if incident_doc and incident_doc.assigned_to
        Meteor.users.find 
            _id: $in: incident_doc.assigned_to
        
        
Meteor.publish 'office_events', (office_doc_id)->
    Docs.find {type:'event'}, limit:10
        
        
        
# Meteor.publish 'my_customer_account_doc', ->
#     if Meteor.user()
#         cust_id = Meteor.user().customer_jpid
#         cursor = Docs.find jpid:cust_id
#         cursor
        
Meteor.publish 'users_feed', (username, limit=100, sort_key='timestamp', sort_direction=1, skip=0)->
    user = Meteor.users.findOne username:username
    Docs.find {
        type: 'event'
        author_id: user._id
    },{
            skip: skip
            limit:limit
            sort:"#{sort_key}":parseInt("#{sort_direction}")
        }
    
Meteor.publish 'events', (doc_type, limit=10, sort_key='timestamp', sort_direction=-1, skip=0)->
    Docs.find {
        type: 'event'
        doc_type:doc_type
    },{
            skip: skip
            limit:limit
            sort:"#{sort_key}":parseInt("#{sort_direction}")
        }
    
Meteor.publish 'all_users', (query, limit=100, sort_key='timestamp', sort_direction=1, skip=0)->
    if query 
        Meteor.users.find {
            $text: $search: query
        },{
            skip: skip
            limit:limit
            sort:"#{sort_key}":parseInt("#{sort_direction}")
        }
    else
        Meteor.users.find {
        },{
            skip: skip
            limit:limit
            sort:"#{sort_key}":parseInt("#{sort_direction}")
        }
    
    
    

Meteor.publish 'child_docs', (doc_id, limit)->
    if limit
        Docs.find {parent_id:doc_id}, {limit:limit, sort:timestamp:-1}
    else
        Docs.find parent_id:doc_id
        
Meteor.publish 'parent_doc', (child_id)->
    child =  Docs.findOne child_id
    Docs.find
        _id: child.parent_id
        
        
Meteor.publish 'has_key', (key)->
    Docs.find "ev.#{key}": $exists: true
    # Docs.find "ev.FRANCH_NAME": $exists: true
        
        
Meteor.publish 'has_key_value', (key, value)->
    Docs.find "ev.#{key}": value
    # Docs.find "ev.FRANCH_NAME": $exists: true
        
        

    
Meteor.publish 'static_office_employees', (office_jpid)->
    office_doc = Docs.findOne "ev.ID":office_jpid
    Meteor.users.find
        "profile.office_name": office_doc.ev.MASTER_LICENSEE

Meteor.publish 'office_employees', (office_jpid, query, limit=1000, sort_key='public', sort_direction=1, skip=0)->
    office_doc = Docs.findOne "ev.ID":office_jpid
    match = {}
    if query then match
    if query 
        Meteor.users.find {
            "ev.COMPANY_NAME": office_doc.ev.MASTER_LICENSEE
            $text: $search: query
        },{
            skip: skip
            limit:limit
            sort:"#{sort_key}":parseInt("#{sort_direction}")
        }
    else
        Meteor.users.find {
            "ev.COMPANY_NAME": office_doc.ev.MASTER_LICENSEE
        },{
            skip: skip
            limit:limit
            sort:"#{sort_key}":parseInt("#{sort_direction}")
        }
    

    
    

Meteor.publish 'users_docs',(username) ->
    user = Meteor.users.findOne username:username
    Docs.find({author_id: user._id}, {limit:20})
    
Meteor.publish 'user_events',(username) ->
    user = Meteor.users.findOne username:username
    if user
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
            
Meteor.publish 'author', (user_id)->
    Meteor.users.find user_id,
        fields:
            profile: 1
            username: 1
            # ev:1
            # published:1
            # customer_jpid:1
            # franchisee_jpid:1
            # office_jpid:1
            

# user connected accounts 
Meteor.publish 'my_customer_account', ->
    user = Meteor.user()
    if user and user.customer_jpid and user.roles and 'customer' in user.roles
        Docs.find
            "ev.ID": user.customer_jpid
            type:'customer'
        
Meteor.publish 'my_franchisee', ->
    user = Meteor.user()
    if user and user.franchisee_jpid and user.roles and 'customer' in user.roles
        Docs.find
            "ev.ID": user.franchisee_jpid
            type:'franchisee'
        
Meteor.publish 'my_office', ->
    user = Meteor.user()
    if user and user.office_jpid and user.roles and 'office' or 'customer' in user.roles
        console.log 'publishing office', user.office_jpid
        Docs.find
            "ev.ID": user.office_jpid
            type:'office'
    else
        console.log 'not publishing office', user.office_jpid
        
Meteor.publish 'my_special_services', ->
    user = Meteor.user()
    if user and user.customer_jpid
        customer_doc = Docs.findOne
            "ev.ID": user.customer_jpid
            type:'customer'
            # grandparent office
        Docs.find {
            type:'special_service'
            # "ev.CUSTOMER": customer_doc.ev.CUST_NAME
        }, limit: 5
    
Meteor.publish 'my_office_contacts', ()->    
    # console.log 'looking for office contacts'
    user = Meteor.user()
    if user
        if 'customer' in user.roles
            # console.log 'good?'
            if user.customer_jpid
                customer_doc = Docs.findOne
                    "ev.ID": user.customer_jpid
                    type:'customer'
                # console.log customer_doc
                Meteor.users.find {
                    published: true
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




# Meteor.publish 'userStatus', ->
#     Meteor.users.find { 'status.online': true }, 
#         fields: 
#             points: 1
#             tags: 1
            
            
            
# Meteor.publish 'user_status_notification', ->
#     Meteor.users.find('status.online': true).observe
#         added: (id) ->
#         removed: (id) ->



Meteor.publish 'block_children', (type)->
    Docs.find { type:type }, limit:5



Meteor.publish 'schema_doc', (child_doc_id)->
    doc = Docs.findOne child_doc_id
    Docs.find
        type:'schema'
        slug:doc.type

Meteor.publish 'schema_doc_by_type', (doc_type)->
    Docs.find
        type:'schema'
        slug:doc_type


Meteor.publish 'service_child_requests', (service_id)->
    Docs.find
        type:'service_request'
        service_id:service_id
        
        
    
    
Meteor.publish 'offices', (name_filter='', limit=100, sort_key='timestamp', sort_direction=1, skip=0)->
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
        
    

Meteor.publish 'assigned_users', (doc_id)->
    doc = Docs.findOne doc_id
    Meteor.users.find(_id: $in: doc.assigned_to)

Meteor.publish 'selected_users', (doc_id, key)->
    doc = Docs.findOne doc_id
    Meteor.users.find(_id: $in: doc["#{key}"])

Meteor.publish 'author_array', (author_array)->
    Meteor.users.find(_id: $in: author_array)

            
            
Meteor.publish 'blocks', (parent_id)->
    Docs.find   
        type:'block'
        parent_id:parent_id
            
Meteor.publish 'blocks_by_page_slug', (page_slug)->
    # parent = Docs.findOne 
    #     type:'page'
    #     slug:page_slug
    Docs.find   
        type:'block'
        parent_slug:page_slug
            
Meteor.publish 'events_by_type', (type)->
    Docs.find   
        type:'event'
        event_type:type
            
            
Meteor.publish 'admin_nav_pages', ()->
    Docs.find
        type:'page'
        admin_nav:true
            
Meteor.publish 'office_nav_pages', ()->
    Docs.find
        type:'page'
        office_nav:true
            
Meteor.publish 'customer_nav_pages', ()->
    Docs.find
        type:'page'
        customer_nav:true
            
            
Meteor.publish 'page_by_slug', (slug)->
    Docs.find
        type:'page'
        slug:slug
            
            
            
Meteor.publish 'doc_by_jpid', (jpid)->
    if jpid
        Docs.find
            "ev.ID":jpid