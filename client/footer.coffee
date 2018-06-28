Template.role_switcher.onCreated ->
    @autorun -> Meteor.subscribe 'type', 'role'

Template.role_switcher.helpers
    role_docs: -> 
        Docs.find 
            type: 'role'

Template.role_switcher.events
    'click .change_role': ->
        cursor = Docs.find(type:'role').fetch()
        console.log @
        Meteor.users.update Meteor.userId(),
            $set: roles: [@name]