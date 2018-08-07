Meteor.publish 'count', (type)->
    Meteor.call 'calculate_doc_type_count', type
    Stats.find {
        doc_type: type
        stat_type: 'total'
    }



Meteor.publish 'stats', ->
    Stats.find()

Meteor.methods
    'calculate_doc_type_count': (type)->
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
        
        
    'calculate_active_customers': ()->
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
        
        
    'calculate_active_franchisees': ()->
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
        
        
        
    'calculate_user_count': ()->
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
        
        
        
        
        
