FlowRouter.route '/admin', 
    name:'admin'
    action: -> BlazeLayout.render 'layout', main: 'admin'

FlowRouter.route '/a/:doc_type',
    name: 'content_type'
    action: (params) ->
        BlazeLayout.render 'layout',
            # nav: 'nav'
            main: 'doc_type_view'

Template.doc_type_view.helpers
    type_view: -> FlowRouter.getParam('doc_type')
        


            
Template.admin.onCreated ->
    @autorun -> Meteor.subscribe 'admin_total_stats'
    @autorun -> Meteor.subscribe 'type', 'admin_section'

Template.admin.helpers
    admin_sections: ->
        Docs.find   
            type:'admin_section'