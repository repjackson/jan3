if Meteor.isClient
    Template.office_view.onCreated ->
        # @autorun -> Meteor.subscribe 'doc', FlowRouter.getParam('doc_id')
    Template.office_view.helpers
    
    
    FlowRouter.route '/offices', action: ->
        BlazeLayout.render 'layout', main: 'offices'
    
    
    # @selected_office_tags = new ReactiveArray []
    
    # Template.offices.onCreated ->
        # @autorun => Meteor.subscribe 'facet', 
        #     selected_tags.array()
        #     selected_keywords.array()
        #     selected_author_ids.array()
        #     selected_location_tags.array()
        #     selected_timestamp_tags.array()
        #     type='office'
        #     author_id=null
        
    Template.offices.helpers
        selector: ->  type: "office"
        
        
    Template.offices.onCreated () ->
        Template.instance().uploading = new ReactiveVar false 
    
    Template.offices.helpers
        uploading: -> Template.instance().uploading.get()
        
    Template.offices.events
        'change [name="upload_csv"]': (event,template)->
            template.uploading.set true

            Papa.parse event.target.files[0],
                header: true
                complete: (results,file) =>
                    Meteor.call 'parse_office_upload', results.data, (err,res)=>
                        if err
                            console.log err.reason
                        else
                            template.uploading.set false
                            Bert.alert 'Upload complete!', 'success', 'growl-top-right'
        
        
    Template.office_edit.events
        'click #delete': ->
            template = Template.currentData()
            swal {
                title: 'Delete office?'
                # text: 'Confirm delete?'
                type: 'error'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'Cancel'
                confirmButtonText: 'Delete'
                confirmButtonColor: '#da5347'
            }, =>
                doc = Docs.findOne FlowRouter.getParam('doc_id')
                # console.log doc
                Docs.remove doc._id, ->
                    FlowRouter.go "/offices"


