Meteor.publish 'type', (type)->
    Docs.find {type:type}, limit:300
        
        
# Meteor.publish 'my_customer_account_doc', ->
#     if Meteor.user()
#         cust_id = Meteor.user().profile.customer_jpid
#         cursor = Docs.find jpid:cust_id
#         # console.log cursor.count()
#         cursor
        
Meteor.publish 'child_docs', (doc_id, limit)->
    # if limit
    #     Docs.find {parent_id: doc_id },
    #         limit:limit
    # else
    Docs.find parent_id: doc_id
        
Meteor.publish 'parent_doc', (child_id)->
    child =  Docs.findOne child_id
    Docs.find
        _id: child.parent_id
        
        

# Meteor.publish 'users', ()->
#     Meteor.users.find()
    
    
        
Meteor.publish 'has_key', (key)->
    Docs.find "ev.#{key}": $exists: true
    # Docs.find "ev.FRANCH_NAME": $exists: true
        
        
Meteor.publish 'has_key_value', (key, value)->
    # console.log key, value
    Docs.find "ev.#{key}": value
    # Docs.find "ev.FRANCH_NAME": $exists: true
        
        
        


publishComposite 'docs', (selected_tags, type)->
    {
        find: ->
            self = @
            match = {}
            if type then match.type = type
            # console.log match
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


publishComposite 'incidents', (level)->
    {
        find: ->
            self = @
            match = {}
            # match.current_level = parseInt(level)
            match.type = 'incident'
            # console.log match
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

Meteor.publish 'my_profile', ->
    Meteor.users.find @userId,
        fields:
            tags: 1
            profile: 1
            username: 1
            published: 1
            image_id: 1


Meteor.publish 'user', (username)->
    Meteor.users.find username:username,
        fields:
            profile: 1
            username: 1
            ev:1

Meteor.publish 'office_by_franchisee', (franch_id)->
    franch_doc = Docs.findOne franch_id
    # console.log 'franch_doc', franch_doc
    if franch_doc.ev
        found = Docs.find
            type:'office'
            office_name:franch_doc.ev.MASTER_LICENSEE
        # console.log found.count()
        return found
        

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

publishComposite 'me', ()->
    {
        find: -> 
            # console.log @userId
            Meteor.users.find @userId
        children: [
            {
                find: (user)-> 
                    # users customer account
                    # console.log 'current user?', user.profile
                    Docs.find
                        jpid: user.profile.customer_jpid
                children: [
                    {
                        find: (customer)-> 
                            # console.log 'finding franchisees for', customer
                            # parent incidents
                            Docs.find
                                customer_jpid: customer.jpid
                                type:'incident'
                    }
                    {
                        find: (customer)-> 
                            # console.log 'finding franchisees for', customer
                            # parent franchisee
                            Docs.find
                                franchisee: customer.franchisee
                                type:'franchisee'
                    }
                    {
                        find: (customer)-> 
                            # console.log 'finding special services for', customer
                            # special services
                            Docs.find
                                "ev.CUSTOMER": customer.cust_name
                                type:'special_service'
                    }
                    {
                        find: (customer)-> 
                            # grandparent office
                            Docs.find
                                office_name: customer.master_licensee
                                type:'office'
                        children: [
                            {
                                find: (office)-> 
                                    # offices users
                                    # console.log 'query users from office doc', office
                                    Meteor.users.find
                                        "profile.office_name": office.office_name
                            }
                        ]
                    }
                ]    
            }
        ]
    }
