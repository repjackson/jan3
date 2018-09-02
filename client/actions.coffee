Template.action.helpers
    action_doc: -> 
        action_doc = Docs.findOne @valueOf()
        
Template.vote_button.helpers
    vote_up_button_class: ->
        if not Meteor.userId() then 'disabled'
        else if @upvoters and Meteor.userId() in @upvoters then 'green'
        else 'outline'

    vote_down_button_class: ->
        if not Meteor.userId() then 'disabled'
        else if @downvoters and Meteor.userId() in @downvoters then 'red'
        else 'outline'

Template.vote_button.events
    'click .vote_up': (e,t)-> 
        if Meteor.userId()
            Meteor.call 'vote_up', @_id
        else FlowRouter.go '/sign-in'

    'click .vote_down': -> 
        if Meteor.userId() then Meteor.call 'vote_down', @_id
        else FlowRouter.go '/sign-in'

            
Template.mark_read_button.events
    'click .mark_read': (e,t)-> Meteor.call 'mark_read', @
    'click .mark_unread': (e,t)-> Meteor.call 'mark_read', @

Template.mark_read_button.helpers
    read: -> @read_by and Meteor.userId() in @read_by
    # read: -> true
    
Template.mark_read_link.events
    'click .mark_read': (e,t)-> Meteor.call 'mark_read', @
    'click .mark_unread': (e,t)-> Meteor.call 'mark_read', @

Template.mark_read_link.helpers
    read: -> @read_by and Meteor.userId() in @read_by
    # read: -> true
    
    
Template.read_by_list.onCreated ->
    @autorun => Meteor.subscribe 'read_by', Template.parentData()._id
    
Template.read_by_list.helpers
    read_by: ->
        if @read_by
            if @read_by.length > 0
                Meteor.users.find _id: $in: @read_by
        else 
            false
            