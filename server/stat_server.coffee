Meteor.publish 'stats', ->
    Stats.find()

Meteor.publish 'stat', (doc_type, stat_type)->
    Stats.find
        doc_type: doc_type
        stat_type: stat_type

Meteor.publish 'admin_total_stats', ()->
    Stats.find 
        stat_type:'total'

Meteor.publish 'active_customers_stat', (type)->
    Meteor.call 'calculate_active_customers'
    Stats.find
        doc_type: 'customer'
        stat_type: 'active'


Meteor.publish 'active_franchisees_stat', (type)->
    Meteor.call 'calculate_active_franchisees'
    Stats.find
        doc_type: 'franchisee'
        stat_type: 'active'



Meteor.publish 'count', (type)->
    Meteor.call 'calculate_doc_type_count', type
    Stats.find
        doc_type: type
        stat_type: 'total'

Meteor.publish 'my_incident_count', ()->
    user = Meteor.user()
    if user
        Meteor.call 'calculate_my_incidents_count'
        Stats.find
            doc_type: 'incident'
            stat_type: 'customer'
            customer_jpid: user.customer_jpid


Meteor.publish 'all_users_count', ()->
    Meteor.call 'calculate_all_users_count'
    Stats.find
        collection: 'users'
        stat_type: 'total'

Meteor.publish 'incomplete_task_count', ()->
    Meteor.call 'calculate_incomplete_task_count'
    Stats.find
        collection: 'doc'
        doc_type: 'task'
        stat_type: 'incomplete'

Meteor.publish 'office_stats', (office_doc_id)->
    office_doc = Docs.findOne office_doc_id
    Stats.find {
        office_jpid:office_doc.ev.ID
    }
    


Meteor.publish 'office_employee_count', (office_doc_id)->
    user = Meteor.user()
    Meteor.call 'calculate_office_employee_count', office_doc_id
    office_doc = Docs.findOne office_doc_id
    Stats.find {
        collection: 'users'
        stat_type: 'office_employees'
        office_jpid:office_doc.ev.ID
    }
    
Meteor.publish 'office_franchisee_count', (office_doc_id)->
    user = Meteor.user()
    Meteor.call 'calculate_office_franchisee_count', office_doc_id
    office_doc = Docs.findOne office_doc_id
    Stats.find {
        doc_type: 'franchisee'
        stat_type: 'office_franchisees'
        office_jpid:office_doc.ev.ID
    }
    
Meteor.publish 'office_incident_count', (office_doc_id)->
    user = Meteor.user()
    Meteor.call 'calculate_office_incident_count', office_doc_id
    office_doc = Docs.findOne office_doc_id
    Stats.find {
        doc_type: 'incident'
        stat_type: 'office_incidents'
        office_jpid:office_doc.ev.ID
    }

Meteor.publish 'office_customer_count', (office_doc_id)->
    Meteor.call 'calculate_office_customer_count', office_doc_id
    office_doc = Docs.findOne office_doc_id
    
    Stats.find {
        doc_type: 'customer'
        stat_type: 'office_customers'
        office_jpid:office_doc.ev.ID
    }

Meteor.publish 'event_type_count', (event_type)->
    Meteor.call 'calculate_event_type_count', event_type
    
    Stats.find {
        doc_type: 'event'
        stat_type: 'event_type'
        event_type:event_type
    }
    

Meteor.methods
    calculate_office_incident_count: (office_doc_id)->
        office_doc = Docs.findOne office_doc_id
        if office_doc
            office_incident_count = 
                Docs.find({
                    incident_office_name: office_doc.ev.MASTER_LICENSEE
                    type: "incident"
                }).count()
            Stats.update {
                doc_type: 'incident'
                stat_type: 'office_incidents'
                office_jpid:office_doc.ev.ID
            }, { $set:amount:office_incident_count },{upsert:true }


    calculate_office_franchisee_count: (office_doc_id)->
        office_doc = Docs.findOne office_doc_id
        if office_doc
            office_franchisee_count = 
                Docs.find({
                    "ev.MASTER_LICENSEE": office_doc.ev.MASTER_LICENSEE
                    "ev.ACCOUNT_STATUS": 'ACTIVE'
                    type: "franchisee"
                }).count()
            Stats.update {
                doc_type: 'franchisee'
                stat_type: 'office_franchisees'
                office_jpid:office_doc.ev.ID
            }, { $set:amount:office_franchisee_count },{upsert:true }
        
    calculate_office_customer_count: (office_doc_id)->
        office_doc = Docs.findOne office_doc_id
        if office_doc
            office_customer_count = 
                Docs.find({
                    "ev.MASTER_LICENSEE":office_doc.ev.MASTER_LICENSEE
                    "ev.ACCOUNT_STATUS": 'ACTIVE'
                    type:'customer'
                }).count()
            Stats.update({
                doc_type: 'customer'
                stat_type: 'office_customers'
                office_jpid:office_doc.ev.ID
            },{ $set:amount:office_customer_count },{upsert:true})
        
        
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
        
        
        
    calculate_doc_type_count: (type)->
        count = Docs.find(type:type).count()
        
        Stats.update({
            doc_type: type
            stat_type: 'total'
        }, { $set:amount:count },{ upsert:true })
    
    calculate_my_incidents_count: ()->
        user = Meteor.user()
        if user and user.customer_jpid
            count = 
                Docs.find({
                    customer_jpid: user.customer_jpid
                    type: 'incident'
                }).count()
        
            Stats.update({
                doc_type: 'incident'
                stat_type: 'customer'
                customer_jpid: user.customer_jpid
            }, { $set:amount:count },{ upsert:true })
        
        
        
    calculate_active_customers: ()->
        count = Docs.find(type:'customer', "ev.ACCOUNT_STATUS":'ACTIVE').count()
        Stats.update({
            doc_type: 'customer'
            stat_type: 'active'
        }, { $set:amount:count },{ upsert:true })
        
        
    calculate_active_franchisees: ()->
        count = Docs.find(type:'franchisee', "ev.ACCOUNT_STATUS":'ACTIVE').count()
        
        Stats.update({
            doc_type: 'franchisee'
            stat_type: 'active'
        }, { $set:amount:count },{ upsert:true })
        
        
        
    calculate_user_count: ()->
        count = Meteor.users().count()
        
        Stats.update {
            collection:'users'
            stat_type: 'total'
        }, { $set:amount:count },{ upsert:true }
        
        
        
        
    calc_office_stats: (office_doc_id)->
        office_doc = Docs.findOne office_doc_id
        if office_doc
            office_incident_count = 
                Docs.find({
                    incident_office_name: office_doc.ev.MASTER_LICENSEE
                    type: "incident"
                }).count()
            Stats.update {
                doc_type: 'incident'
                stat_type: 'office_incidents'
                office_jpid:office_doc.ev.ID
            }, { $set:amount:office_incident_count },{upsert:true }
            office_incident_count = 
                Docs.find({
                    incident_office_name: office_doc.ev.MASTER_LICENSEE
                    type: "incident"
                }).count()
            Stats.update {
                doc_type: 'incident'
                stat_type: 'office_incidents'
                office_jpid:office_doc.ev.ID
            }, { $set:amount:office_incident_count },{upsert:true }


    calculate_event_type_count: (event_type)->
        count = Docs.find(type:'event', event_type:event_type).count()
        
        Stats.update({
            doc_type: 'event'
            stat_type: 'event_type'
            event_type:event_type
        }, { $set:amount:count },{ upsert:true })
    
