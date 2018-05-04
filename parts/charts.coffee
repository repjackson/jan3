if Meteor.isClient
    FlowRouter.route '/charts', action: ->
        BlazeLayout.render 'layout', 
            main: 'charts'
            
            
    FlowRouter.route '/chart/edit/:doc_id', action: ->
        BlazeLayout.render 'layout', 
            main: 'edit_chart'
    
    
    FlowRouter.route '/chart/view/:doc_id', action: ->
        BlazeLayout.render 'layout', 
            main: 'view_chart'
    
    
    Template.charts.onRendered =>
        # Meteor.setTimeout (->
        #     $('table').tablesort()
        # ), 500    

    
    Template.charts.onCreated ->
        @autorun -> Meteor.subscribe('docs', selected_tags.array(), 'chart')
        
   
    Template.edit_chart.onCreated ->
        @autorun -> Meteor.subscribe('doc', FlowRouter.getParam('doc_id'))

    Template.view_chart.onCreated ->
        @autorun -> Meteor.subscribe('doc', FlowRouter.getParam('doc_id'))



    Template.charts.helpers
        charts: ->
            Docs.find type:'chart'
                
        test_chart: ->        
            {
                chart:
                    plotBackgroundColor: null
                    plotBorderWidth: null
                    plotShadow: false
                title: text: @username + '\'s top genres'
                tooltip: pointFormat: '<b>{point.percentage:.1f}%</b>'
                plotOptions: pie:
                    allowPointSelect: true
                    cursor: 'pointer'
                    dataLabels:
                        enabled: true
                        format: '<b>{point.name}</b>: {point.percentage:.1f} %'
                        style: color: Highcharts.theme and Highcharts.theme.contrastTextColor or 'black'
                        connectorColor: 'silver'
                series: [ {
                    type: 'pie'
                    name: 'genre'
                    data: [
                        [
                            'Adventure'
                            45.0
                        ]
                        [
                            'Action'
                            26.8
                        ]
                        [
                            'Ecchi'
                            12.8
                        ]
                        [
                            'Comedy'
                            8.5
                        ]
                        [
                            'Yuri'
                            6.2
                        ]
                    ]
                } ]
            }

    Template.charts.events
        'click #add_chart': ->
            id = Docs.insert type: 'chart'
            FlowRouter.go "/chart/edit/#{id}"
    
    Template.edit_chart.helpers
        chart: -> 
            doc_id = FlowRouter.getParam('doc_id')
            # console.log doc_id
            Docs.findOne doc_id 

    Template.view_chart.helpers
        chart: -> 
            doc_id = FlowRouter.getParam('doc_id')
            # console.log doc_id
            Docs.findOne doc_id 


    Template.edit_chart.events
        'click #delete_chart': (e,t)->
            swal {
                title: 'Delete chart?'
                # text: 'Confirm delete?'
                type: 'error'
                animation: false
                showCancelButton: true
                closeOnConfirm: true
                cancelButtonText: 'Cancel'
                confirmButtonText: 'Delete'
                confirmButtonColor: '#da5347'
            }, ->
                Docs.remove FlowRouter.getParam('doc_id'), ->
                    FlowRouter.go "/charts"



        'click #add_chart_number': (e,t)->
            chart_number = parseInt $('#new_chart_number').val()
            Docs.update @_id,
                $addToSet: 
                    chart_numbers: chart_number
            $('#new_chart_number').val('')
        
        'keyup #new_chart_number': (e,t)->
            if e.which is 13
                chart_number = parseInt $('#new_chart_number').val()
                Docs.update @_id,
                    $addToSet: 
                        chart_numbers: chart_number
                $('#new_chart_number').val('')
    
        'change #select_chart_street': (e,t)->
            chart_street = e.currentTarget.value
            Docs.update @_id,
                $set: chart_street: chart_street

        'click .remove_number': (e,t)->
            chart_number = @valueOf()
            Docs.update FlowRouter.getParam('doc_id'),
                $pull: 
                    chart_numbers: chart_number
            
