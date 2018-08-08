Meteor.publish 'count', (type)->
    Meteor.call 'calculate_doc_type_count', type
    Stats.find {
        doc_type: type
        stat_type: 'total'
    }

Meteor.publish 'my_incident_count', ()->
    user = Meteor.user()
    Meteor.call 'calculate_my_incidents_count'
    Stats.find {
        doc_type: 'incident'
        stat_type: 'customer'
        customer_jpid: user.customer_jpid
    }


Meteor.publish 'stats', ->
    Stats.find()



Meteor.publish 'office_customer_count', (office_doc_id)->
    console.log 'office customers', office_doc_id
    Meteor.call 'calculate_office_customer_count', office_doc_id

    Stats.find {
        doc_type: 'customer'
        stat_type: 'office_customers'
        office_jpid:office_doc.ev.ID
    }



Meteor.methods
    calculate_office_customer_count: (office_doc_id)->
        office_doc = Docs.findOne office_doc_id
        office_customer_count = 
            Docs.find({
                type:'customer'
                "ev.MASTER_LICENSEE":office_doc.ev.MASTER_LICENSEE
            }).count()
        console.log 'count', office_customer_count
        Stats.update {
            doc_type: 'customer'
            stat_type: 'office_customers'
            office_jpid:office_doc.ev.ID
        }, {
            $set:amount:count
        },{
            upsert:true
        }

        
    calculate_doc_type_count: (type)->
        count = Docs.find(type:type).count()
        # console.log count
        
        Stats.update {
            doc_type: type
            stat_type: 'total'
        }, {
            $set:amount:count
        },{
            upsert:true
        }
    
    calculate_my_incidents_count: ()->
        user = Meteor.user()
        if user and user.customer_jpid
            count = 
                Docs.find({
                    customer_jpid: user.customer_jpid
                    type: 'incident'
                }).count()
            console.log count
        
            Stats.update {
                doc_type: 'incident'
                stat_type: 'customer'
                customer_jpid: user.customer_jpid
            }, {
                $set:amount:count
            },{ upsert:true }
        
        
    calculate_office_customer_count: (type)->
        count = Docs.find(type:type).count()
        # console.log count
        
        Stats.update {
            doc_type: type
            stat_type: 'total'
        }, {
            $set:amount:count
        },{ upsert:true }
        
        
    calculate_active_customers: ()->
        count = Docs.find(type:'customer', "ev.ACCOUNT_STATUS":'active').count()
        # console.log count
        
        Stats.update {
            doc_type: 'customer'
            stat_type: 'active'
        }, {
            $set:amount:count
        },{
            upsert:true
        }
        
        
    calculate_active_franchisees: ()->
        count = Docs.find(type:'franchisee', "ev.ACCOUNT_STATUS":'active').count()
        # console.log count
        
        Stats.update {
            doc_type: 'franchisee'
            stat_type: 'active'
        }, {
            $set:amount:count
        },{
            upsert:true
        }
        
        
        
    calculate_user_count: ()->
        count = Meteor.users().count()
        # console.log count
        
        Stats.update {
            collection:'users'
            stat_type: 'total'
        }, {
            $set:amount:count
        },{
            upsert:true
        }
        
        
        
        
        