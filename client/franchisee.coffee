FlowRouter.route '/franchisees', 
    action: -> BlazeLayout.render 'layout', main: 'franchisees'
    
Template.franchisees.helpers
    settings: ->
        collection: 'franchisees'
        rowsPerPage: 10
        showFilter: true
        showRowCount: true
        # showColumnToggles: true
        fields: [
            { key: 'ev.ID', label: 'JPID' }
            { key: 'ev.FRANCHISEE', label: 'Name' }
            { key: 'ev.FRANCH_EMAIL', label: 'Email' }
            { key: 'ev.FRANCH_NAME', label: 'Short Name' }
            { key: 'ev.TELE_CELL', label: 'Phone' }
            { key: 'ev.MASTER_LICENSEE', label: 'Office' }
            # { key: 'ev.ACCOUNT_STATUS', label: 'Status' }
            { key: '', label: 'View', tmpl:Template.view_button }
        ]

Template.franchisees.events
    'click .get_all_franchisees': ->
        Meteor.call 'get_all_franchisees',(err,res)->
            if err then console.error err
Template.franchisee_view.onCreated ->
    @autorun => Meteor.subscribe 'office_by_franchisee', FlowRouter.getParam('doc_id')

