FlowRouter.route '/help',
    name:'help'
    action: ->
        BlazeLayout.render 'layout',
            main: 'help'


Template.help.onCreated ->
