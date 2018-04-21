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
        
    tagify_date_time: (val)->
        console.log moment(val).format("dddd, MMMM Do YYYY, h:mm:ss a")
        minute = moment(val).minute()
        hour = moment(val).format('h')
        date = moment(val).format('Do')
        ampm = moment(val).format('a')
        weekdaynum = moment(val).isoWeekday()
        weekday = moment().isoWeekday(weekdaynum).format('dddd')

        month = moment(val).format('MMMM')
        year = moment(val).format('YYYY')

        date_array = [hour, minute, ampm, weekday, month, date, year]
        date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
        # date_array = _.each(date_array, (el)-> console.log(typeof el))
        console.log date_array
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
