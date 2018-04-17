if Meteor.isClient
    FlowRouter.route '/bikes', action: ->
        BlazeLayout.render 'layout', 
            main: 'bikes'
            
            
    FlowRouter.route '/bikes/edit/:doc_id', action: ->
        BlazeLayout.render 'layout', 
            main: 'edit_bike'
    
    
    
    Template.bike.onRendered ->
        Meteor.setTimeout (->
            $('.shape').shape()
        ), 500


    Template.bikes.onCreated ->
        @autorun -> Meteor.subscribe('docs', selected_tags.array(), 'bike')

    Template.edit_bike.onCreated ->
        @autorun -> Meteor.subscribe('doc', FlowRouter.getParam('doc_id'))

    
    Template.bikes.helpers
        bikes: -> 
            Docs.find 
                type: 'bike'
         
         
    Template.bike.events
        'click .flip_shape': (e,t)->
            $(e.currentTarget).closest('.shape').shape('flip right');
            # console.log $(e.currentTarget).closest('.shape').shape('flip up')
            # $('.shape').shape('flip up')
         
         
                
    Template.bikes.events
        'click #add_impounded_bike': ->
            id = Docs.insert
                type: 'bike'
            FlowRouter.go "/bikes/edit/#{id}"
    

    Template.edit_bike.helpers
        doc: -> 
            doc_id = FlowRouter.getParam 'doc_id'
            Docs.findOne  doc_id

    Template.edit_bike.events
        'click #delete_bike': ->
            swal {
                title: 'Delete?'
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
                Docs.remove doc._id, ->
                    FlowRouter.go "/bikes"
                    
        "change #upload_handlebar_image": (e) ->
            doc_id = FlowRouter.getParam('doc_id')
            files = e.currentTarget.files
    
    
            Cloudinary.upload files[0],
                # folder:"secret" # optional parameters described in http://cloudinary.com/documentation/upload_images#remote_upload
                # type:"private" # optional: makes the image accessible only via a signed url. The signed url is available publicly for 1 hour.
                (err,res) -> #optional callback, you can catch with the Cloudinary collection as well
                    # console.log "Upload Error: #{err}"
                    # console.dir res
                    if err
                        console.error 'Error uploading', err
                    else
                        Docs.update doc_id, $set: handlebar_image_id: res.public_id
                    return
        
        "change #upload_frame_image": (e) ->
            doc_id = FlowRouter.getParam('doc_id')
            files = e.currentTarget.files
    
    
            Cloudinary.upload files[0],
                # folder:"secret" # optional parameters described in http://cloudinary.com/documentation/upload_images#remote_upload
                # type:"private" # optional: makes the image accessible only via a signed url. The signed url is available publicly for 1 hour.
                (err,res) -> #optional callback, you can catch with the Cloudinary collection as well
                    # console.log "Upload Error: #{err}"
                    # console.dir res
                    if err
                        console.error 'Error uploading', err
                    else
                        Docs.update doc_id, $set: frame_image_id: res.public_id
                    return
        
        "change #upload_seat_image": (e) ->
            doc_id = FlowRouter.getParam('doc_id')
            files = e.currentTarget.files
    
    
            Cloudinary.upload files[0],
                # folder:"secret" # optional parameters described in http://cloudinary.com/documentation/upload_images#remote_upload
                # type:"private" # optional: makes the image accessible only via a signed url. The signed url is available publicly for 1 hour.
                (err,res) -> #optional callback, you can catch with the Cloudinary collection as well
                    # console.log "Upload Error: #{err}"
                    # console.dir res
                    if err
                        console.error 'Error uploading', err
                    else
                        Docs.update doc_id, $set: seat_image_id: res.public_id
                    return
    
        # 'keydown #input_image_id': (e,t)->
        #     if e.which is 13
        #         doc_id = FlowRouter.getParam('doc_id')
        #         image_id = $('#input_image_id').val().toLowerCase().trim()
        #         if image_id.length > 0
        #             Docs.update doc_id,
        #                 $set: image_id: image_id
        #             $('#input_image_id').val('')
    
    
    
        'click #remove_handlebar_photo': ->
            swal {
                title: 'Remove Photo?'
                type: 'warning'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'No'
                confirmButtonText: 'Remove'
                confirmButtonColor: '#da5347'
            }, =>
                Meteor.call "c.delete_by_public_id", @image_id, (err,res) ->
                    if not err
                        # Do Stuff with res
                        # console.log res
                        Docs.update FlowRouter.getParam('doc_id'), 
                            $unset: handlebar_image_id: 1
    
                    else
                        throw new Meteor.Error "it failed miserably"
        'click #remove_frame_photo': ->
            swal {
                title: 'Remove Frame Photo?'
                type: 'warning'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'No'
                confirmButtonText: 'Remove'
                confirmButtonColor: '#da5347'
            }, =>
                Meteor.call "c.delete_by_public_id", @image_id, (err,res) ->
                    if not err
                        # Do Stuff with res
                        # console.log res
                        Docs.update FlowRouter.getParam('doc_id'), 
                            $unset: frame_image_id: 1
    
                    else
                        throw new Meteor.Error "it failed miserably"
        'click #remove_seat_photo': ->
            swal {
                title: 'Remove Seat Photo?'
                type: 'warning'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'No'
                confirmButtonText: 'Remove'
                confirmButtonColor: '#da5347'
            }, =>
                Meteor.call "c.delete_by_public_id", @image_id, (err,res) ->
                    if not err
                        # Do Stuff with res
                        # console.log res
                        Docs.update FlowRouter.getParam('doc_id'), 
                            $unset: seat_image_id: 1
    
                    else
                        throw new Meteor.Error "it failed miserably"
                        