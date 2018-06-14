FlowRouter.route '/offices', action: ->
    BlazeLayout.render 'layout', main: 'offices'

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
    
Template.customers_by_office.helpers
    selector: ->  
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        return {
            type: "customer"
            master_licensee: page_office.office_name
            }
    
    
Template.users_by_office.helpers
    selector: ->  
        page_office = Docs.findOne FlowRouter.getParam('doc_id')
        return {
            "profile.office_name": page_office.office_name
            }
    
    
    
    
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


