@Docs = new Meteor.Collection 'docs'


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
    doc.timestamp_tags = date_array
    doc.author_id = Meteor.userId()
    if Meteor.user()
        doc.author_username = Meteor.user().username
        if Meteor.user().office_jpid
            doc.office_jpid = Meteor.user().office_jpid
        if Meteor.user().customer_jpid
            doc.customer_jpid = Meteor.user().customer_jpid
        if Meteor.user().franchisee_jpid
            doc.franchisee_jpid = Meteor.user().franchisee_jpid

        if Meteor.user().office_name
            doc.office_name = Meteor.user().office_name
        if Meteor.user().customer_name
            doc.customer_name = Meteor.user().customer_name
        if Meteor.user().franchisee_name
            doc.franchisee_name = Meteor.user().franchisee_name

    return

Meteor.users.helpers
    name: ->
        if @profile?.first_name and @profile?.last_name
            "#{@profile.first_name}  #{@profile.last_name}"
        else
            "#{@username}"
    last_login: -> moment(@status?.lastLogin.date).fromNow()

    users_customer: ->
        if @customer_jpid
            found = Docs.findOne
                type:'customer'
                customer_jpid: @customer_jpid
            found

    users_office: ->
        if @office_jpid
            office_doc = Docs.findOne
                type:'office'
                office_jpid: @office_jpid
            return office_doc


    email: ->
        if @emails
            @emails[0].address


Docs.helpers
    event_type_doc: ->
        found_event_type = Docs.findOne
            type:'event_type'
            slug:@event_type
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
            calc
    parent: -> Docs.findOne @parent_id
    customer: -> Docs.findOne @customer_jpid
    office: -> Docs.findOne @office_jpid
    comment_count: -> Docs.find({type:'comment', parent_id:@_id}).count()
    # notified_users: ->
    #     Meteor.users.find
    children: -> Docs.find parent_id:@_id
    franchisee_customers: ->
        Docs.find
            type: 'customer'
            customer_name: @customer_name

    parent_franchisee: ->
        Docs.findOne
            type: 'franchisee'
            franchisee_name: @franchisee_name

    incident_customer: ->
        Docs.findOne
            type:'customer'
            customer_jpid: @customer_jpid

    # users_customer: ->
    #     user = Meteor.user()
    #     found = Docs.findOne
    #         type:'customer'
    #         customer_jpid: user.customer_jpid
    #     found



Meteor.methods
    move: (doc_id, array, from_index, to_index)->
        array.splice(to_index, 0, array.splice(from_index, 1)[0] );
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