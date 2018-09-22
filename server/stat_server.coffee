Meteor.publish 'stats', ->
    Stats.find()

# Meteor.publish 'stat', (doc_type, stat_type)->
Meteor.publish 'stat', (match_object)->
    Meteor.call 'calculate_stat', match_object
    Stats.find match_object


Meteor.publish 'count', (type)->
    Meteor.call 'calculate_doc_type_count', type
    Stats.find
        doc_type: type
        stat_type: 'total'



Meteor.publish 'all_users_count', ()->
    Meteor.call 'calculate_all_users_count'
    Stats.find
        collection: 'users'
        stat_type: 'total'



Meteor.publish 'office_employee_count', (office_jpid)->
    user = Meteor.user()
    Meteor.call 'calculate_office_employee_count', office_jpid
    office_doc = Docs.findOne "ev.ID":office_jpid
    Stats.find {
        collection: 'users'
        stat_type: 'office_employees'
        office_jpid:office_jpid
    }
    
    

Meteor.methods
    calculate_office_employee_count: (office_doc_id)->
        office_doc = Docs.findOne office_doc_id
        if office_doc
            office_employee_count = 
                Meteor.users.find({
                    "ev.COMPANY_NAME": office_doc.ev.MASTER_LICENSEE
                    }).count()
            Stats.update({
                collection: 'users'
                stat_type: 'office_employees'
                office_jpid:office_doc.ev.ID
            },{ $set:amount:office_employee_count },{upsert:true})
        
        
    calculate_all_users_count: ()->
        all_user_count = 
            Meteor.users.find({}).count()
        Stats.update({
            collection: 'users'
            stat_type: 'total'
        },{ $set:amount:all_user_count },{upsert:true})
        
        
        
    calculate_my_tickets_count: ()->
        user = Meteor.user()
        if user and user.customer_jpid
            count = 
                Docs.find({
                    customer_jpid: user.customer_jpid
                    type: 'ticket'
                }).count()
        
            Stats.update({
                doc_type: 'ticket'
                stat_type: 'customer'
                customer_jpid: user.customer_jpid
            }, { $set:amount:count },{ upsert:true })
        
        
        
    calculate_user_count: ()->
        count = Meteor.users().count()
        
        Stats.update {
            collection:'users'
            stat_type: 'total'
        }, { $set:amount:count },{ upsert:true }
        

    # calculate_stat: (doc_type, stat_type)->
    calculate_stat: (stat_match_object)->
        count_match_object = {}
        if stat_match_object
            if stat_match_object.stat_type and stat_match_object.stat_type is 'office'
                office_doc = Docs.findOne
                    type:'office'
                    "ev.ID":stat_match_object.jpid
                if office_doc
                    switch stat_match_object.doc_type
                        when 'ticket' then count_match_object.ticket_office_name = office_doc.ev.MASTER_LICENSEE
                        when 'franchisee' then count_match_object["ev.MASTER_LICENSEE"] = office_doc.ev.MASTER_LICENSEE
                        when 'customer' then count_match_object["ev.MASTER_LICENSEE"] = office_doc.ev.MASTER_LICENSEE
                # count_match_object["ev.ID"] = stat_match_object.jpid

            count_match_object.type = stat_match_object.doc_type
                    
            if stat_match_object.active and stat_match_object.active is true
                count_match_object["ev.ACCOUNT_STATUS"] = 'ACTIVE'
            count = 
                Docs.find(count_match_object).count()
            Stats.update(stat_match_object, { $set:amount:count },{ upsert:true })
    
