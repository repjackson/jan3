

Template.ticket_assignment_cell.onCreated ->
    @autorun =>  Meteor.subscribe 'assigned_to_users', @data._id

Template.ticket_assignment_cell.helpers
    # ticket_assignment_cell_class: ->
    #     if @assignment_timestamp
    #         now = Date.now()
    #         response = @assignment_timestamp - now
    #         calc = moment.duration(response).humanize()
    #         hour_amount = moment.duration(response).asHours()
    #         if hour_amount<-5 then 'negative' else 'positive'

    assigned_users: ->
        if @assigned_to
            Meteor.users.find
                _id: $in: @assigned_to


Template.call_method.events
    'click .call_method': ->
        Meteor.call @name, @argument, (err,res)->
            # else



Template.author_info.onCreated ->
    @autorun => Meteor.subscribe 'author', @data.author_id



Template.user_list_view.onCreated ->
    @autorun => Meteor.subscribe 'single_user', @data._id






