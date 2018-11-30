Template.dash.onCreated ->
    @autorun => Meteor.subscribe 'type', 'schema', 200

Template.footer.onCreated ->
    @autorun => Meteor.subscribe 'user_status'

Template.quick_idea.events
    'click .submit_idea': (e,t)->
        idea = t.$('#idea_text').val()
        Docs.insert
            type:'idea'
            details: idea
        t.$('#idea_text').val('')

    'keyup #idea_text': (e,t)->
        if e.which is 13
            idea = t.$('#idea_text').val()
            Docs.insert
                type:'idea'
                details: idea
            idea = t.$('#idea_text').val('')




Template.dash.helpers
    bookmarks: ->
        if Meteor.user() and Meteor.user().roles
            Docs.find {
                view_roles: $in:Meteor.user().roles
                type:'schema'
            }, sort:title:1
            
Template.nav.helpers
    header_class: -> 
        delta = Docs.findOne type:'delta'
        if delta.menu_template is 'dash' then 'lightblue' else ''

    cc_class: -> 
        delta = Docs.findOne type:'delta'
        if delta.menu_template is 'cc' then 'lightblue' else ''


Template.dash.events
    'click .pick_delta': (e,t)->
        e.preventDefault()
        # console.log @
        Session.set 'is_calculating', true
        Meteor.call 'set_schema', @slug, ->
            Session.set 'is_calculating', false


Template.nav.events
    'click .bell': (e,t)->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:
                viewing_menu:false
                viewing_page: true
                page_template:'notifications'
                viewing_delta: false

    'click .messages': (e,t)->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:
                viewing_menu:false
                viewing_page: true
                page_template:'messages'
                viewing_delta: false

    'click .chat': (e,t)->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:
                viewing_menu:false
                viewing_page: true
                page_template:'chat'
                viewing_delta: false

    'click .bookmarks': (e,t)->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:
                viewing_menu:false
                viewing_page: true
                page_template:'bookmark'
                viewing_delta: false

    'click .todo': (e,t)->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:
                viewing_menu:false
                viewing_page: true
                page_template:'todo'
                viewing_delta: false

    'click .dash': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:
                viewing_menu: !delta.viewing_menu
                menu_template:'dash'
                # viewing_delta: !delta.viewing_delta

    'click .cc': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:
                viewing_menu: !delta.viewing_menu
                menu_template:'cc'
                # viewing_delta: !delta.viewing_delta



Template.cc.onCreated ->
    @signing_out = new ReactiveVar false

Template.cc.events
    'click .settings': ->
        delta = Docs.findOne type:'delta'
        # console.log @
        Docs.update delta._id,
            $set:
                viewing_page:true
                page_template:'account_settings'
                viewing_delta:false


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


    'click .sla': ->
        delta = Docs.findOne type:'delta'
        Docs.update delta._id,
            $set:
                viewing_page:true
                page_template:'office_sla'
                viewing_delta:false

    'click #logout': (e,t)->
        # e.preventDefault()
        t.signing_out.set true
        Meteor.logout ->
            t.signing_out.set false


Template.cc.helpers
    signing_out: -> Template.instance().signing_out.get()

