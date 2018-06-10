Meteor.methods
    calculate_child_count: (doc_id)->
        child_count = Docs.find(parent_id: doc_id).count()
        Docs.update doc_id, 
            $set: child_count: child_count


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
        
    # notify_user_about_document: (doc_id, recipient_id)->
    #     doc = Docs.findOne doc_id
    #     parent = Docs.findOne doc.parent_id
    #     recipient = Meteor.users.findOne recipient_id
        
        
    #     doc_link = "/view/#{doc._id}"
    #     notification = 
    #         Docs.findOne
    #             type:'notification'
    #             object_id:doc_id
    #             recipient_id:recipient_id
    #     if notification
    #         throw new Meteor.Error 500, 'User already notified.'
    #         return
    #     else
    #         Docs.insert
    #             type:'notification'
    #             object_id:doc_id
    #             recipient_id:recipient_id
    #             content: 
    #                 "<p>#{Meteor.user().name()} has notified you about <a href=#{doc_link}>#{parent.title} entry</a>.</p>"
    
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


    generate_upvoted_cloud: ->
        match = {}
        match.upvoters = $in: [Meteor.userId()]
        match.type = 'facet'

        
        upvoted_cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 100 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        upvoted_list = (tag.name for tag in upvoted_cloud)
        Meteor.users.update Meteor.userId(),
            $set:
                upvoted_cloud: upvoted_cloud
                upvoted_list: upvoted_list



    generate_downvoted_cloud: ->
        match = {}
        match.downvoters = $in: [Meteor.userId()]
        match.type = 'facet'
        downvoted_cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: '$tags' }
            { $group: _id: '$tags', count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: 100 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        downvoted_list = (tag.name for tag in downvoted_cloud)
        Meteor.users.update Meteor.userId(),
            $set:
                downvoted_cloud: downvoted_cloud
                downvoted_list: downvoted_list
            
            
