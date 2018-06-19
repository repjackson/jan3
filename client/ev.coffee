FlowRouter.route '/ev', 
    action: -> BlazeLayout.render 'layout', main: 'ev'
            
FlowRouter.route '/reports', 
    action: -> BlazeLayout.render 'layout', main: 'ev_reports'

Template.report_view.onCreated ->
    @autorun => Meteor.subscribe 'child_docs', FlowRouter.getParam('doc_id')
Template.ev_card.onCreated ->
    @autorun => Meteor.subscribe 'child_docs', @data._id

Template.ev_reports.helpers
    selector: ->  type: "report"
    
Template.report_view.helpers
    current_doc: -> JSON.stringify Docs.findOne(FlowRouter.getParam('doc_id'))

Template.ev_reports.events
    'click .sync_reports': ->
        Meteor.call 'sync_ev_reports', (err,res)->
            if err then console.error err
                
Template.report_view.events
    'click .run_report': ->
        report = Docs.findOne FlowRouter.getParam('doc_id')
        Meteor.call 'run_report', report.report_id, FlowRouter.getParam('doc_id'), (err,res)->
            if err then console.error err


# fields
FlowRouter.route '/ev_fields', 
    action: -> BlazeLayout.render 'layout', main: 'ev_fields'

Template.ev_fields.events
    'click .sync_ev_fields': ->
        Meteor.call 'sync_ev_fields',(err,res)->
            if err then console.error err
Template.ev_fields.helpers
    selector: ->  type: "field"

# history
FlowRouter.route '/history', 
    action: -> BlazeLayout.render 'layout', main: 'history'

Template.history.events
    'click .refresh_history': ->
        Meteor.call 'get_history',(err,res)->
            if err then console.error err
Template.history.helpers
    selector: ->  type: "history"


# jpids
FlowRouter.route '/jpids', 
    action: -> BlazeLayout.render 'layout', main: 'jpids'
Template.jpids.helpers
    selector: ->  type: "jpid"
Template.jpids.events
    'click .get_jp_id': ->
        Meteor.call 'get_jp_id',(err,res)->
            if err then console.error err
    'keyup #jp_lookup': (e,t)->
        e.preventDefault()
        val = $('#jp_lookup').val().trim()
        if e.which is 13
            unless val.length is 0
                Meteor.call 'get_jp_id', val.toString(), (err,res)=>
                    if err
                        Bert.alert "#{err.reason}", 'danger', 'growl-top-right'
                    else
                        Bert.alert "Added JP ID #{val}", 'success', 'growl-top-right'
                    $('#jp_lookup').val ''

Template.jpid_view.events
    'click .refresh_jpid': (e,t)->
        doc = Docs.findOne FlowRouter.getParam('doc_id')
        Meteor.call 'get_jp_id', doc.jpid, (err,res)=>
            if err
                Bert.alert "#{err.reason}", 'danger', 'growl-top-right'
            else
                Bert.alert "Updated JP ID #{doc.jpid}", 'success', 'growl-top-right'

    # 'keyup #office_lookup': (e,t)->
    #     e.preventDefault()
    #     val = $('#office_lookup').val().trim()
    #     if e.which is 13
    #         unless val.length is 0
    #             Meteor.call 'search_ev', val.toString(), (err,res)=>
    #                 if err
    #                     Bert.alert "#{err.reason}", 'danger', 'growl-top-right'
    #                 else
    #                     Bert.alert "Searched #{val}", 'success', 'growl-top-right'
    #                 $('#office_lookup').val ''


# areas
FlowRouter.route '/areas', 
    action: -> BlazeLayout.render 'layout', main: 'areas'
Template.areas.helpers
    selector: ->  type: "area"


# meta
FlowRouter.route '/meta', 
    action: -> BlazeLayout.render 'layout', main: 'meta'
Template.meta.helpers
    selector: ->  type: "meta"


# franchisee
FlowRouter.route '/franchisees', 
    action: -> BlazeLayout.render 'layout', main: 'franchisees'
Template.franchisees.helpers
    selector: ->  type: "franchisee"
Template.franchisees.events
    'click .get_all_franchisees': ->
        Meteor.call 'get_all_franchisees',(err,res)->
            if err then console.error err
Template.franchisee_view.onCreated ->
    @autorun => Meteor.subscribe 'office_by_franchisee', FlowRouter.getParam('doc_id')



# customer
FlowRouter.route '/customers', 
    action: -> BlazeLayout.render 'layout', main: 'customers'
Template.customers.helpers
    selector: ->  type: "customer"
Template.customers.events
    'click .sync_customers': ->
        Meteor.call 'sync_customers',(err,res)->
            if err then console.error err


Template.related_customers.helpers
    selector: ->  
        page_doc = Docs.findOne FlowRouter.getParam('doc_id')
        return {
            type: "customer"
            franchisee: page_doc.franchisee
        }
            
Template.franchise_by_customer.helpers
    selector: ->  
        page_doc = Docs.findOne FlowRouter.getParam('doc_id')
        return {
            type: "franchisee"
            franchisee: page_doc.franchisee
        }
            
