FlowRouter.route '/offices', action: ->
    BlazeLayout.render 'layout', main: 'offices'

Template.offices.helpers
    selector: ->  type: "office"
    
    
Template.office_view.onRendered ->
    Meteor.setTimeout ->
        $('.ui.tabular.menu .item').tab()
    , 500

    
Template.office_view.onCreated ->
    @autorun -> Meteor.subscribe 'office', FlowRouter.getParam('doc_id')

    
Template.office_view.helpers
    office_customers_selector: ->  
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        return {
            type: "customer"
            master_licensee: page_office.office_name
            }
    
    office_franchisees_selector: ->  
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        return {
            type: "franchisee"
            "ev.MASTER_LICENSEE": page_office.office_name
            }
    
    office_incidents_selector: ->  
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        return {
            type: "incident"
            "ev.MASTER_LICENSEE": page_office.office_name
            }
    
    office_incidents: ->  
        Docs.find
            type: 'incident'
    
    office_users_selector: ->  
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        return {
            "profile.office_name": page_office.office_name
            }
    