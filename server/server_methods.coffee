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
                $set: date_array: date_array
            return date_array


    verify_email: (user_id)->
        Accounts.sendVerificationEmail(user_id)        
        
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