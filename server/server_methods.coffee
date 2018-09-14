Meteor.methods
    calculate_request_count: (doc_id)->
        request_count = Docs.find(service_id: doc_id).count()
        Docs.update doc_id, 
            $set: request_count: request_count

    create_user: (options)->
        new_id = Accounts.createUser options
        return new_id

    update_username:  (username) ->
        userId = Meteor.userId()
        if not userId
            throw new Meteor.Error(401, "Unauthorized")
        Accounts.setUsername(userId, username)
        return "Updated Username: #{username}"
        
        
    update_email: (new_email) ->
        userId = Meteor.userId();
        if !userId
            throw new Meteor.Error(401, "Unauthorized");
        Accounts.addEmail(userId, new_email)
        return "Updated Email to #{new_email}"
        
    tagify_timestamp: (doc_id)->
        doc = Docs.findOne doc_id
        if doc
            timestamp = doc.timestamp
            # minute = moment(timestamp).minute()
            # hour = moment(timestamp).format('h')
            date = moment(timestamp).format('Do')
            ampm = moment(timestamp).format('a')
            weekdaynum = moment(timestamp).isoWeekday()
            weekday = moment().isoWeekday(weekdaynum).format('dddd')
    
            month = moment(timestamp).format('MMMM')
            year = moment(timestamp).format('YYYY')
    
            date_array = [ampm, weekday, month, date, year]
            date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
            Docs.update doc_id,
                $set: timestamp_tags: date_array
            return date_array


    verify_email: (user_id)->
        Accounts.sendVerificationEmail(user_id)        
        
    
    # update_location: (doc_id, result)->
    #     location_tags = (component.long_name for component in result.address_components)
    #     parts = result.address_components
        
    #     geocode = {}
    #     for part in parts
    #         geocode["#{part.types[0]}"] = part.short_name 
    #     geocode['formatted_address'] = result.formatted_address
    #     # # street_address = _.where(parts, {types:[ 'street_number' ]})
    #     # street_address = parts[0].short_name

    #     lowered_location_tags = _.map(location_tags, (tag)->
    #         tag.toLowerCase()
    #         )


    #     doc = Docs.findOne doc_id
    #     tags_without_address = _.difference(doc.tags, doc.location_tags)
    #     tags_with_new = _.union(tags_without_address, lowered_location_tags)

    #     Docs.update doc_id,
    #         $set:
    #             tags:tags_with_new
    #             location_ob:result
    #             location_tags:lowered_location_tags
    #             geocode:geocode
    #             location_lat: result.lat
    #             location_lng: result.lng
                
                
    assign_user: (doc_id, user)->
        doc = Docs.findOne doc_id
        Docs.update doc_id,
            $addToSet: assigned_to: user._id
        Docs.insert
            type:'event'
            parent_id: doc_id
            event_type: 'assignment'
            text: "#{user.username} was assigned to #{doc.type}"
        
    user_array_add: (doc_id, key, user)->
        doc = Docs.findOne doc_id
        Docs.update doc_id,
            $addToSet: "#{key}": user._id
        Docs.insert
            type:'event'
            parent_id: doc_id
            event_key: key
            text: "#{user.username} was added to #{key} on #{doc.type}"
        
        
    user_array_pull: (doc_id, key, user)->
        doc = Docs.findOne doc_id
        Docs.update doc_id,
            $pull: "#{key}": user._id
        Docs.insert
            type:'event'
            parent_id: doc_id
            event_key: key
            text: "#{user.username} was removed from #{key}."
        
        
    link_doc: (doc_id, key, doc)->
        # doc = Docs.findOne doc_id
        if key is 'customer_id'
            Docs.update doc_id,
                $set: 
                    "#{key}": doc._id
                    customer_name: doc.cust_name
                    customer_jpid: doc.jpid
        else            
            Docs.update doc_id,
                $set: "#{key}": doc._id
        Docs.insert
            type:'event'
            parent_id: doc_id
            event_key: key
            text: "#{doc.text} was added to #{key} on #{doc.type}"
        
        
    unlink_doc: (doc_id, key, doc)->
        doc = Docs.findOne doc_id
        Docs.update doc_id,
            $unset: "#{key}": 1
        Docs.insert
            type:'event'
            parent_id: doc_id
            event_key: key
            text: "#{doc.text} was removed from #{key}."
        
        
    
    unassign_user: (doc_id, user)->
        doc = Docs.findOne doc_id
        Docs.update doc_id,
            $pull: assigned_to: user._id
        Docs.insert
            type:'event'
            parent_id: doc_id
            event_type: 'assignment'
            text: "#{user.username} was unassigned from #{doc.type}"
        
        
    create_event: (parent_id, event_type, action)->
        if parent_id
            Docs.insert
                type:'event'
                parent_id: parent_id
                event_type: event_type
                action:action
        else
            Docs.insert
                type:'event'
                parent_id: parent_id
                event_type: event_type
                action:action

    create_incident_event: (incident_doc_id, event_type, action)->
        incident = Docs.findOne incident_doc_id
        office_doc = Meteor.call 'find_office_from_customer_jpid', incident.ev.ID
        franchisee_doc = Meteor.call 'find_franchisee_from_customer_jpid', incident.ev.ID
        Docs.insert
            type:'event'
            parent_id: incident_doc_id
            event_type: event_type
            action:action
            office_jpid: office_doc.ev.ID
            franchisee_jpid: franchisee_doc.ev.ID

    set_incident_level: (target_id, event_type, level)->
        doc = Docs.findOne target_id
        current_user = Meteor.users.findOne @userId
        if doc
            Docs.update { target_id },
                $set: level: level
            Docs.insert
                type:'event'
                parent_id: target_id
                event_type: 'change_level'
                text: "#{current_user.username} changed level to #{level}"


    create_alert: (type, parent_id, comment_id)->
        doc = Docs.findOne comment_id
        if type is 'comment'
            new_alert_id = 
                Docs.insert
                    type:'event'
                    event_type:'comment'
                    parent_id:parent_id
                    comment_id:comment_id
                    text: "#{doc.author().username} commented #{doc.text}."
            return new_alert_id
        else
          throw new Meteor.Error 'unknown_type', 'unknown alert type'
          
          
    # mark_read: (doc_id)-> Docs.update doc_id, $addToSet: read_by: Meteor.userId()
    # mark_unread: (doc_id)-> Docs.update doc_id, $pull: read_by: Meteor.userId()
          
          

    check_username: (username)->
        found_user = Accounts.findUserByUsername username
        found_user
    
    check_email: (email)->
        found_user = Accounts.findUserByEmail email
        found_user


    add_role_to_user: (userid, role)->
        Meteor.users.update userid,
            $addToSet: roles: role
        user = Meteor.users.findOne userid
        Meteor.call 'create_event', userid, 'add role to user', "#{role} was added to #{user.username}."


    send_password_reset_email_by_username: (username)->
        found_user = Accounts.findUserByUsername(username)
        sent = Accounts.sendResetPasswordEmail(found_user._id)
        return sent
        
    send_password_reset_email_by_email: (email)->
        found_user = Accounts.findUserByEmail(email)
        sent = Accounts.sendResetPasswordEmail(found_user._id)
        return sent
        
        
        
    count_current_incident_number: ->
        incident_count = Docs.find(type:'incident').count()
        return incident_count
        
        
    find_customer_by_jpid: (customer_jpid)->
        found = 
            Docs.findOne
                type:'customer'
                "ev.ID":customer_jpid
        if found
            return found
        else
            throw new Meteor.Error 'customer_not_found', "Customer not found with JPID #{customer_jpid}."

    find_office_from_customer_jpid: (customer_jpid)->     
        customer_doc = Docs.findOne
            "ev.ID": customer_jpid
            type:'customer'
        if customer_doc
            found_office = Docs.findOne
                "ev.MASTER_LICENSEE": customer_doc.ev.MASTER_LICENSEE
                type:'office'
            return found_office
        else 
            throw new Meteor.Error 'no_office_from_customer_jpid', "couldnt find office from customer #{customer_jpid}"
            
         
         
    find_franchisee_from_customer_jpid: (customer_jpid)->
        customer_doc = Docs.findOne
            "ev.ID": customer_jpid
            type:'customer'
        console.log customer_doc
        if customer_doc and customer_doc.ev.FRANCHISEE
            found_franchisee = Docs.findOne
                "ev.FRANCHISEE": customer_doc.ev.FRANCHISEE
                type: 'franchisee'
            return found_franchisee
        

         
    find_office_from_jpid: (office_jpid)->     
        office_doc = Docs.findOne
            "ev.ID": office_jpid
            type:'office'
        office_doc
            
    redirect_office_after_login: ()->     
        res = {}
        user = Meteor.user()
        if user
            office_doc = Docs.findOne
                "ev.ID": user.office_jpid
                type:'office'
            res.office = office_doc
            res.user = user
            return res            
            
    add_to_cart: (doc_id)->
        product = Docs.findOne doc_id
        Docs.insert
            type: 'cart_item'
            product_id: doc_id
            product_title:product.title
            product_price:product.price
            amount: 1
    
    remove_from_cart: (doc_id)->
        Docs.remove doc_id
    
    
    refresh_customer_jpids: (username)->
        user = Meteor.users.findOne username:username
        if user and user.customer_jpid
            customer_doc = Docs.findOne
                "ev.ID": user.customer_jpid
                type:'customer'
        
        
        found_franchisee = Docs.findOne
            type: 'franchisee'
            "ev.FRANCHISEE": customer_doc.ev.FRANCHISEE
        
        found_office = Docs.findOne
            "ev.MASTER_LICENSEE": found_franchisee.ev.MASTER_LICENSEE
            type: 'office'

        Meteor.users.update user._id,
            $set:
                customer_jpid: customer_doc.ev.ID
                franchisee_jpid: found_franchisee.ev.ID
                office_jpid: found_office.ev.ID
                
                
    lookup_office_user: (office_name, username_query)->
        office_doc = Docs.findOne 
            type:'office'
            "ev.MASTER_LICENSEE":office_name
        found_users = 
            Meteor.users.find({
                "ev.COMPANY_NAME":office_doc.ev.MASTER_LICENSEE
                username: {$regex:"#{username_query}", $options: 'i'}
                }).fetch()
        found_users
        
    lookup_office_user_by_username_and_officename: (office_name, username_query)->
        office_doc = Docs.findOne 
            type:'office'
            "ev.MASTER_LICENSEE":office_name
        found_users = 
            Meteor.users.find({
                "ev.COMPANY_NAME":office_name
                username: {$regex:"#{username_query}", $options: 'i'}
                }).fetch()
        found_users
    
    
    lookup_office_user_by_username_and_office_jpid: (office_jpid, username_query)->
        office_doc = Docs.findOne 
            type:'office'
            "ev.ID":office_jpid
        found_users = 
            Meteor.users.find({
                "ev.COMPANY_NAME":office_doc.ev.MASTER_LICENSEE
                username: {$regex:"#{username_query}", $options: 'i'}
                }).fetch()
        found_users
    
    
    
    update_incident_numbers: ->
        unnumbered_count = Docs.find({
            type:'incident', 
            incident_number: $exists:false
        }).count()
        
        
    update_incident_number: (doc_id)->
        incident = Docs.findOne doc_id
        unnumbered_incidents = Docs.find({type:'incident', incident_number:{$exists:false}}).count()
        Docs.update doc_id,
            $set:incident_number:unnumbered_incidents
            
    create_complete_task_event: (task_id)->
        Docs.insert
            type:'event'
            event_type:'mark_complete'
            doc_type:'task'
            parent_id:task_id
            text:"Task was marked complete by #{Meteor.user().username}."
            
    create_incomplete_task_event: (task_id)->
        Docs.insert
            type:'event'
            event_type:'mark_incomplete'
            doc_type:'task'
            parent_id:task_id
            text:"Task was marked incomplete by #{Meteor.user().username}."


Meteor.methods
    update_field_title: (doc_id, field_object, title)->
        Docs.update { _id:doc_id, fields:field_object },
            { $set: "fields.$.title": title }

    update_field_slug: (doc_id, field_object, slug)->
        # console.log doc_id
        # console.log field_object
        # console.log slug
        Docs.update { _id:doc_id, fields:field_object },
            { $set: "fields.$.slug": slug }

    pull_schema_field: (schema_doc_id, field_object)->
        # console.log doc_id
        # console.log field_object
        # console.log slug
        Docs.update { _id:schema_doc_id },
            { $pull: "fields": field_object }


    update_field_key_value: (doc_id, field_object, key, value)->
        # console.log 'updating field', field_object, key
        # console.log value
        Docs.update { _id:doc_id, fields:field_object },
            { $set: "fields.$.#{key}": value }



    slugify: (doc_id, field_object, title)->
        slug = title.toString().toLowerCase().replace(/\s+/g, '_').replace(/[^\w\-]+/g, '').replace(/\-\-+/g, '_').replace(/^-+/, '').replace(/-+$/,'')
        return slug
        # console.log field_object
        # console.log doc_id
        # # Docs.update { _id:doc_id, fields:field_object },
        # Docs.update { _id:doc_id, fields:field_object },
        #     { $set: "fields.$.slug": slug }
        
        
    update_sla_setting: (office_jpid, incident_type, escalation_number, key, value)->
        console.log 'trying to update sla setting'
        console.log office_jpid
        console.log incident_type
        console.log escalation_number
        console.log key
        console.log value
        
        sla_doc= Docs.update {
            type;'sla_setting'
            office_jpid:office_jpid
            incident_type:incident_type
            escalation_number:escalation_number
        }, { $set: "#{key}":value }, {upsert:true}
        if sla_doc
            console.log sla_doc