FlowRouter.route '/user/edit/:user_id', action: (params) ->
    BlazeLayout.render 'layout',
        main: 'user_edit'

Template.user_edit.onCreated ->
    @autorun -> Meteor.subscribe 'user_profile', FlowRouter.getParam('user_id')


Template.user_edit.helpers
    edit_user: -> Meteor.users.findOne FlowRouter.getParam('user_id')

Template.user_edit.events
    'keydown #input_image_id': (e,t)->
        if e.which is 13
            user_id = FlowRouter.getParam('user_id')
            image_id = $('#input_image_id').val().toLowerCase().trim()
            if image_id.length > 0
                Meteor.users.update user_id,
                    $set: image_id: image_id
                $('#input_image_id').val('')


    # "change input[type='file']": (e) ->
    #     files = e.currentTarget.files
    #     Cloudinary.upload files[0],
    #         # folder:"secret" # optional parameters described in http://cloudinary.com/documentation/upload_images#remote_upload
    #         # type:"private" # optional: makes the image accessible only via a signed url. The signed url is available publicly for 1 hour.
    #         (err,res) -> #optional callback, you can catch with the Cloudinary collection as well
    #             # console.log "Upload Error: #{err}"
    #             # console.dir res
    #             if err
    #                 console.error 'Error uploading', err
    #             else
    #                 Meteor.users.update FlowRouter.getParam('user_id'),
    #                     $set: "profile.image_id": res.public_id
    #             return

    'click #remove_photo': ->
        if confirm 'Remove Profile Photo?'
            Meteor.users.update FlowRouter.getParam('user_id'),
                $unset: "image_id": 1
