Meteor.publish 'stats', ->
    Stats.find()

# Meteor.publish 'stat', (doc_type, stat_type)->
Meteor.publish 'stat', (match_object)->
    Meteor.call 'calculate_stat', match_object
    Stats.find match_object, limit:100


Meteor.publish 'count', (type)->
    Meteor.call 'calculate_doc_type_count', type
    Stats.find
        doc_type: type
        stat_type: 'total'

Meteor.publish 'admin_stats', ()->
    Meteor.call 'calculate_admin_stats'
    Stats.find
        stat_type: 'admin'



Meteor.publish 'all_users_count', ()->
    Meteor.call 'calculate_all_users_count'
    Stats.find
        collection: 'users'
        stat_type: 'total'


Meteor.publish 'office_stats', (jpid)->
    Meteor.call 'calculate_office_stats', jpid
    Stats.find
        office_jpid: jpid




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
            return

    calculate_all_users_count: ()->
        all_user_count =
            Meteor.users.find({}).count()
        Stats.update({
            collection: 'users'
            stat_type: 'total'
        },{ $set:amount:all_user_count },{upsert:true})
        return


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
            return
        return


    calculate_user_count: ()->
        count = Meteor.users().count()

        Stats.update {
            collection:'users'
            stat_type: 'total'
        }, { $set:amount:count },{ upsert:true }
        return

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

            return

    calculate_office_stats: (jpid)->
        office_doc =
            Docs.findOne
                "ev.ID":jpid
                type:'office'
        if office_doc

            customer_count_query = {
                "ev.MASTER_LICENSEE":office_doc.ev.MASTER_LICENSEE
                type:'customer'
            }
            customer_count =
                Docs.find(customer_count_query).count()

            stat_match_object = customer_count_query
            stat_match_object['name'] = 'office_total_active_customers'
            stat_match_object['office_jpid'] = jpid
            Stats.update(stat_match_object,
                { $set:count:customer_count },
                { upsert:true })
            stat = Stats.findOne stat_match_object


            franchisee_count_query = {
                "ev.MASTER_LICENSEE":office_doc.ev.MASTER_LICENSEE
                type:'franchisee'
            }
            franchisee_count =
                Docs.find(franchisee_count_query).count()

            stat_match_object = franchisee_count_query
            stat_match_object['name'] = 'office_total_active_franchisees'
            stat_match_object['office_jpid'] = jpid
            Stats.update(stat_match_object,
                { $set:count:franchisee_count },
                { upsert:true })
            stat = Stats.findOne stat_match_object


            # tickets
            levels = [1,2,3,4]
            for number in levels
                ticket_count_query = {
                    office_jpid:jpid
                    type:'ticket'
                    level:number
                }
                ticket_count =
                    Docs.find(ticket_count_query).count()

                stat_match_object = ticket_count_query
                stat_match_object['name'] = "office_level_#{number}_tickets"
                stat_match_object['office_jpid'] = jpid
                Stats.update(stat_match_object,
                    { $set:count:ticket_count },
                    { upsert:true })
                # stat = Stats.findOne stat_match_object

                return


        # franchisee count
        # ticket count per level
        # rank customers per ticket level/type




    calculate_admin_stats: ->
        types = ['customer','office','franchisee','ticket']
        for doc_type in types
            current_query = {type:doc_type}
            total_count = Docs.find(current_query).count()

            stat_match_object = current_query
            stat_match_object['stat_type'] = 'admin'
            stat_match_object['name'] = "total_#{doc_type}s"

            Stats.update(stat_match_object,
                { $set:count:total_count },
                { upsert:true })
            return


    log_stats: ->
        types = ['customer','office','franchisee','ticket']
        for doc_type in types
            current_query = {type:doc_type}
            total_count = Docs.find(current_query).count()

            stat_log_object = current_query
            stat_log_object['type'] = 'stat_log'
            stat_log_object['name'] = "total_#{doc_type}s"
            stat_log_object['count'] = total_count
            stat_log_object['timestamp'] = Date.now()

            Stats.insert(stat_log_object)
            return