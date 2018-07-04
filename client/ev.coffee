# history
FlowRouter.route '/history', 
    action: -> BlazeLayout.render 'layout', main: 'history'
Template.history.onCreated ->
    @autorun => Meteor.subscribe 'type', 'history'
    @autorun => Meteor.subscribe 'type', 'search_history_doc'
Template.history.helpers
    history_docs: ->  
        Docs.find {
            type:'history' 
            }, sort: "ev.TIMESTAMP": -1
    search_history_docs: ->  
        Docs.find {
            type:'search_history_doc' 
            }, sort: "ev.TIMESTAMP": -1

Template.history.events
    'click .refresh_history': ->
        Meteor.call 'get_history',(err,res)->
            if err then console.error err
    'click .run_timestamp_search': ->
        Meteor.call 'search_ev',(err,res)->
            if err then console.error err


# jpids
FlowRouter.route '/jpids', 
    action: -> BlazeLayout.render 'layout', main: 'jpids'
Template.jpids.onCreated ->
    @autorun => Meteor.subscribe 'type', 'jpid'
Template.jpids.helpers
    jpid_docs: ->  
        Docs.find 
            type: "jpid"
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

Template.jpids.events
    'keyup #ev_search': (e,t)->
        e.preventDefault()
        val = $('#ev_search').val().trim()
        if e.which is 13
            unless val.length is 0
                Meteor.call 'search_ev', val.toString(), (err,res)=>
                    if err
                        Bert.alert "#{err.reason}", 'danger', 'growl-top-right'
                    else
                        Bert.alert "Searched #{val}", 'success', 'growl-top-right'
                    $('#ev_search').val ''




# franchisee
FlowRouter.route '/franchisees', 
    action: -> BlazeLayout.render 'layout', main: 'franchisees'
    
Template.franchisees.helpers
    settings: ->
        collection: 'franchisees'
        rowsPerPage: 20
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
            { key: '', label: 'View', tmpl:Template.view_button }
        ]

Template.franchisees.events
    'click .get_all_franchisees': ->
        Meteor.call 'get_all_franchisees',(err,res)->
            if err then console.error err
Template.franchisee_view.onCreated ->
    @autorun => Meteor.subscribe 'office_by_franchisee', FlowRouter.getParam('doc_id')

