Template.leftbar.onCreated ->
    @autorun => Meteor.subscribe 'type', 'schema', 200


Template.leftbar.onRendered ->
    @autorun =>
        if @subscriptionsReady()
            Meteor.setTimeout ->
                $('.context .ui.left.sidebar')
                    .sidebar({
                        context: $('.context .pushable')
                        dimPage: false
                        transition: 'overlay'
                        scrollLock: false
                        exclusive: true
                    })
                    .sidebar('attach events', '.context .menu .toggle_leftbar')
            , 1300

Template.topbar.onRendered ->
    @autorun =>
        if @subscriptionsReady()
            Meteor.setTimeout ->
                $('.context .ui.top.sidebar')
                    .sidebar({
                        context: $('.context .pushable')
                        dimPage: false
                        transition: 'overlay'
                        scrollLock: false
                        exclusive: true
                    })
                    .sidebar('attach events', '.context .menu .toggle_topbar')
            , 1300

Template.bottombar.onRendered ->
    @autorun =>
        if @subscriptionsReady()
            Meteor.setTimeout ->
                $('.context .ui.bottom.sidebar')
                    .sidebar({
                        context: $('.context .pushable')
                        dimPage: false
                        transition: 'overlay'
                        scrollLock: false
                        exclusive: true
                    })
                    .sidebar('attach events', '.context .menu .toggle_topbar')
            , 1300

Template.rightbar.onRendered ->
    if @subscriptionsReady()
            Meteor.setTimeout ->
                $('.context .ui.right.sidebar')
                    .sidebar({
                        context: $('.context .pushable')
                        dimPage: false
                        transition: 'overlay'
                        scrollLock: false
                        exclusive: true
                    })
                    .sidebar('attach events', '.context .menu .toggle_rightbar')
            , 1300



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
        Meteor.call 'set_schema', @slug, ->
            Session.set 'is_calculating', false


Template.topbar.events
    'click .set_notifications': (e,t)->
        Session.set 'is_calculating', true
        Meteor.call 'set_schema', 'notification', ->
            Session.set 'is_calculating', false

    'click .set_messages': (e,t)->
        Session.set 'is_calculating', true
        Meteor.call 'set_schema', 'message', ->
            Session.set 'is_calculating', false

    'click .set_bookmarks': (e,t)->
        Session.set 'is_calculating', true
        Meteor.call 'set_schema', 'bookmark', ->
            Session.set 'is_calculating', false

    'click .set_tasks': (e,t)->
        Session.set 'is_calculating', true
        Meteor.call 'set_schema', 'task', ->
            Session.set 'is_calculating', false



Template.rightbar.onCreated ->
    @signing_out = new ReactiveVar false

Template.rightbar.events
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


Template.rightbar.helpers
    signing_out: -> Template.instance().signing_out.get()

