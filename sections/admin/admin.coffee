
FlowRouter.route '/admin', action: (params) ->
    BlazeLayout.render 'layout',
        nav: 'nav'
        sub_nav: 'admin_nav'
        main: 'admin'
 
 
if Meteor.isClient
    Template.admin_nav.onRendered ->
        # Meteor.setTimeout ->
        #     $('.item').popup()
        # , 400
        


    
    Template.task_widget.onCreated ->
        @autorun ->  Meteor.subscribe 'docs', [], 'task'
    Template.task_widget.helpers
        tasks: -> 
            Docs.find
                type:'task'
                complete:false
    
    Template.role_widget.onCreated ->
        @autorun ->  Meteor.subscribe 'docs', [], 'role'
    Template.role_widget.helpers
        roles: -> Docs.find type:'role'
    
    
    Template.rule_widget.onCreated ->
        @autorun ->  Meteor.subscribe 'docs', [], 'rule'
    Template.rule_widget.helpers
        rules: -> Docs.find type:'rule'
    

    Template.widget_list.onCreated ->
        @autorun =>  Meteor.subscribe 'docs', [], @data.type
    Template.widget_list.helpers
        type_docs: -> Docs.find type:Template.currentData().type
    




    
    
