Meteor.publish 'type', (type, limit)->
    if limit
        limit_val = limit
    else
        limit_val = 400
    Docs.find {type:type, archive:$ne:true},
        {
            limit:limit_val
            sort: timestamp:-1
        }

Meteor.publish 'my_bookmarks', ->
    Docs.find
        bookmark_ids:$in:[Meteor.userId()]

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

Meteor.publish 'customer_jpid', (jpid)->
    console.log jpid
    Docs.find
        type:'customer'
        customer_jpid: jpid


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

# Meteor.users.find({ "status.online": true }).observe
#     added: (id)->
#         console.log id, 'came online'
#     removed: (id)->
#         console.log id, 'went offline'


Meteor.publish "user_status", ()->
    Meteor.users.find({ "status.online": true })




Meteor.publish 'children', (doc_id, limit)->
    if limit
        Docs.find {parent_id:doc_id}, {limit:limit, sort:timestamp:-1}
    else
        Docs.find parent_id:doc_id

Meteor.publish 'parent_doc', (child_id)->
    child =  Docs.findOne child_id
    Docs.find
        _id: child.parent_id


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


Meteor.publish 'me', ->
    Meteor.users.find @userId

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

    # Meteor.users.find {}, limit:5


Meteor.publish 'doc', (id)-> Docs.find id


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
    if doc and doc.assigned_to
        Meteor.users.find(_id: $in: doc.assigned_to)

Meteor.publish 'selected_users', (doc_id, key)->
    doc = Docs.findOne doc_id
    Meteor.users.find(_id: $in: doc["#{key}"])

Meteor.publish 'author_array', (author_array)->
    Meteor.users.find(_id: $in: author_array)


Meteor.publish 'events_by_type', (type)->
    Docs.find
        type:'event'
        event_type:type



Meteor.publish 'doc_by_jpid', (jpid)->
    if jpid
        if typeof jpid is 'number'
            Docs.find
                jpid:jpid.toString()
        else
            Docs.find
                jpid:jpid


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