Template.delta.onCreated ->
    @autorun -> Meteor.subscribe 'me'
    @autorun -> Meteor.subscribe 'nav_items'
    @autorun -> Meteor.subscribe 'my_customer_account'
    @autorun -> Meteor.subscribe 'my_franchisee'
    @autorun -> Meteor.subscribe 'my_office'
    @autorun -> Meteor.subscribe 'my_schemas'
    @autorun -> Meteor.subscribe 'my_bookmarks'


Template.nav.onRendered ->
    # Meteor.setTimeout ->
    #     $('.item').popup()
    # , 1000



# Template.nav.onRendered ->
#     Meteor.setTimeout ->
#         $('.dropdown').dropdown()
#     , 500


Template.delta.helpers
    bookmarks: ->
        Docs.find
            # bookmark_ids: $in:[Meteor.userId()]
            type:'schema'




Template.nav.events
    'click .delta_franchisees': (e,t)->
        e.preventDefault()
        doc = { slug:'franchisee' }
        Session.set 'is_calculating', true
        # console.log 'hi call'
        Meteor.call 'set_schema', doc, ->
            Session.set 'is_calculating', false


    'click .delta_customers': (e,t)->
        e.preventDefault()
        doc = { slug:'customer' }
        Session.set 'is_calculating', true
        # console.log 'hi call'
        Meteor.call 'set_schema', doc, ->
            Session.set 'is_calculating', false

    'click #toggle_editing': ->
        Session.set('editing_mode',!Session.get('editing_mode'))

