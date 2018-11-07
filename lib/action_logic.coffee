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
        if target.bookmark_ids and Meteor.userId() in target.bookmark_ids
            Docs.update target._id,
                $pull: bookmark_ids: Meteor.userId()
        else
            Docs.update target._id,
                $addToSet: bookmark_ids: Meteor.userId()
