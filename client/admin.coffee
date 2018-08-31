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
    @autorun => Meteor.subscribe 'facet', 
        selected_tags.array()
        selected_author_ids.array()
        selected_location_tags.array()
        selected_timestamp_tags.array()
        type='admin_section'
        author_id=null

Template.admin.helpers
    admin_sections: ->
        Docs.find   
            type:'admin_section'