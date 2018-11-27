Template.account_settings.events
    'click .test': ->
        # console.log 'hi'
        # $('.context .ui.top.sidebar').sidebar('toggle')
        toastr.success(
            "<button class='ui button mark_alert_read'><i class='envelope icon'></i>Mark Read</button>
            <button class='ui button view_alert'>View<i class='chevron right icon'></i></button>",
            'title', {
                timeOut:0
                closeButton:false
                # onShown: ()-> console.log('hello')
                # onHidden: ()-> console.log('goodbye')
                # positionClass:'toast-bottom-full-width'
                positionClass:'toast-top-right'
                tapToDismiss:false
                extendedTimeOut:0
                progressBar:false
                # onclick: ()-> console.log('clicked')
                # onCloseClick: ()-> console.log('close button clicked')
            });


#   "closeButton": false,
#   "debug": false,
#   "newestOnTop": false,
#   "progressBar": false,
#   "positionClass": "toast-top-right",
#   "preventDuplicates": false,
#   "onclick": null,
#   "showDuration": "300",
#   "hideDuration": "1000",
#   "timeOut": 0,
#   "extendedTimeOut": 0,
#   "showEasing": "swing",
#   "hideEasing": "linear",
#   "showMethod": "fadeIn",
#   "hideMethod": "fadeOut",
#   "tapToDismiss": false
