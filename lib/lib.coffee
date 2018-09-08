@Docs = new Meteor.Collection 'docs'
# @Settings = new Meteor.Collection 'settings'
@Stats = new Meteor.Collection 'stats'
@Tags = new Meteor.Collection 'tags'

# @People_tags = new Meteor.Collection 'people_tags'

# @Ancestor_ids = new Meteor.Collection 'ancestor_ids'
# @Location_tags = new Meteor.Collection 'location_tags'
# @Intention_tags = new Meteor.Collection 'intention_tags'
@Timestamp_tags = new Meteor.Collection 'timestamp_tags'
# @Watson_keywords = new Meteor.Collection 'watson_keywords'
# @Watson_concepts = new Meteor.Collection 'watson_concepts'
@Author_ids = new Meteor.Collection 'author_ids'
# @Participant_ids = new Meteor.Collection 'participant_ids'
# @Upvoter_ids = new Meteor.Collection 'upvoter_ids'

Docs.before.insert (userId, doc)->
    timestamp = Date.now()
    doc.timestamp = timestamp
    doc.updated = timestamp
    doc.long_timestamp = moment(timestamp).format("dddd, MMMM Do YYYY, h:mm:ss a")
    date = moment(timestamp).format('Do')
    weekdaynum = moment(timestamp).isoWeekday()
    weekday = moment().isoWeekday(weekdaynum).format('dddd')
    month = moment(timestamp).format('MMMM')
    year = moment(timestamp).format('YYYY')

    date_array = [weekday, month, date, year]
    if _
        date_array = _.map(date_array, (el)-> el.toString().toLowerCase())
    # date_array = _.each(date_array, (el)-> console.log(typeof el))
    # console.log date_array
    doc.timestamp_tags = date_array
    doc.author_id = Meteor.userId()
    # doc.points = 0
    # doc.read_by = [Meteor.userId()]
    # doc.upvoters = []
    # doc.downvoters = []

    return

Meteor.users.helpers
    name: -> 
        if @profile?.first_name and @profile?.last_name
            "#{@profile.first_name}  #{@profile.last_name}"
        else
            "#{@username}"
    last_login: -> moment(@status?.lastLogin.date).fromNow()

    users_customer: ->
        # console.log @
        if @customer_jpid
            found = Docs.findOne
                type:'customer'
                "ev.ID": @customer_jpid
            # console.log found
            found
        
    users_office: ->
        # console.log @
        if @office_jpid
            office_doc = Docs.findOne
                type:'office'
                "ev.ID": @office_jpid
            return office_doc
            # else if @customer_jpid
            #     users_customer = Docs.findOne
            #         type:'customer'
            #         "ev.ID": @customer_jpid
            #     if users_customer
            #         customers_franchisee = Docs.findOne
            #             type: 'franchisee'
            #             "ev.FRANCHISEE": users_customer.ev.FRANCHISEE
            #         if customers_franchisee
            #             customers_office = Docs.findOne
            #                 type:'office'
            #                 "ev.MASTER_LICENSEE": customers_franchisee.ev.MASTER_LICENSEE
            #             return customers_office

        
    email: -> 
        if @emails
            @emails[0].address
    

Docs.helpers
    event_type_doc: ->
        found_event_type = Docs.findOne 
            type:'event_type'
            slug:@event_type
        # console.log found_event_type
        found_event_type


    author: -> Meteor.users.findOne @author_id
    assigned_to_user: -> 
        if @assigned_to
            Meteor.users.findOne _id:$in:@assigned_to
    when: -> moment(@timestamp).fromNow()
    response: -> 
        if @assignment_timestamp
            now = Date.now()
            response = @assignment_timestamp - now
            calc = moment.duration(response).humanize()
            # console.log calc
            calc
    parent: -> Docs.findOne @parent_id
    customer: -> Docs.findOne @customer_id
    comment_count: -> Docs.find({type:'comment', parent_id:@_id}).count()
    # notified_users: -> 
    #     Meteor.users.find 
    children: -> Docs.find parent_id:@_id
    franchisee_customers: ->
        Docs.find
            type: 'customer'
            "ev.FRANCHISEE": @ev.FRANCHISEE

    parent_franchisee: ->
        Docs.findOne
            type: 'franchisee'
            "ev.FRANCHISEE": @ev.FRANCHISEE
    
    incident_customer: ->
        Docs.findOne
            type:'customer'
            "ev.ID": @customer_jpid
    
    # users_customer: ->
    #     user = Meteor.user()
    #     found = Docs.findOne
    #         type:'customer'
    #         "ev.ID": user.customer_jpid
    #     console.log found, 'hi'
    #     found
    
    
    parent_office: ->
        # attached to franchisee
        # console.log @
        found = Docs.findOne
            type:'office'
            "ev.MASTER_LICENSEE": @ev.MASTER_LICENSEE
        # console.log found
        if found
            found
            

Meteor.methods
    move: (doc_id, array, from_index, to_index)->
        array.splice(to_index, 0, array.splice(from_index, 1)[0] );
        # console.log array
        Docs.update doc_id,
            $set: fields: array


    update_module_field: (module_doc_id, field_object, key, value)->
        Docs.update { _id:module_doc_id, fields:field_object },
            { $set: "fields.$.#{key}": value }
    
    
    remove_module_field_object: (module_doc_id, field_object)->
        Docs.update { _id:module_doc_id },
            { $pull: "fields": field_object }


    update_row_key: (page_doc_id, row_object, key, value)->
        Docs.update { _id:page_doc_id, rows:row_object },
            { $set: "rows.$.#{key}": value }
    
    


    vote_up: (id)->
        doc = Docs.findOne id
        if not doc.upvoters
            Docs.update id,
                $set: 
                    upvoters: []
                    downvoters: []
        else if Meteor.userId() in doc.upvoters #undo upvote
            Docs.update id,
                $pull: upvoters: Meteor.userId()
                $inc: points: -1
            Meteor.users.update doc.author_id, $inc: points: -1
            # Meteor.users.update Meteor.userId(), $inc: points: 1

        else if Meteor.userId() in doc.downvoters #switch downvote to upvote
            Docs.update id,
                $pull: downvoters: Meteor.userId()
                $addToSet: upvoters: Meteor.userId()
                $inc: points: 2
            # Meteor.users.update doc.author_id, $inc: points: 2

        else #clean upvote
            Docs.update id,
                $addToSet: upvoters: Meteor.userId()
                $inc: points: 1
            Meteor.users.update doc.author_id, $inc: points: 1
            # Meteor.users.update Meteor.userId(), $inc: points: -1
        # Meteor.call 'generate_upvoted_cloud', Meteor.userId()

    vote_down: (id)->
        doc = Docs.findOne id
        if not doc.downvoters
            Docs.update id,
                $set: 
                    upvoters: []
                    downvoters: []
        else if Meteor.userId() in doc.downvoters #undo downvote
            Docs.update id,
                $pull: downvoters: Meteor.userId()
                $inc: points: 1
            # Meteor.users.update doc.author_id, $inc: points: 1
            # Meteor.users.update Meteor.userId(), $inc: points: 1

        else if Meteor.userId() in doc.upvoters #switch upvote to downvote
            Docs.update id,
                $pull: upvoters: Meteor.userId()
                $addToSet: downvoters: Meteor.userId()
                $inc: points: -2
            # Meteor.users.update doc.author_id, $inc: points: -2

        else #clean downvote
            Docs.update id,
                $addToSet: downvoters: Meteor.userId()
                $inc: points: -1
            # Meteor.users.update doc.author_id, $inc: points: -1
            # Meteor.users.update Meteor.userId(), $inc: points: -1
        # Meteor.call 'generate_downvoted_cloud', Meteor.userId()

    # favorite: (doc)->
    #     if doc.favoriters and Meteor.userId() in doc.favoriters
    #         Docs.update doc._id,
    #             $pull: favoriters: Meteor.userId()
    #             $inc: favorite_count: -1
    #     else
    #         Docs.update doc._id,
    #             $addToSet: favoriters: Meteor.userId()
    #             $inc: favorite_count: 1
    
    # mark_complete: (doc)->
    #     if doc.completed_ids and Meteor.userId() in doc.completed_ids
    #         Docs.update doc._id,
    #             $pull: completed_ids: Meteor.userId()
    #             $inc: completed_count: -1
    #     else
    #         Docs.update doc._id,
    #             $addToSet: completed_ids: Meteor.userId()
    #             $inc: completed_count: 1
    
    
    mark_read: (doc)->
        if doc.read_by and Meteor.userId() in doc.read_by
            Docs.update doc._id,
                $pull: read_by: Meteor.userId()
                $inc: read_count: -1
        else
            Docs.update doc._id,
                $addToSet: read_by: Meteor.userId()
                $inc: read_count: 1
    
    bookmark: (doc)->
        if doc.bookmarked_ids and Meteor.userId() in doc.bookmarked_ids
            Docs.update doc._id,
                $pull: bookmarked_ids: Meteor.userId()
                $inc: bookmarked_count: -1
        else
            Docs.update doc._id,
                $addToSet: bookmarked_ids: Meteor.userId()
                $inc: bookmarked_count: 1
    
    # pin: (doc)->
    #     if doc.pinned_ids and Meteor.userId() in doc.pinned_ids
    #         Docs.update doc._id,
    #             $pull: pinned_ids: Meteor.userId()
    #             $inc: pinned_count: -1
    #     else
    #         Docs.update doc._id,
    #             $addToSet: pinned_ids: Meteor.userId()
    #             $inc: pinned_count: 1
    
    # subscribe: (doc)->
    #     if doc.subscribed_ids and Meteor.userId() in doc.subscribed_ids
    #         Docs.update doc._id,
    #             $pull: subscribed_ids: Meteor.userId()
    #             $inc: subscribed_count: -1
    #     else
    #         Docs.update doc._id,
    #             $addToSet: subscribed_ids: Meteor.userId()
    #             $inc: subscribed_count: 1
    
