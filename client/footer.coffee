Template.role_switcher.onCreated ->
    @autorun -> Meteor.subscribe 'type', 'role'

Template.role_switcher.helpers
    role_docs: -> 
        Docs.find 
            type: 'role'

    role_button_class: ->
        if Meteor.user() and Meteor.user().roles and @name in Meteor.user().roles then 'blue' else ''



Template.role_switcher.events
    'click .change_role': ->
        cursor = Docs.find(type:'role').fetch()
        # console.log @
        Meteor.users.update Meteor.userId(),
            $set: roles: [@name]