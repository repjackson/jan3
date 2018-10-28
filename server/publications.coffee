Meteor.publish 'type', (type, limit)->
    if limit
        limit_val = limit
    else
        limit_val = 100
    Docs.find {type:type},
        {
            limit:limit_val
            sort: timestamp:-1
        }


Meteor.publish 'single_doc', (doc_id)->
    Docs.find doc_id


Meteor.publish 'assigned_to_users', (ticket_doc_id)->
    ticket_doc = Docs.findOne ticket_doc_id
    if ticket_doc and ticket_doc.assigned_to
        Meteor.users.find
            _id: $in: ticket_doc.assigned_to




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
                "ev.ID": user.customer_jpid
                type:'customer'

Meteor.publish 'my_franchisee', ->
    user = Meteor.user()
    if user and user.franchisee_jpid and user.roles
        if 'customer' in user.roles
            Docs.find
                "ev.ID": user.franchisee_jpid
                type:'franchisee'

Meteor.publish 'my_office', ->
    user = Meteor.user()
    if user
        if user.office_jpid and user.roles
            if 'office' or 'customer' in user.roles
                Docs.find
                    "ev.ID": user.office_jpid
                    type:'office'



publishComposite 'doc', (id)->
    {
        find: -> Docs.find id
        children: [
            {
                find: (doc)-> Meteor.users.find _id:doc.author_id
            }
        ]
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
                        "ev.ID": ticket.customer_jpid

            }
            {
                find: (ticket)->
                    Docs.find
                        "ev.ID": ticket.office_jpid
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
    }
Meteor.publish 'comments', (doc_id)->
    Docs.find
        parent_id: doc_id
        type:'comment'




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




Meteor.publish 'doc_by_jpid', (jpid)->
    if jpid
        if typeof jpid is 'number'
            Docs.find
                "ev.ID":jpid.toString()
        else
            Docs.find
                "ev.ID":jpid

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
    office_doc = Docs.findOne "ev.ID":ticket.office_jpid
    Meteor.users.find
        "ev.COMPANY_NAME": office_doc.ev.MASTER_LICENSEE


Meteor.publish 'feedback_doc', (ticket_id)->
    Docs.find
        type:'feedback'
        parent_id: ticket_id



Meteor.publish 'inbox', ->
    user = Meteor.user()
    if Meteor.user()
        Docs.find {
            type:'message'
            to:Meteor.user().username
        }, limit:20


Meteor.publish 'outbox', ->
    user = Meteor.user()
    if Meteor.user()
        Docs.find {
            type:'message'
            author_username:Meteor.user().username
        }, limit:20