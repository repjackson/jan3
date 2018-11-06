Meteor.publish 'type', (type, limit)->
    if limit
        limit_val = limit
    else
        limit_val = 400
    Docs.find {type:type},
        {
            limit:limit_val
            sort: timestamp:-1
        }


Meteor.publish 'office_jpid', (jpid)->
    console.log jpid
    Docs.find
        type:'office'
        office_jpid: jpid

Meteor.publish 'franchisee_jpid', (jpid)->
    console.log jpid
    Docs.find
        type:'franchisee'
        franchisee_jpid: jpid


Meteor.publish 'block_children', (
    block_doc_id,
    filter_key=null,
    filter_value=null,
    query=null,
    limit=10,
    sort_key='timestamp',
    sort_direction=1,
    skip=0,
    status
    page_jpid
    query_params
    doc_id
    )->
        block = Docs.findOne block_doc_id
        collection = if block.children_collection is 'users' then "Meteor.users" else "Docs"
        if block.filter_source
            if block.filter_source is "{page_slug}"
                filter_source_doc = Docs.findOne jpid:page_jpid
            else if block.filter_source is "{doc_id}"
                filter_source_doc = Docs.findOne doc_id
            else if block.filter_source is "{current_user}"
                filter_source_doc = Meteor.user()
        if page_jpid
            doc_object = Docs.findOne jpid:page_jpid
        else if doc_id
            doc_object = Docs.findOne doc_id
        # else

        match = {}
        unless block.children_collection is 'users'
            match.type = block.children_doc_type
        if status then match["ev.ACCOUNT_STATUS"] = "ACTIVE"
        if query then match["$text"] = "$search":query
        # if block.children_doc_type is 'event'
        calculated_value =
            switch filter_value
                when "{source_key}"
                    if filter_source_doc
                        if block.filter_key_ev_subset
                            result = filter_source_doc.ev["#{block.filter_source_key}"]
                        else
                            result = filter_source_doc["#{block.filter_source_key}"]
                        # if block.children_doc_type is 'event'
                        result
                    else
                when "{current_user_customer_name}"
                    if Meteor.user()
                        found_customer = Docs.findOne
                            type:'customer'
                            customer_jpid:Meteor.user().customer_jpid
                        found_customer.ev.CUST_NAME
                when "{current_user_office_name}"
                    if Meteor.user()
                        found_office = Docs.findOne
                            type:'office'
                            office_jpid:Meteor.user().office_jpid
                        found_office.ev.MASTER_LICENSEE
                when "{current_user_franchisee_name}"
                    found_franchisee = Docs.findOne
                        type:'franchisee'
                        franchisee_jpid:Meteor.user().franchisee_jpid
                    found_franchisee.ev.FRANCHISEE
                # user
                when "{current_user_customer_jpid}"
                    Meteor.user().customer_jpid
                when "{current_user_office_jpid}"
                    Meteor.user().office_jpid
                when "{current_user_franchisee_jpid}"
                    Meteor.user().franchisee_jpid
                # page
                when "{current_page_jpid}"
                    if page_jpid
                        page_jpid
                when "{current_page_doc_id}"
                    if doc_id
                        doc_id
                # when "{current_page_customer_name}"
                #     if doc_object
                #         if doc_object.ev.CUST_NAME.length > 0
                #             doc_object.ev.CUST_NAME
                #         if doc_object.ev.CUST_NAME.length is 0
                #             @stop()
                when "{current_page_office_name}"
                    # if doc_object
                    #     if doc_object.ev.MASTER_LICENSEE.length > 0
                    #         doc_object.ev.MASTER_LICENSEE
                    #     if doc_object.ev.MASTER_LICENSEE.length is 0
                    #         @stop()
                    doc_object.ev.MASTER_LICENSEE
                when "{current_page_franchisee_name}"
                    if doc_object
                        if doc_object.ev.FRANCHISEE.length > 0
                            doc_object.ev.FRANCHISEE
                        if doc_object.ev.FRANCHISEE.length is 0
                            @stop()
                else filter_value
        if filter_key and calculated_value then match["#{filter_key}"] = calculated_value
        # if block.children_doc_type is 'event'
        user = Meteor.user()

        if block.children_collection
            unless block.children_collection is 'users'
                if user and user.roles
                    # unless 'customer' in user.roles
                    match.submitted = $ne: false

        if -1 > limit > 100
            limit = 100

        if block.context is 'link'
            match = "#{block.source_key}": query_params["#{block.query_param1}"]
            if block.source_collection is 'users'
                source =
                    Meteor.users.findOne match
            else
                source =
                    Docs.findOne
                        type: block.children_doc_type
                        # fix
                        # "#{block.target_key}":
            source_value = source["#{block.source_match_key}"]
            source_match = {}
            source_match["#{block.target_key}"] = source_value
            source_match.type = block.source_match_type
            if block.target_collection is 'docs'
                cursor = Docs.find source_match
                return cursor
                @stop

        else if block.context is 'direct'
            match = query_params
        if block.children_collection is 'users'
            cursor = Meteor.users.find match,{
                skip: skip
                limit:limit
                sort:"#{sort_key}":parseInt("#{sort_direction}")
            }
            cursor
        # else if block.children_collection is 'stats'
        #     cursor = Stats.find match,{
        #         skip: skip
        #         limit:limit
        #         sort:"#{sort_key}":parseInt("#{sort_direction}")
        #     }
        #     cursor
        else
            Docs.find match,{
                skip: skip
                limit:limit
                sort:"#{sort_key}":parseInt("#{sort_direction}")
            }


Meteor.publish 'assigned_to_users', (ticket_doc_id)->
    ticket_doc = Docs.findOne ticket_doc_id
    if ticket_doc and ticket_doc.assigned_to
        Meteor.users.find
            _id: $in: ticket_doc.assigned_to



Meteor.publish 'nav_items', ->
    user = Meteor.user()
    if user
        if user.roles
            if 'customer' in Meteor.user().roles then key='customer_nav'
            if 'office' in Meteor.user().roles then key='office_nav'
            if 'admin' in Meteor.user().roles then key='admin_nav'

            Docs.find
                type:'page'
                "#{key}":true

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
    office_doc = Docs.findOne "jpid":office_jpid
    Meteor.users.find
        "office_name": office_doc.ev.MASTER_LICENSEE



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
    Meteor.users.find username:username
        # fields:
        #     profile: 1
        #     username: 1
        #     ev:1
        #     published:1
        #     customer_jpid:1
        #     franchisee_jpid:1
        #     office_jpid:1

Meteor.publish 'user_profile', (user_id)->
    Meteor.users.find user_id

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
    if user and user.customer_jpid and user.roles
        if 'customer' in user.roles
            Docs.find
                "jpid": user.customer_jpid
                type:'customer'

Meteor.publish 'my_franchisee', ->
    user = Meteor.user()
    if user and user.franchisee_jpid and user.roles
        if 'customer' in user.roles
            Docs.find
                jpid: user.franchisee_jpid
                type:'franchisee'

Meteor.publish 'my_office', ->
    user = Meteor.user()
    if user
        if user.office_jpid and user.roles
            if 'office' or 'customer' in user.roles
                Docs.find
                    office_jpid: user.office_jpid
                    type:'office'

Meteor.publish 'my_special_services', ->
    user = Meteor.user()
    if user and user.customer_jpid
        customer_doc = Docs.findOne
            jpid: user.customer_jpid
            type:'customer'
            # grandparent office
        Docs.find {
            type:'special_service'
            # "ev.CUSTOMER": customer_doc.ev.CUST_NAME
        }, limit: 5

Meteor.publish 'my_office_contacts', ()->
    # user = Meteor.user()
    # if Meteor.user()
    #     if Meteor.user().customer_jpid
    #         customer_doc = Docs.findOne
    #             jpid: Meteor.user().customer_jpid
    #             type:'customer'
    #         Meteor.users.find {
    #             # published: true
    #             office_jpid: customer_doc.office_jpid
    #         }

    Meteor.users.find {}, limit:5

publishComposite 'doc', (id)->
    {
        find: -> Docs.find id
        # children: [
        #     {
        #         find: (doc)-> Meteor.users.find _id:doc.author_id
        #     }
        #     {
        #         find: (doc)->
        #             Docs.find
        #                 type:'office'
        #                 jpid:doc.office_jpid
        #     }
        #     {
        #         find: (doc)->
        #             Docs.find
        #                 type:'customer'
        #                 jpid:doc.customer_jpid
        #     }
        #     {
        #         find: (doc)-> Docs.find _id:doc.parent_id
        #     }
        # ]
    }


publishComposite 'ticket', (id)->
    {
        find: -> Docs.find id
        children: [
            {
                find: (ticket)-> Meteor.users.find _id:ticket.author_id
            }
            {
                find: (ticket)->
                    # customer doc
                    Docs.find
                        type:'customer'
                        jpid: ticket.customer_jpid

            }
            {
                find: (ticket)->
                    Docs.find
                        jpid: ticket.office_jpid
                        type:'office'

            }
            # {
            #     find: (ticket)-> Docs.find _id:doc.referenced_customer_id
            # }
            {
                find: (ticket)->
                    Docs.find
                        type:'feedback'
                        parent_id:ticket._id
            }
        ]
    }



publishComposite 'me', ()->
    {
        find: ->
            Meteor.users.find @userId
        # children: [
        #     {
        #         find: (user)->
        #             # users customer account
        #             if user.profile
        #                 if user.customer_jpid
        #                     Docs.find
        #                         jpid: user.customer_jpid
        #                         type:'customer'
        #                 if user.office_jpid
        #                     Docs.find
        #                         jpid: user.office_jpid
        #                         type:'office'

        #         # children: [
        #         #     # {
        #         #     #     find: (customer)->
        #         #     #         # parent tickets
        #         #     #         Docs.find
        #         #     #             customer_jpid: customer.jpid
        #         #     #             type:'ticket'
        #         #     # }
        #         #     # {
        #         #     #     find: (customer)->
        #         #     #         # parent franchisee
        #         #     #         Docs.find
        #         #     #             franchisee: customer.franchisee
        #         #     #             type:'franchisee'
        #         #     # }
        #         #     # {
        #         #     #     find: (customer)->
        #         #     #         # special services
        #         #     #         Docs.find
        #         #     #             "ev.CUSTOMER": customer.cust_name
        #         #     #             type:'special_service'
        #         #     # }
        #         #     # {
        #         #     #     find: (customer)->
        #         #     #         # grandparent office
        #         #     #         Docs.find
        #         #     #             # "ev.MASTER_LICENSEE": customer.ev.MASTER_LICENSEE
        #         #     #             type:'office'
        #         #     #     # children: [
        #         #     #     #     {
        #         #     #     #         find: (office)->
        #         #     #     #             # offices users
        #         #     #     #             # Meteor.users.find
        #         #     #     #             #     "office_name": office.ev.MASTER_OFFICE_NAME
        #         #     #     #     }
        #         #     #     # ]
        #         #     # }
        #         # ]
        #     }
        # ]
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




Meteor.publish 'schema_doc', (child_doc_id)->
    doc = Docs.findOne child_doc_id
    if doc
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




Meteor.publish 'page_by_slug', (slug)->
    Docs.find
        type:'page'
        slug:slug


Meteor.publish 'doc_by_jpid', (jpid)->
    if jpid
        if typeof jpid is 'number'
            Docs.find
                jpid:jpid.toString()
        else
            Docs.find
                jpid:jpid

Meteor.publish 'block_field_docs', (block_doc_id)->
    Docs.find
        block_id:block_doc_id
        type:'display_field'

Meteor.publish 'office_sla_settings', (jpid)->
    Docs.find
        type:'sla_setting'
        office_jpid:jpid


Meteor.publish 'my_office_messages', ()->
    if Meteor.user()
        if Meteor.user().office_jpid
            Docs.find
                type:'office_message'
                office_jpid: Meteor.user().office_jpid






Meteor.publish 'ticket_sla_docs', (ticket_doc_id)->
    ticket = Docs.findOne ticket_doc_id
    Docs.find
        type:'sla_setting'
        office_jpid:ticket.office_jpid
        ticket_type:ticket.ticket_type


Meteor.publish 'office_employees_from_ticket_doc_id', (ticket_doc_id)->
    ticket = Docs.findOne ticket_doc_id
    office_doc = Docs.findOne jpid:ticket.office_jpid
    Meteor.users.find
        "ev.COMPANY_NAME": office_doc.ev.MASTER_LICENSEE


Meteor.publish 'feedback_doc', (ticket_id)->
    Docs.find
        type:'feedback'
        parent_id: ticket_id