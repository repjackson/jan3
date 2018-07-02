FlowRouter.route '/offices', action: ->
    BlazeLayout.render 'layout', main: 'offices'

Template.offices.onCreated ->
    @autorun => Meteor.subscribe 'type', 'office'
    @autorun -> Meteor.subscribe 'office_counter_publication'

Template.offices.helpers
    current_office_counter: -> Counts.get 'office_counter'
    office_docs: -> Docs.find type: "office"

Template.office_admin_section.onRendered ->
    Meteor.setTimeout ->
        $('.ui.tabular.menu .item').tab()
    , 500
    # Meteor.setTimeout ->
    #     $('.checkbox').checkbox()
    # , 500

    
Template.office_view.onCreated ->
    @autorun -> Meteor.subscribe 'office', FlowRouter.getParam('doc_id')

    
Template.office_admin_section.helpers
    current_office: ->
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        # console.log page_office
        return page_office
        
    office_customers_selector: ->  
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        Docs.find
            type: "customer"
            master_licensee: page_office.office_name
    
    related_franchisees: ->  
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        Docs.find
            type: "franchisee"
            "ev.MASTER_LICENSEE": page_office.office_name
    
    office_incidents: ->  
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        Docs.find
            type: "incident"
            "ev.MASTER_LICENSEE": page_office.office_name
    
    office_employees: ->  
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        Meteor.users.find
            "profile.office_name": page_office.office_name
    