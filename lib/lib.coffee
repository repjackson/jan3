@Docs = new Meteor.Collection 'docs'
# @Settings = new Meteor.Collection 'settings'
@Events = new Meteor.Collection 'events'
@Stats = new Meteor.Collection 'stats'
# @Tags = new Meteor.Collection 'tags'



Docs.before.insert (userId, doc)->
    timestamp = Date.now();
    now = moment(timestamp);
    
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


    update_block_field: (block_doc_id, field_object, key, value)->
        Docs.update { _id:block_doc_id, fields:field_object },
            { $set: "fields.$.#{key}": value }
    
    
    remove_block_field_object: (block_doc_id, field_object)->
        Docs.update { _id:block_doc_id },
            { $pull: "fields": field_object }


    update_row_key: (page_doc_id, row_object, key, value)->
        Docs.update { _id:page_doc_id, rows:row_object },
            { $set: "rows.$.#{key}": value }