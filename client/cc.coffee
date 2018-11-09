FlowRouter.route '/cc', action: ->
    BlazeLayout.render 'layout',
        main: 'cc'

Template.cc.onCreated ->
    @autorun -> Meteor.subscribe 'my_blocks'

Template.cc.helpers
    my_blocks: ->
        Docs.find
            type:'block'
            block_type: 'cc'
            author_id: Meteor.userId()


Template.cc.events
    'click .add_block': ->
        # console.log 'hi'
        Docs.insert
            type:'block'
            block_type: 'cc'

