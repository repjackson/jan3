if Meteor.isClient
    Template.work.onCreated ->
        @autorun => Meteor.subscribe 'work'

    Template.work.helpers
        joules: ->
            Docs.find {
                type:'task'
                # assigned_ids: $in: [Meteor.userId()]
            }, limit:20

        work_segment_class: ->
            if @complete then 'green secondary' else ''

    Template.work.events
        'click .work': ->
            delta = Docs.findOne type:'delta'
            Docs.update delta._id,
                $set:
                    viewing_detail: true
                    view_rightbar: false
                    detail_id: @_id
                    expand_id: @_id
                    viewing_page: false
                    viewing_delta: false
            
        'click .mark_complete': ->
            Docs.update @_id,
                $set: complete: true
        'click .mark_incomplete': ->
            Docs.update @_id,
                $set: complete: false

if Meteor.isServer
    Meteor.publish 'work', ->
        Docs.find {
            type:'task'
            # assigned_ids: $in: [Meteor.userId()]
        }, limit: 20