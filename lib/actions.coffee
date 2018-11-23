if Meteor.isClient
    Template.set_schema_small.events
        'click .set_schema': ->
            delta = Docs.findOne type:'delta'
            card_doc = Template.parentData(4)

            Docs.update delta._id,
                $set:
                    filter_type: [card_doc.slug]
                    current_page: 0
                    detail_id:null
                    viewing_children:false
                    viewing_detail:false
                    editing:false
                    config_mode:false
            Session.set 'is_calculating', true
            Meteor.call 'fo', (err,res)->
                if err then console.log err
                else
                    Session.set 'is_calculating', false



    Template.bookmark_big.onCreated ->
        @autorun -> Meteor.subscribe 'user_list_users', Template.parentData(4), 'bookmark_ids'

    Template.bookmark_small.onCreated ->
        @autorun -> Meteor.subscribe 'user_list_users', Template.parentData(4), 'bookmark_ids'


    Template.bookmark_big.helpers
        bookmarked: ->
            target = Template.parentData(4)
            if target.bookmark_ids and Meteor.userId() in target.bookmark_ids then true else false
    Template.bookmark_small.helpers
        bookmarked: ->
            target = Template.parentData(4)
            if target.bookmark_ids and Meteor.userId() in target.bookmark_ids then true else false


    Template.bookmark_big.events
        'click .toggle_bookmark': (e,t)->
            target = Template.parentData(4)
            Meteor.call 'user_toggle_list', target, 'bookmark_ids'
    Template.bookmark_small.events
        'click .toggle_bookmark': (e,t)->
            target = Template.parentData(4)
            Meteor.call 'user_toggle_list', target, 'bookmark_ids'


    Template.bookmark_big.helpers
        bookmark_users: ->
            target = Template.parentData(4)
            if target and target.bookmark_ids
                Meteor.users.find
                    _id: $in: target.bookmark_ids


    Template.subscribe_big.onCreated ->
        @autorun -> Meteor.subscribe 'user_list_users', Template.parentData(4), 'subscribe_ids'
    Template.subscribe_small.onCreated ->
        @autorun -> Meteor.subscribe 'user_list_users', Template.parentData(4), 'subscribe_ids'


    Template.subscribe_big.helpers
        subscribed: ->
            target = Template.parentData(4)
            if target.subscribe_ids and Meteor.userId() in target.subscribe_ids then true else false
    Template.subscribe_small.helpers
        subscribed: ->
            target = Template.parentData(4)
            if target.subscribe_ids and Meteor.userId() in target.subscribe_ids then true else false
    Template.subscribe_big.events
        'click .toggle_subscribe': (e,t)->
            Meteor.call 'user_toggle_list', Template.parentData(4), 'subscribe_ids'
    Template.subscribe_small.events
        'click .toggle_subscribe': (e,t)->
            Meteor.call 'user_toggle_list', Template.parentData(4), 'subscribe_ids'

    Template.subscribe_big.helpers
        subscribers: ->
            target = Template.parentData(4)
            if target and target.subscribe_ids
                Meteor.users.find
                    _id: $in: target.subscribe_ids


    Template.subscribe_small.helpers
        subscribers: ->
            target = Template.parentData(4)
            if target and target.subscribe_ids
                Meteor.users.find
                    _id: $in: target.subscribe_ids






    Template.voting_small.helpers
        upvoted: -> if @upvoter_ids and Meteor.userId() in @upvoter_ids then true else false
        downvoted: -> if @downvoter_ids and Meteor.userId() in @downvoter_ids then true else false

        upvote_class: -> if @upvoter_ids and Meteor.userId() in @upvoter_ids then 'green' else false
        downvote_class: -> if @downvoter_ids and Meteor.userId() in @downvoter_ids then 'red' else false

    Template.voting_small.events
        'click .upvote': (e,t)-> Meteor.call 'upvote', @_id
        'click .downvote': (e,t)-> Meteor.call 'downvote', @_id

    Template.voting_big.onCreated ->
        @autorun -> Meteor.subscribe 'user_list_users', @data, 'upvoter_ids'
        @autorun -> Meteor.subscribe 'user_list_users', @data, 'downvoter_ids'
    Template.voting_big.helpers
        upvoters: ->
            target = Template.parentData(4)
            if target and target.upvoter_ids
                Meteor.users.find
                    _id: $in: target.upvoter_ids

        downvoters: ->
            target = Template.parentData(4)
            if target and target.downvoter_ids
                Meteor.users.find
                    _id: $in: target.downvoter_ids



    Template.mark_read_small.helpers
        read: ->
            target = Template.parentData(4)
            if target.read_ids and Meteor.userId() in target.read_ids then true else false
    Template.mark_read_big.helpers
        read: ->
            target = Template.parentData(4)
            if target.read_ids and Meteor.userId() in target.read_ids then true else false

    Template.mark_read_small.events
        'click .toggle_read': (e,t)->
            target = Template.parentData(4)
            Meteor.call 'user_toggle_list', target, 'read_ids'

    Template.mark_read_big.events
        'click .toggle_read': (e,t)->
            target = Template.parentData(4)
            Meteor.call 'user_toggle_list', target, 'read_ids'

    Template.mark_read_big.onCreated ->
        @autorun -> Meteor.subscribe 'user_list_users', Template.parentData(4), 'read_ids'
    Template.mark_read_small.onCreated ->
        @autorun -> Meteor.subscribe 'user_list_users', Template.parentData(4), 'read_ids'
    Template.mark_read_big.helpers
        read_users: ->
            target = Template.parentData(4)
            if target and target.read_ids
                Meteor.users.find
                    _id: $in: target.read_ids

    Template.mark_read_small.helpers
        read_users: ->
            target = Template.parentData(4)
            if target and target.read_ids
                Meteor.users.find
                    _id: $in: target.read_ids









    Template.assignment_small.onCreated ->
        @autorun => Meteor.subscribe 'user_list_users', @data, 'assigned_ids'
        @user_results = new ReactiveVar( [] )
    Template.assignment_big.onCreated ->
        @autorun => Meteor.subscribe 'user_list_users', @data, 'assigned_ids'
        @user_results = new ReactiveVar( [] )

    Template.assignment_big.events
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


    Template.assignment_big.helpers
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


    Template.assignment_small.helpers
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




    Template.approval_big.onCreated ->
        @autorun => Meteor.subscribe 'user_list_users', @data, 'approver_ids'
        @user_results = new ReactiveVar( [] )

    Template.approval_big.events
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


    Template.approval_big.helpers
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
    set_schema: (schema_slug)->
        delta = Docs.findOne
            type:'delta'
            author_id:Meteor.userId()
        if delta and schema_slug
            Docs.update delta._id,
                $set:
                    filter_type: [schema_slug]
                    current_page: 0
                    detail_id:null
                    viewing_menu:false
                    viewing_detail:false
                    viewing_delta:true
                    editing:false
                    config_mode:false
                    viewing_page:false
                    viewing_leftbar:false
                    viewing_rightbar:false
            Meteor.call 'fo', (err,res)->
        else
            return null

    user_toggle_list: (target, key)->
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

