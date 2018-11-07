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

    Template.set_schema.events
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
        icon_class: -> if  @bookmark_ids and Meteor.userId() in @bookmark_ids then 'red' else 'outline'

    Template.bookmark_button.events
        'click .toggle_bookmark': (e,t)->
            # console.log @
            # console.log t
            # console.log t.data
            # console.log Template.currentData()
            # console.log Template.parentData()
            Meteor.call 'bookmark', @




    Template.subscribe_button.helpers
        icon_class: -> if  @subscribe_ids and Meteor.userId() in @subscribe_ids then 'red' else 'outline'

    Template.subscribe_button.events
        'click .toggle_subscribe': (e,t)->
            # console.log @
            # console.log t
            # console.log t.data
            # console.log Template.currentData()
            # console.log Template.parentData()
            Meteor.call 'subscribe', @



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


    bookmark: (target)->
        # console.log target
        if target.bookmark_ids and Meteor.userId() in target.bookmark_ids
            Docs.update target._id,
                $pull: bookmark_ids: Meteor.userId()
        else
            Docs.update target._id,
                $addToSet: bookmark_ids: Meteor.userId()


    subscribe: (target)->
        # console.log target
        if target.subscribe_ids and Meteor.userId() in target.subscribe_ids
            Docs.update target._id,
                $pull: subscribe_ids: Meteor.userId()
        else
            Docs.update target._id,
                $addToSet: subscribe_ids: Meteor.userId()
