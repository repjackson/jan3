if Meteor.isClient
    FlowRouter.route '/ev', 
        action: ->
            selected_timestamp_tags.clear()
            BlazeLayout.render 'layout', 
                main: 'ev'

    Template.report_view.onCreated ->
        @autorun => Meteor.subscribe 'child_docs', FlowRouter.getParam('doc_id')
    Template.ev.onCreated ->
        @autorun => Meteor.subscribe 'facet', 
            selected_tags.array()
            selected_keywords.array()
            selected_author_ids.array()
            selected_location_tags.array()
            selected_timestamp_tags.array()
            type='report'
            author_id=null

    Template.ev.helpers
        reports: -> Docs.find {type:'report'}, limit:20
    Template.report_view.helpers
        current_doc: -> JSON.stringify Docs.findOne(FlowRouter.getParam('doc_id'))

    Template.ev.events
        'click .call_ev': ->
            Meteor.call 'call_ev', (err,res)->
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
