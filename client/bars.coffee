Template.leftbar.onCreated ->
    @autorun => Meteor.subscribe 'type', 'schema', 200


Template.leftbar.helpers
    bookmarks: ->
        if Meteor.user() and Meteor.user().roles
            Docs.find {
                view_roles: $in:Meteor.user().roles
                type:'schema'
            }, sort:title:1

Template.leftbar.events
    'click .pick_delta': (e,t)->
        e.preventDefault()
        # console.log @
        Session.set 'is_calculating', true
        Meteor.call 'set_schema', @, ->
            Session.set 'is_calculating', false



Template.rightbar.onCreated ->
    @signing_out = new ReactiveVar false

Template.rightbar.events
    'click .settings': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:
                viewing_page:true
                page_template:'account_settings'


    'click .delete_delta': ->
        if confirm 'Clear Session?'
            delta = Docs.findOne type:'delta'
            Docs.remove delta._id

    'click .run_fo': ->
        delta = Docs.findOne type:'delta'
        Session.set 'is_calculating', true
        Meteor.call 'fo', (err,res)->
            if err then console.log err
            else
                Session.set 'is_calculating', false



    'click .sla': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:
                viewing_page:true
                page_template:'office_sla'

    'click #logout': (e,t)->
        # e.preventDefault()
        t.signing_out.set true
        Meteor.logout ->
            t.signing_out.set false


Template.rightbar.helpers
    signing_out: -> Template.instance().signing_out.get()

