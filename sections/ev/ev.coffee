if Meteor.isClient
    FlowRouter.route '/ev', 
        action: ->
            BlazeLayout.render 'layout', 
                main: 'ev'
                
    FlowRouter.route '/reports', 
        action: ->
            BlazeLayout.render 'layout', 
                main: 'ev_reports'
    FlowRouter.route '/evfields', 
        action: ->
            BlazeLayout.render 'layout', 
                main: 'ev_fields'

    Template.report_view.onCreated ->
        @autorun => Meteor.subscribe 'child_docs', FlowRouter.getParam('doc_id')
    Template.ev_card.onCreated ->
        @autorun => Meteor.subscribe 'child_docs', @data._id
    
    Template.ev_reports.onCreated ->
        # @autorun => Meteor.subscribe 'type', 'report' 
        @autorun => Meteor.subscribe 'facet', 
            selected_tags.array()
            selected_keywords.array()
            selected_author_ids.array()
            selected_location_tags.array()
            selected_timestamp_tags.array()
            type='report'
            author_id=null

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
    Template.ev_fields.onCreated ->
        # @autorun => Meteor.subscribe 'type', 'field' 

    Template.ev_fields.events
        'click .sync_ev_fields': ->
            Meteor.call 'sync_ev_fields',(err,res)->
                if err then console.error err
                # else
                    # console.log res

    Template.ev_fields.helpers
        # fields: -> Docs.find {type:'field'}, limit:100
        selector: ->  type: "field"

