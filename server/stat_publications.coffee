Meteor.publish 'count', (type)->
    Meteor.call 'calculate_doc_type_count', type
    Stats.find {
        doc_type: type
        stat_type: 'total'
    }
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