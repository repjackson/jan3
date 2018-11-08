if Meteor.isClient
    Template.action.events
        'click .fire_action': (e,t)->
            target = Template.parentData()
            if @function
                # Session.set 'is_calculating', true
                Meteor.call @function, target, (err,res)->
                    if err then console.log err
                    # else
                        # console.log 'return', res
                        # Session.set 'is_calculating', false

    Template.set_schema_button.events
        'click .set_schema': ->
            delta = Docs.findOne type:'delta'
            # console.log @
            # console.log Template.parentData()

            Docs.update delta._id,
                $set:
                    "filter_type": [@slug]
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


    Template.bookmark_button.helpers
        bookmarked: -> if @bookmark_ids and Meteor.userId() in @bookmark_ids then true else false

    Template.bookmark_button.events
        'click .toggle_bookmark': (e,t)->
            Meteor.call 'user_toggle_list', @, 'bookmark_ids'




    Template.subscribe_button.helpers
        icon_class: -> if @subscribe_ids and Meteor.userId() in @subscribe_ids then 'blue' else 'outline'

    Template.subscribe_button.events
        'click .toggle_subscribe': (e,t)->
            Meteor.call 'user_toggle_list', @data, 'subscribe_ids'


    Template.mark_read_pane.onCreated ->
        @autorun -> Meteor.subscribe 'user_list_users', @data, 'read_ids'

    Template.bookmark_pane.onCreated ->
        @autorun -> Meteor.subscribe 'user_list_users', @data, 'bookmark_ids'

    Template.bookmark_pane.helpers
        bookmark_users: ->
            target = Template.currentData()
            if target
                Meteor.users.find
                    _id: $in: target.bookmark_ids



    Template.mark_read_button.helpers
        read: -> if @read_ids and Meteor.userId() in @read_ids then true else false

    Template.mark_read_button.events
        'click .toggle_read': (e,t)->
            Meteor.call 'user_toggle_list', @, 'read_ids'

    Template.mark_read_pane.helpers
        read_users: ->
            target = Template.currentData()
            if target
                Meteor.users.find
                    _id: $in: target.read_ids


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


if Meteor.isServer
    Meteor.publish 'user_list_users', (target,key)->
        Meteor.users.find
            _id: $in: target["#{key}"]