Meteor.methods
    calculate_child_count: (doc_id)->
        child_count = Docs.find(parent_id: doc_id).count()
        Docs.update doc_id, 
            $set: child_count: child_count

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
        Accounts.addEmail(userId, new_email);
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
          
          
    create_conversation: (tags=[])->
        Docs.insert
            tags: tags
            type: 'conversation'
            subscribers: [Meteor.userId()]
            participant_ids: [Meteor.userId()]
        # FlowRouter.go "/conversation/#{id}"

    close_conversation: (conversation_id)->
        Docs.remove conversation_id
        Docs.remove 
            type: 'message'
            group_id: conversation_id

    join_conversation: (conversation_id)->
        Docs.update conversation_id,
            $addToSet: participant_ids: Meteor.userId()

    leave_conversation: (conversation_id)->
        Docs.update conversation_id,
            $pull: participant_ids: Meteor.userId()
            
            
    add_message: (body,group_id)->
        new_message_id = Docs.insert
            body: body
            type: 'message'
            group_id: group_id
            tags: ['conversation', 'message']
        
        conversation_doc = Docs.findOne _id: group_id
        message_doc = Docs.findOne new_message_id
        message_author = Meteor.users.findOne message_doc.author_id
        
        message_link = "https://www.jan.meteorapp.com/view/#{conversation_doc._id}"
        # console.log 'message author', message_author
        # console.log 'message_doc', message_doc
        
        this.unblock()
        
        offline_ids = []
        for participant_id in conversation_doc.participant_ids
            user = Meteor.users.findOne participant_id
            console.log participant_id
            if user.status.online is true
                console.log 'user online:', user.profile.first_name
            else
                offline_ids.push user._id
                console.log 'user offline:', user.profile.first_name
        
        
        for offline_id in offline_ids
            console.log 'offline id', offline_id
            offline_user = Meteor.users.findOne offline_id
            
            Email.send
                to: " #{offline_user.profile.first_name} #{offline_user.profile.last_name} <#{offline_user.emails[0].address}>",
                from: "Jan-Pro Customer Portal Admin <no-reply@jan-pro.com>",
                subject: "New Message from #{message_author.profile.first_name} #{message_author.profile.last_name}",
                html: 
                    "<h4>#{message_author.profile.first_name} just sent the following message while you were offline: </h4>
                    #{text} <br><br>
                    
                    Click <a href=#{message_link}> here to view.</a><br><br>
                    You can unsubscribe from this conversation in the Actions panel.
                    "
                
                # html: 
                #     "<h4>#{message_author.profile.first_name} just sent the following message: </h4>
                #     #{text} <br>
                #     In conversation with tags: #{conversation_doc.tags}. \n
                #     In conversation with description: #{conversation_doc.description}. \n
                #     \n
                #     Click <a href="/view/#{_id}"
                # "
        return new_message_id
      
      
    update_escalation_statuses: ->
        incident_cursor = Docs.find(type:'incident')
        console.log incident_cursor.count()
        for incident in incident_cursor.fetch()
            # console.log incident.level
            # console.log incident.timestamp
            now = Date.now()
            # console.log incident.incident_office_name
            incidents_office =
                Docs.findOne
                    "ev.MASTER_LICENSEE": incident.incident_office_name
                    type:'office'
            difference = now - incident.last_updated_datetime
            # console.log 'difference', difference
            # console.log 'level',incident.level
            hours_value = "escalation_#{incident.level}_hours"
            # hours_value = incidents_office["escalation_#{incident.level}_hours"]
            console.log hours_value
            # if difference < hours_value*60
            #     console.log 'escalate'
            # else
            #     console.log 'dont'
            # console.log 'the office', incidents_office