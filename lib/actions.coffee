if Meteor.isClient
    Template.set_schema_button.events
        'click .set_schema': ->
            delta = Docs.findOne type:'delta'
            card_doc = Template.parentData(4)

            Docs.update delta._id,
                $set:
                    "filter_type": [card_doc.slug]
                    current_page: 0
                    detail_id:null
                    viewing_children:false
                    viewing_detail:false
                    editing_mode:false
                    config_mode:false
            Session.set 'is_calculating', true
            Meteor.call 'fo', (err,res)->
                if err then console.log err
                else
                    Session.set 'is_calculating', false


    Template.bookmark_widget.helpers
        bookmarked: -> if @bookmark_ids and Meteor.userId() in @bookmark_ids then true else false
    Template.bookmark_widget.events
        'click .toggle_bookmark': (e,t)->
            console.log @
            Meteor.call 'user_toggle_list', @, 'bookmark_ids'

    Template.bookmark_pane.onCreated ->
        @autorun -> Meteor.subscribe 'user_list_users', @data, 'bookmark_ids'
    Template.bookmark_pane.helpers
        bookmark_users: ->
            target = Template.currentData()
            if target and target.bookmark_ids
                Meteor.users.find
                    _id: $in: target.bookmark_ids



    Template.subscribe.helpers
        subscribed: -> if @subscribe_ids and Meteor.userId() in @subscribe_ids then true else false
    Template.subscribe.events
        'click .toggle_subscribe': (e,t)->
            Meteor.call 'user_toggle_list', @, 'subscribe_ids'

    Template.subscribe_pane.onCreated ->
        @autorun -> Meteor.subscribe 'user_list_users', @data, 'subscribe_ids'
    Template.subscribe_pane.helpers
        subscribers: ->
            target = Template.currentData()
            if target and target.subscribe_ids
                Meteor.users.find
                    _id: $in: target.subscribe_ids






    Template.voting.helpers
        upvoted: -> if @upvoter_ids and Meteor.userId() in @upvoter_ids then true else false
        downvoted: -> if @downvoter_ids and Meteor.userId() in @downvoter_ids then true else false

        upvote_class: -> if @upvoter_ids and Meteor.userId() in @upvoter_ids then 'green' else false
        downvote_class: -> if @downvoter_ids and Meteor.userId() in @downvoter_ids then 'red' else false

    Template.voting.events
        'click .upvote': (e,t)-> Meteor.call 'upvote', @_id
        'click .downvote': (e,t)-> Meteor.call 'downvote', @_id

    Template.voting_pane.onCreated ->
        @autorun -> Meteor.subscribe 'user_list_users', @data, 'upvoter_ids'
        @autorun -> Meteor.subscribe 'user_list_users', @data, 'downvoter_ids'
    Template.voting_pane.helpers
        upvoters: ->
            target = Template.currentData()
            if target and target.upvoter_ids
                Meteor.users.find
                    _id: $in: target.upvoter_ids

        downvoters: ->
            target = Template.currentData()
            if target and target.downvoter_ids
                Meteor.users.find
                    _id: $in: target.downvoter_ids














    # Template.comment_button.helpers
    #     commentd: -> if @comment_ids and Meteor.userId() in @comment_ids then true else false
    # Template.comment_button.events
    #     'click .toggle_comment': (e,t)->
    #         Meteor.call 'user_toggle_list', @, 'comment_ids'

    Template.comment_pane.onCreated ->
        @autorun -> Meteor.subscribe 'comments', @data
    Template.comment_pane.helpers
        comments: ->
            target = Template.currentData()
            if target
                Docs.find
                    type:'comment'
                    parent_id: target._id





    Template.mark_read_button.helpers
        read: -> if @read_ids and Meteor.userId() in @read_ids then true else false
    Template.mark_read_button.events
        'click .toggle_read': (e,t)->
            Meteor.call 'user_toggle_list', @, 'read_ids'

    Template.mark_read_pane.onCreated ->
        @autorun -> Meteor.subscribe 'user_list_users', @data, 'read_ids'
    Template.mark_read_pane.helpers
        read_users: ->
            target = Template.currentData()
            if target and target.read_ids
                Meteor.users.find
                    _id: $in: target.read_ids









    Template.assignments.onCreated ->
        @autorun => Meteor.subscribe 'user_list_users', @data, 'assigned_ids'
        @user_results = new ReactiveVar( [] )

    Template.assignments.events
        'click .clear_results': (e,t)->
            t.user_results.set null

        'keyup #multiple_user_select_input': (e,t)->
            multiple_user_select_input_value = $(e.currentTarget).closest('#multiple_user_select_input').val().trim()
            current_ticket = Docs.findOne Template.currentData()._id
            Meteor.call 'lookup_office_user_by_username_and_officename', current_ticket.ticket_office_name, multiple_user_select_input_value, (err,res)=>
                if err then console.error err
                else
                    t.user_results.set res

        'click .select_user': (e,t) ->
            delta = Docs.findOne type:'delta'
            target =  Docs.findOne delta.detail_id
            page_doc = Docs.findOne Template.currentData()._id
            Meteor.call 'list_add_user', delta.detail_id,'assigned_ids',@,(err,res)=>
            $('#multiple_user_select_input').val ''
            t.user_results.set null
            # if page_doc.type is 'task'
            #     Meteor.call 'send_email_about_task_assignment', page_doc._id, @username
            Docs.update target._id,
                $set: assignment_timestamp:Date.now()
                # Meteor.call 'send_email_about_ticket_assignment', page_doc._id, @username

        'click .pull_user': ->
            if confirm "Remove #{@username}?"
                Meteor.call 'list_remove_user', Template.currentData()._id, 'assigned_ids', @


    Template.assignments.helpers
        ticket_assignment_timestamp: ->
            delta = Docs.findOne type:'delta'
            target =  Docs.findOne delta.detail_id
            if target
                target.assignment_timestamp

        user_results: -> Template.instance().user_results.get()

        assigned_users: ->
            delta = Docs.findOne type:'delta'
            target =  Docs.findOne delta.detail_id
            if target and target.assigned_ids
                Meteor.users.find(_id: $in: target.assigned_ids)



    # approval
    #


    Template.approval.onCreated ->
        @autorun => Meteor.subscribe 'user_list_users', @data, 'approver_ids'
        @user_results = new ReactiveVar( [] )

    Template.approval.events
        'click .clear_results': (e,t)->
            t.user_results.set null

        'keyup #multiple_user_select_input': (e,t)->
            multiple_user_select_input_value = $(e.currentTarget).closest('#multiple_user_select_input').val().trim()
            current_ticket = Docs.findOne Template.currentData()._id
            Meteor.call 'lookup_office_user_by_username_and_officename', current_ticket.ticket_office_name, multiple_user_select_input_value, (err,res)=>
                if err then console.error err
                else
                    t.user_results.set res

        'click .select_user': (e,t) ->
            delta = Docs.findOne type:'delta'
            target =  Docs.findOne delta.detail_id
            page_doc = Docs.findOne Template.currentData()._id
            Meteor.call 'list_add_user', delta.detail_id,'approver_ids',@,(err,res)=>
            $('#multiple_user_select_input').val ''
            t.user_results.set null
            # if page_doc.type is 'task'
            #     Meteor.call 'send_email_about_task_assignment', page_doc._id, @username

        'click .pull_user': ->
            if confirm "Remove #{@username}?"
                Meteor.call 'list_remove_user', Template.currentData()._id, 'approver_ids', @


    Template.approval.helpers
        ticket_assignment_timestamp: ->
            delta = Docs.findOne type:'delta'
            target =  Docs.findOne delta.detail_id
            if target
                target.assignment_timestamp

        user_results: -> Template.instance().user_results.get()

        assigned_users: ->
            delta = Docs.findOne type:'delta'
            target =  Docs.findOne delta.detail_id
            if target and target.approver_ids
                Meteor.users.find(_id: $in: target.approver_ids)

















Meteor.methods
    set_schema: (target)->
        # console.log 'target',target
        delta = Docs.findOne
            type:'delta'
            author_id:Meteor.userId()
        # console.log 'delta',delta
        if delta and target.slug
            Docs.update delta._id,
                $set:
                    "filter_type": [target.slug]
                    current_page: 0
                    detail_id:null
                    viewing_children:false
                    viewing_detail:false
                    editing_mode:false
                    config_mode:false
            # console.log 'hi call'
            Meteor.call 'fo', (err,res)->
        else
            return null

    user_toggle_list: (target, key)->
        # console.log target
        list = target["#{key}"]
        if list and Meteor.userId() in list
            Docs.update target._id,
                $pull: "#{key}": Meteor.userId()
        else
            Docs.update target._id,
                $addToSet: "#{key}": Meteor.userId()


    list_add_user: (doc_id, key, user)->
        doc = Docs.findOne doc_id
        Docs.update doc_id,
            $addToSet: "#{key}": user._id
        Docs.insert
            type:'event'
            parent_id: doc_id
            event_type: 'assignment'
            text: "#{user.username} was assigned to #{doc.type}."


    list_remove_user: (doc_id, key, user)->
        doc = Docs.findOne doc_id
        Docs.update doc_id,
            $pull: "#{key}": user._id
        Docs.insert
            type:'event'
            parent_id: doc_id
            event_type: 'assignment'
            text: "#{user.username} was unassigned from #{doc.type}."





if Meteor.isServer
    Meteor.publish 'user_list_users', (target,key)->
        if target and target["#{key}"]
            Meteor.users.find
                _id: $in: target["#{key}"]

