FlowRouter.route '/franchisees', 
    action: -> BlazeLayout.render 'layout', main: 'franchisees'


Template.franchisees.onCreated ->
    Session.setDefault('query',null)
    Session.setDefault('sort_direction','-1')

    @autorun -> Meteor.subscribe 'type', 'franchisee', Session.get('query'), parseInt(Session.get('page_size')),Session.get('sort_key'), Session.get('sort_direction'), parseInt(Session.get('skip'))

Template.franchisees.helpers
    all_franchisees: ->
        sort_object ={
            "#{Session.get('sort_key')}": "#{Session.get('sort_direction')}"
            }
        # console.log sort_object
        Session.get('sort_key')
        Docs.find {
            type:'franchisee'
            },{ 
                sort:
                    "#{Session.get('sort_key')}":parseInt("#{Session.get('sort_direction')}")
            }

Template.franchisees.events
    # 'click .get_all_franchisees': ->
    #     Meteor.call 'get_all_franchisees',(err,res)->
    #         if err then console.error err
Template.franchisee_view.onCreated ->
    @autorun => Meteor.subscribe 'office_by_franchisee', FlowRouter.getParam('doc_id')

