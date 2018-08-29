Meteor.methods
    calculate_child_count: (doc_id)->
        child_count = Docs.find(parent_id: doc_id).count()
        Docs.update doc_id, 
            $set: child_count: child_count
    
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
        
    
    update_location: (doc_id, result)->
        location_tags = (component.long_name for component in result.address_components)
        parts = result.address_components
        
        geocode = {}
        for part in parts
            geocode["#{part.types[0]}"] = part.short_name 
        geocode['formatted_address'] = result.formatted_address
        # # street_address = _.where(parts, {types:[ 'street_number' ]})
        # street_address = parts[0].short_name

        lowered_location_tags = _.map(location_tags, (tag)->
            tag.toLowerCase()
            )


        doc = Docs.findOne doc_id
        tags_without_address = _.difference(doc.tags, doc.location_tags)
        tags_with_new = _.union(tags_without_address, lowered_location_tags)

        Docs.update doc_id,
            $set:
                tags:tags_with_new
                location_ob:result
                location_tags:lowered_location_tags
                geocode:geocode
                location_lat: result.lat
                location_lng: result.lng
                
                
    create_message: (recipient_id, text, parent_id)->
        
        found_conversation = Docs.findOne
            type: 'conversation'
            participant_ids: $all: [Meteor.userId(), recipient_id]
            
        if found_conversation 
            convo_id = found_conversation._id
        else
            new_conversation_id = 
                Docs.insert
                    type: 'conversation'
                    participant_ids: [Meteor.userId(), recipient_id]
            convo_id = new_conversation_id
        new_message_id = 
            new_message_id = Docs.insert
                type: 'message'
                group_id: convo_id
                parent_id: parent_id
                body: text
        return new_message_id
            
    notify_user_about_document: (doc_id, recipient_id)->
        doc = Docs.findOne doc_id
        parent = Docs.findOne doc.parent_id
        recipient = Meteor.users.findOne recipient_id
        
        
        doc_link = "/view/#{doc._id}"
        notification = 
            Docs.findOne
                type:'notification'
                object_id:doc_id
                recipient_id:recipient_id
        if notification
            throw new Meteor.Error 500, 'User already notified.'
            return
        else
            Docs.insert
                type:'notification'
                object_id:doc_id
                recipient_id:recipient_id
                content: 
                    "<p>#{Meteor.user().name()} has notified you about <a href=#{doc_link}>#{parent.title} entry</a>.</p>"
                
                
    remove_notification: (doc_id, recipient_id)->
        doc = Docs.findOne doc_id
        recipient = Meteor.users.findOne recipient_id
        
        notification = 
            Docs.findOne
                type:'notification'
                object_id:doc_id
                recipient_id:recipient_id
        
        if notification 
            Docs.remove notification._id
        else
                
        return
        
        
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
          
          
    # create_conversation: (tags=[])->
    #     Docs.insert
    #         tags: tags
    #         type: 'conversation'
    #         subscribers: [Meteor.userId()]
    #         participant_ids: [Meteor.userId()]
    #     # FlowRouter.go "/conversation/#{id}"

    # close_conversation: (conversation_id)->
    #     Docs.remove conversation_id
    #     Docs.remove 
    #         type: 'message'
    #         group_id: conversation_id

    # join_conversation: (conversation_id)->
    #     Docs.update conversation_id,
    #         $addToSet: participant_ids: Meteor.userId()

    # leave_conversation: (conversation_id)->
    #     Docs.update conversation_id,
    #         $pull: participant_ids: Meteor.userId()
            
            
    # add_message: (body,group_id)->
    #     new_message_id = Docs.insert
    #         body: body
    #         type: 'message'
    #         group_id: group_id
    #         tags: ['conversation', 'message']
        
    #     conversation_doc = Docs.findOne _id: group_id
    #     message_doc = Docs.findOne new_message_id
    #     message_author = Meteor.users.findOne message_doc.author_id
        
    #     message_link = "https://www.jan.meteorapp.com/view/#{conversation_doc._id}"
        
    #     this.unblock()
        
    #     offline_ids = []
    #     for participant_id in conversation_doc.participant_ids
    #         user = Meteor.users.findOne participant_id
    #         if user.status.online is true
    #         else
    #             offline_ids.push user._id
        
        
    #     for offline_id in offline_ids
    #         offline_user = Meteor.users.findOne offline_id
            
    #         Email.send
    #             to: " #{offline_user.profile.first_name} #{offline_user.profile.last_name} <#{offline_user.emails[0].address}>",
    #             from: "Jan-Pro Customer Portal Admin <no-reply@jan-pro.com>",
    #             subject: "New Message from #{message_author.profile.first_name} #{message_author.profile.last_name}",
    #             html: 
    #                 "<h4>#{message_author.profile.first_name} just sent the following message while you were offline: </h4>
    #                 #{text} <br><br>
                    
    #                 Click <a href=#{message_link}> here to view.</a><br><br>
    #                 You can unsubscribe from this conversation in the Actions panel.
    #                 "
                
    #             # html: 
    #             #     "<h4>#{message_author.profile.first_name} just sent the following message: </h4>
    #             #     #{text} <br>
    #             #     In conversation with tags: #{conversation_doc.tags}. \n
    #             #     In conversation with description: #{conversation_doc.description}. \n
    #             #     \n
    #             #     Click <a href="/view/#{_id}"
    #             # "
    #     return new_message_id
      
      
    # update_escalation_statuses: ->
    #     open_incidents = Docs.find({type:'incident', open:true, submitted:true})
    #     open_incidents_count = open_incidents.count()
    #     Meteor.call 'create_event',null, 'start_escalation_check', "Starting esclation check now."
    #     Meteor.call 'create_event',null, 'incident_count', "Found #{open_incidents_count} open incidents, checking escalation status."
    #     for incident in open_incidents.fetch()
    #         Meteor.call 'single_escalation_check', incident._id
         

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
        
        found_franchisee = Docs.findOne
            type: 'franchisee'
            "ev.FRANCHISEE": customer_doc.ev.FRANCHISEE
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
    
    # register_transaction: (product_id)->
    #     product = Docs.findOne product_id
    #     if product.point_price
    #         Meteor.users.update Meteor.userId(),
    #             $inc: points: -product.point_price
            
    #         Meteor.users.update product.author_id,
    #             $inc: points: product.point_price
    #     Docs.insert
    #         type: 'transaction'
    #         parent_id: product_id
    #         sale_dollar_price: product.dollar_price
    #         sale_point_price: product.point_price
    #         author_id: Meteor.userId()
    #         recipient_id: product.author_id
    
    
    
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
                
                
                
                
    query_db: (query)->
        query_count = Docs.find(query).count()
        result = Docs.find(query).fetch()
        return result
        
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
