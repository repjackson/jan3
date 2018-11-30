if Meteor.isClient
    Template.set_schema_part.events
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




    Template.subscribe_part.onCreated ->
        @autorun -> Meteor.subscribe 'user_list_users', Template.parentData(4), 'subscribe_ids'


    Template.subscribe_part.helpers
        subscribed: ->
            target = Template.parentData(4)
            if target.subscribe_ids and Meteor.userId() in target.subscribe_ids then true else false
        subscribers: ->
            target = Template.parentData(4)
            if target and target.subscribe_ids
                Meteor.users.find
                    _id: $in: target.subscribe_ids

    Template.subscribe_part.events
        'click .toggle_subscribe': (e,t)->
            Meteor.call 'user_toggle_list', Template.parentData(4), 'subscribe_ids'



    Template.voting_part.onCreated ->
        @autorun -> Meteor.subscribe 'user_list_users', @data, 'upvoter_ids'
        @autorun -> Meteor.subscribe 'user_list_users', @data, 'downvoter_ids'

    Template.voting_part.helpers
        upvoted: ->
            target = Template.parentData(4)
            if target.upvoter_ids and Meteor.userId() in target.upvoter_ids then true else false
        downvoted: ->
            target = Template.parentData(4)
            if target.downvoter_ids and Meteor.userId() in target.downvoter_ids then true else false

        upvote_class: ->
            target = Template.parentData(4)
            if target.upvoter_ids and Meteor.userId() in target.upvoter_ids then 'blue' else ''

        downvote_class: ->
            target = Template.parentData(4)
            if target.downvoter_ids and Meteor.userId() in target.downvoter_ids then 'blue' else ''


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

    Template.voting_part.events
        'click .upvote': (e,t)->
            target = Template.parentData(4)
            Meteor.call 'upvote', target._id

        'click .downvote': (e,t)->
            target = Template.parentData(4)
            Meteor.call 'downvote', target._id



    Template.mark_read_part.onCreated ->
        @autorun -> Meteor.subscribe 'user_list_users', Template.parentData(4), 'read_ids'

    Template.mark_read_part.helpers
        read: ->
            target = Template.parentData(4)
            if target.read_ids and Meteor.userId() in target.read_ids then true else false

    Template.mark_read_part.events
        'click .toggle_read': (e,t)->
            target = Template.parentData(4)
            Meteor.call 'user_toggle_list', target, 'read_ids'

    Template.mark_read_part.helpers
        read_users: ->
            target = Template.parentData(4)
            if target and target.read_ids
                Meteor.users.find
                    _id: $in: target.read_ids





    Template.complete_part.events
        'click .mark_complete': ->
            Docs.update Template.parentData(4)._id,
                $set: complete:true

        'click .mark_incomplete': ->
            Docs.update Template.parentData(4)._id,
                $set: complete:false





    Template.assignment_part.onCreated ->
        @autorun => Meteor.subscribe 'user_list_users', @data, 'assigned_ids'
        @user_results = new ReactiveVar( [] )

    Template.assignment_part.events
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


    Template.assignment_part.helpers
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




    Template.approval_part.onCreated ->
        @autorun => Meteor.subscribe 'user_list_users', @data, 'approver_ids'
        @user_results = new ReactiveVar( [] )

    Template.approval_part.events
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


    Template.approval_part.helpers
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
                    view_leftbar:false
                    view_rightbar:false
            Meteor.call 'fo', (err,res)->
        else
            return null

    edit_schema: (schema_slug)->
        delta = Docs.findOne
            type:'delta'
            author_id:Meteor.userId()

        schema_doc =
            Docs.findOne
                type:'schema'
                slug:schema_slug

        if delta and schema_slug
            Docs.update delta._id,
                $set:
                    filter_type: [schema_slug]
                    current_page: 0
                    viewing_detail:true
                    detail_id:schema_doc._id
                    editing:true
                    config_mode:false
                    viewing_page:false
            # Meteor.call 'fo', (err,res)->
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

