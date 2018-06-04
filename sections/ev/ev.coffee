if Meteor.isClient
    FlowRouter.route '/ev', 
        action: ->
            BlazeLayout.render 'layout', 
                main: 'ev'
                
    FlowRouter.route '/reports', 
        action: ->
            BlazeLayout.render 'layout', 
                main: 'ev_reports'

    Template.report_view.onCreated ->
        @autorun => Meteor.subscribe 'child_docs', FlowRouter.getParam('doc_id')
    Template.ev_card.onCreated ->
        @autorun => Meteor.subscribe 'child_docs', @data._id
    
    Template.ev_reports.onCreated ->
        # @autorun => Meteor.subscribe 'type', 'report' 
        # @autorun => Meteor.subscribe 'facet', 
        #     selected_tags.array()
        #     selected_keywords.array()
        #     selected_author_ids.array()
        #     selected_location_tags.array()
        #     selected_timestamp_tags.array()
        #     type='report'
        #     author_id=null

    Template.ev_reports.helpers
        # reports: -> Docs.find {type:'report'}, limit:300
        selector: ->  type: "report"

        
    Template.report_view.helpers
        current_doc: -> JSON.stringify Docs.findOne(FlowRouter.getParam('doc_id'))

    Template.ev_reports.events
        'click .sync_reports': ->
            Meteor.call 'sync_ev_reports', (err,res)->
                if err then console.error err
                # else
                    # console.log res
                    
    Template.report_view.events
        'click .run_report': ->
            report = Docs.findOne FlowRouter.getParam('doc_id')
            Meteor.call 'run_report', report.report_id, FlowRouter.getParam('doc_id'), (err,res)->
                if err then console.error err
                # else
                    # console.dir res


# fields
    FlowRouter.route '/ev_fields', 
        action: ->
            BlazeLayout.render 'layout', main: 'ev_fields'

    Template.ev_fields.events
        'click .sync_ev_fields': ->
            Meteor.call 'sync_ev_fields',(err,res)->
                if err then console.error err
                # else
                    # console.log res
    Template.ev_fields.helpers
        selector: ->  type: "field"

# users
    FlowRouter.route '/ev_users', 
        action: ->
            BlazeLayout.render 'layout', main: 'ev_users'
    Template.ev_users.events
        'click .sync_ev_users': ->
            Meteor.call 'sync_ev_users',(err,res)->
                if err then console.error err
                # else
                    # console.log res
    Template.ev_users.helpers
        selector: ->  type: "user"

    Template.user_view.events
        'click .get_user_info': ->
            user = Docs.findOne FlowRouter.getParam('doc_id')
            Meteor.call 'get_user_info', FlowRouter.getParam('doc_id'), (err,res)->
                if err then console.error err
                # else
                    # console.dir res

# users
    FlowRouter.route '/jpids', 
        action: -> BlazeLayout.render 'layout', main: 'jpids'
    
    Template.jpids.events
        'click .get_jp_id': ->
            Meteor.call 'get_jp_id',(err,res)->
                if err then console.error err
                # else
                    # console.log res
    Template.jpids.helpers
        selector: ->  type: "jpid"

    Template.jpids.events
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
