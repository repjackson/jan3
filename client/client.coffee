Template.registerHelper 'delta', () -> Docs.findOne type:'delta'


Template.registerHelper 'is_admin', () ->
    if Meteor.user() and Meteor.user().roles
        'admin' in Meteor.user().roles
Template.registerHelper 'is_dev', () ->
    if Meteor.user() and Meteor.user().roles
        'dev' in Meteor.user().roles
Template.registerHelper 'dev_mode', ()->
    if Meteor.user() and Meteor.user().roles
        'dev' in Meteor.user().roles and Session.get('dev_mode')

Template.registerHelper 'is_eric', ()->
    if Meteor.user()
        'Bda8mRG925DnxTjQC' is Meteor.userId()


Template.registerHelper 'is_array', ()->
    if @primitive
        @primitive in ['array','multiref']
    # else
    #     console.log 'no primitive', @


Template.registerHelper 'is_editor', () ->
    if Meteor.user() and Meteor.user().roles
        'admin' in Meteor.user().roles
Template.registerHelper 'is_office', () ->
    if Meteor.user() and Meteor.user().roles
        'office' in Meteor.user().roles
Template.registerHelper 'is_customer', () ->
    if Meteor.user() and Meteor.user().roles
        'customer' in Meteor.user().roles

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


Template.role_switcher.onCreated ->
    @autorun -> Meteor.subscribe 'type', 'role'

Template.role_switcher.helpers
    role_docs: ->
        Docs.find
            type: 'role'

    role_button_class: ->
        if Meteor.user() and Meteor.user().roles and @slug in Meteor.user().roles then 'blue' else ''


Template.role_switcher.events
    'click .change_role': ->
        cursor = Docs.find(type:'role').fetch()
        # console.log @
        user = Meteor.user()
        if user
            if @slug in user.roles
                Meteor.users.update Meteor.userId(),
                    $pull: roles:@slug
            else
                Meteor.users.update Meteor.userId(),
                    $addToSet: roles: @slug