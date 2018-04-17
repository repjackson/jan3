if Meteor.isClient
    Template.slider.onRendered ->
        Meteor.setTimeout (->
            $('#layerslider').layerSlider
                autoStart: true
                # firstLayer: 1
                # skin: 'borderlesslight'
                # skinsPath: '/static/layerslider/skins/'
            ), 500
