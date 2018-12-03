Template.registerHelper 'delta', () -> Docs.findOne type:'delta'


Template.registerHelper 'is_eric', ()->
    if Meteor.user()
        'Bda8mRG925DnxTjQC' is Meteor.userId()


Template.registerHelper 'is_array', ()->
    if @primitive
        @primitive in ['array','multiref']
    # else
    #     console.log 'no primitive', @

Template.registerHelper 'is_dev_env', () -> Meteor.isDevelopment

Template.nav.events
    'click .delta': (e,t)->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:
                viewing_menu:false
                viewing_page: true
                page_template:'delta'
                viewing_delta: false
   
    'click .add': (e,t)->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:
                viewing_menu:false
                viewing_page: true
                page_template:'add'
                viewing_delta: false

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

    'click .show_delta': (e,t)->
        delta = Docs.findOne type:'delta'
        console.log delta

    'click #logout': (e,t)->
        # e.preventDefault()
        Meteor.logout ->
            t.signing_out.set false