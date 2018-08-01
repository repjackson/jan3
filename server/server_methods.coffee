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
        console.log 'doc_id', doc_id
        doc = Docs.findOne doc_id
        if doc
            timestamp = doc.timestamp
            # console.log moment(timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
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
            # date_array = _.each(date_array, (el)-> console.log(typeof el))
            # console.log date_array
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
                # console.log part.types[0]
                # console.log part.short_name
        geocode['formatted_address'] = result.formatted_address
        console.log result.lat
        console.log result.lng
        # console.log parts[0].types
        # # street_address = _.where(parts, {types:[ 'street_number' ]})
        # street_address = parts[0].short_name
        # console.log 'street address', street_address

        lowered_location_tags = _.map(location_tags, (tag)->
            tag.toLowerCase()
            )

        # console.log location_tags

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
        # console.log 'recipient_id', recipient_id
        
        found_conversation = Docs.findOne
            type: 'conversation'
            participant_ids: $all: [Meteor.userId(), recipient_id]
            
        if found_conversation 
            # console.log 'found conversation with id:', found_conversation._id
            convo_id = found_conversation._id
        else
            new_conversation_id = 
                Docs.insert
                    type: 'conversation'
                    participant_ids: [Meteor.userId(), recipient_id]
            # console.log 'convo NOT found, created new one with id:', new_conversation_id
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
            console.log 'trying to remove unknown notification'
                
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
        # console.log 'key', key
        Docs.update doc_id,
            $pull: "#{key}": user._id
        Docs.insert
            type:'event'
            parent_id: doc_id
            event_key: key
            text: "#{user.username} was removed from #{key}."
        
        
    link_doc: (doc_id, key, doc)->
        # doc = Docs.findOne doc_id
        # console.log 'linking doc', key
        # console.log 'linking doc_id', doc_id
        # console.log 'linking doc', doc
        if key is 'customer_id'
            console.log doc.cust_name
            console.log doc.jpid
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
        # console.log 'key', key
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
            console.log "creating event with parent_id #{parent_id} of type: #{event_type} and action #{action}"
            Docs.insert
                type:'event'
                parent_id: parent_id
                event_type: event_type
                action:action
        else
            console.log "creating event with type: #{event_type} and action #{action}"
            Docs.insert
                type:'event'
                parent_id: parent_id
                event_type: event_type
                action:action

    set_incident_level: (target_id, event_type, level)->
        doc = Docs.findOne target_id
        current_user = Meteor.users.findOne @userId
        # console.log doc
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
    #     # console.log 'message author', message_author
    #     # console.log 'message_doc', message_doc
        
    #     this.unblock()
        
    #     offline_ids = []
    #     for participant_id in conversation_doc.participant_ids
    #         user = Meteor.users.findOne participant_id
    #         console.log participant_id
    #         if user.status.online is true
    #             console.log 'user online:', user.profile.first_name
    #         else
    #             offline_ids.push user._id
    #             console.log 'user offline:', user.profile.first_name
        
        
    #     for offline_id in offline_ids
    #         console.log 'offline id', offline_id
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
      
      
    update_escalation_statuses: ->
        open_incidents = Docs.find({type:'incident', open:true})
        open_incidents_count = open_incidents.count()
        Meteor.call 'create_event',null, 'start_escalation_check', "Starting esclation check now."
        Meteor.call 'create_event',null, 'incident_count', "Found #{open_incidents_count} open incidents, checking escalation status."
        for incident in open_incidents.fetch()
            Meteor.call 'single_escalation_check', incident._id
         
    single_escalation_check: (incident_id)->
        incident = Docs.findOne incident_id
        if incident.level is 4
            Meteor.call 'create_event', incident_id, 'max_level_notice', "Incident is at max level 4, not escalating."
        else
            # console.log 'first',incident_id
            incident_office =
                Docs.findOne
                    "ev.MASTER_LICENSEE": incident.incident_office_name
                    type:'office'
            current_level = incident.level
            next_level = current_level + 1

            # console.log incident._id
            last_updated = incident.updated
            hours_value = incident_office["escalation_#{next_level}_#{incident.incident_type}_hours"]
            now = Date.now()
            console.log 'hours value',hours_value
            console.log 'last_updated value', last_updated
            updated_now_difference = now-last_updated
            console.log 'difference between last updated and now', updated_now_difference
            seconds_elapsed = Math.floor(updated_now_difference/1000)
            console.log 'seconds elapsed =', seconds_elapsed
            minutes_elapsed = Math.floor(seconds_elapsed/60)
            console.log 'minutes elapsed =', minutes_elapsed
            escalation_calculation = minutes_elapsed - hours_value
            console.log 'escalation_calculation', escalation_calculation
            if minutes_elapsed < hours_value
                Meteor.call 'create_event', incident_id, 'not-escalate', "#{minutes_elapsed} minutes have elapsed, less than #{hours_value} in the escalations level #{next_level} #{incident.incident_type} rules, not escalating."
                # continue
            else    
                Meteor.call 'create_event', incident_id, 'escalate', "#{minutes_elapsed} minutes have elapsed, more than #{hours_value} in the escalations level #{next_level} #{incident.incident_type} rules, escalating."
                Meteor.call 'escalate_incident', incident._id, ->
            
    escalate_incident: (doc_id)-> 
        incident = Docs.findOne doc_id
        current_level = incident.level
        # console.log current_level
        if current_level > 3
            console.log "current level is 4, cant escalate beyond"
            Docs.update doc_id,
                $set:level:current_level-1
        else
            next_level = current_level + 1
            console.log 'escalating doc id', doc_id
            Docs.update doc_id,
                $set:
                    level:next_level
                    updated: Date.now()
            Meteor.call 'create_event', doc_id, 'escalate', "Incident was automatically escalated from #{current_level} to #{next_level}."
            Meteor.call 'email_about_escalation', doc_id


    clear_incident_events: (incident_id)->
        cursor = Docs.find
            parent_id: incident_id
            type:'event'
        for event_doc in cursor.fetch()
            # console.log event_doc
            Docs.remove event_doc._id

    check_username: (username)->
        found_user = Accounts.findUserByUsername username
        console.log found_user
        found_user
    
    check_email: (email)->
        found_user = Accounts.findUserByEmail email
        console.log found_user
        found_user


    add_role_to_user: (userid, role)->
        Meteor.users.update userid,
            $addToSet: roles: role
        user = Meteor.users.findOne userid
        console.log "added role #{role} to user #{user.username}" 
        Meteor.call 'create_event', userid, 'add role to user', "#{role} was added to #{user.username}."


    send_password_reset_email_by_username: (username)->
        console.log username
        found_user = Accounts.findUserByUsername(username)
        console.log found_user
        sent = Accounts.sendResetPasswordEmail(found_user._id)
        console.log sent
        return sent
        
    send_password_reset_email_by_email: (email)->
        console.log email
        found_user = Accounts.findUserByEmail(email)
        console.log found_user
        sent = Accounts.sendResetPasswordEmail(found_user._id)
        console.log sent
        return sent
        
        
        
    count_current_incident_number: ->
        incident_count = Docs.find(type:'incident').count()
        console.log 'incident count', incident_count
        return incident_count
        
        
    find_customer_by_jpid: (customer_jpid)->
        found = 
            Docs.findOne
                type:'customer'
                "ev.ID":customer_jpid
        if found
            return found
        else
            throw new Meteor.Error "Customer not found with JPID #{customer_jpid}."
            
    find_office_from_customer_jpid: (customer_jpid)->     
        customer_doc = Docs.findOne
            "ev.ID": customer_jpid
            type:'customer'
        console.log 'found customer, finding office', customer_doc
        if customer_doc
            found_office = Docs.findOne
                "ev.MASTER_LICENSEE": customer_doc.ev.MASTER_LICENSEE
                type:'office'
            console.log 'found office from customer:', found_office
            return found_office
        else 
            console.log 'couldnt find office from customer:', customer_jpid
            
         
         
    find_franchisee_from_customer_jpid: (customer_jpid)->
        customer_doc = Docs.findOne
            "ev.ID": customer_jpid
            type:'customer'
        console.log 'found customer, finding franchisee', customer_doc
        
        found_franchisee = Docs.findOne
            type: 'franchisee'
            "ev.FRANCHISEE": customer_doc.ev.FRANCHISEE
        console.log 'found franchisee', found_franchisee
        return found_franchisee
        

         
    find_office_from_jpid: (office_jpid)->     
        users_office = Docs.findOne
            "ev.ID": user.office_jpid
            type:'office'
        console.log users_office
        users_office
            
            
    # add_to_cart: (doc_id)->
    #     product = Docs.findOne doc_id
    #     Docs.insert
    #         type: 'cart_item'
    #         product_id: doc_id
    #         product_title:product.title
    #         product_price:product.price
    #         amount: 1
    
    # remove_from_cart: (doc_id)->
    #     Docs.remove doc_id
    
    # register_transaction: (product_id)->
    #     product = Docs.findOne product_id
    #     if product.point_price
    #         console.log 'product point price', product.point_price
    #         console.log 'purchaser amount before', Meteor.user().points
    #         Meteor.users.update Meteor.userId(),
    #             $inc: points: -product.point_price
    #         console.log 'purchaser amount after', Meteor.user().points
            
    #         console.log 'seller amount before', Meteor.users.findOne(product.author_id).points
    #         Meteor.users.update product.author_id,
    #             $inc: points: product.point_price
    #         console.log 'seller amount after', Meteor.users.findOne(product.author_id).points
    #     Docs.insert
    #         type: 'transaction'
    #         parent_id: product_id
    #         sale_dollar_price: product.dollar_price
    #         sale_point_price: product.point_price
    #         author_id: Meteor.userId()
    #         recipient_id: product.author_id
    
    
    # publishComposite 'cart', ->
    #     {
    #         find: ->
    #             Docs.find
    #                 type: 'cart_item'
    #                 author_id: @userId            
    #         children: [
    #             { find: (cart_item) ->
    #                 Docs.find cart_item.parent_id
    #                 }
    #             ]    
    #     }            
    
    
    refresh_customer_jpids: (username)->
        user = Meteor.users.findOne username:username
        console.log user
        if user.profile.customer_jpid
            customer_doc = Docs.findOne
                "ev.ID": user.profile.customer_jpid
                type:'customer'
        else if user.customer_jpid
            customer_doc = Docs.findOne
                "ev.ID": user.customer_jpid
                type:'customer'
        
        console.log 'found customer, finding franchisee', customer_doc
        
        found_franchisee = Docs.findOne
            type: 'franchisee'
            "ev.FRANCHISEE": customer_doc.ev.FRANCHISEE
        # console.log 'found franchisee', found_franchisee
        
        found_office = Docs.findOne
            type: 'office'
            "ev.MASTER_LICENSEE": found_franchisee.ev.MASTER_LICENSEE
        # console.log 'found office', found_office

        Meteor.users.update user._id,
            $set:
                customer_jpid: customer_doc.ev.ID
                franchisee_jpid: found_franchisee.ev.ID
                office_jpid: found_office.ev.ID
                