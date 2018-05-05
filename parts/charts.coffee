if Meteor.isClient
    FlowRouter.route '/charts', 
        action: ->
            selected_timestamp_tags.clear()
            selected_keywords.clear()
            BlazeLayout.render 'layout', 
                main: 'charts'

    Template.charts.onCreated ->
        @autorun => Meteor.subscribe 'facet', 
            selected_tags.array()
            selected_keywords.array()
            selected_author_ids.array()
            selected_location_tags.array()
            selected_timestamp_tags.array()
            type='task'
            author_id=null



    Template.charts.helpers
        charts: -> Docs.find type:'chart'
                
        area: -> 
            {
                chart: type: 'area'
                title:text: 'US and USSR nuclear stockpiles'
                credits: enabled: false
                subtitle: text: 'Source: <a href="http://thebulletin.metapress.com/content/c4120650912x74k7/fulltext.pdf">' + 'thebulletin.metapress.com</a>'
                xAxis:
                    allowDecimals: false
                    labels: formatter: ->
                        @value
                        # clean, unformatted number for year
                yAxis:
                    title: text: 'Nuclear weapon states'
                    labels: formatter: ->
                        @value / 1000 + 'k'
                tooltip: pointFormat: '{series.name} produced <b>{point.y:,.0f}</b><br/>warheads in {point.x}'
                plotOptions: area:
                    pointStart: 1940
                    marker:
                        enabled: false
                        symbol: 'circle'
                        radius: 2
                        states: hover: enabled: true
                series: [
                    {
                        name: 'USA'
                        data: [
                            null
                            null
                            null
                            null
                            null
                            6
                            11
                            32
                            110
                            235
                            369
                            640
                            1005
                            1436
                            2063
                            3057
                            4618
                            6444
                            9822
                            15468
                            20434
                            24126
                            27387
                            29459
                            31056
                            31982
                            32040
                            31233
                            29224
                            27342
                            26662
                            26956
                            27912
                            28999
                            28965
                            27826
                            25579
                            25722
                            24826
                            24605
                            24304
                            23464
                            23708
                            24099
                            24357
                            24237
                            24401
                            24344
                            23586
                            22380
                            21004
                            17287
                            14747
                            13076
                            12555
                            12144
                            11009
                            10950
                            10871
                            10824
                            10577
                            10527
                            10475
                            10421
                            10358
                            10295
                            10104
                        ]
                    }
                    {
                        name: 'USSR/Russia'
                        data: [
                            null
                            null
                            null
                            null
                            null
                            null
                            null
                            null
                            null
                            null
                            5
                            25
                            50
                            120
                            150
                            200
                            426
                            660
                            869
                            1060
                            1605
                            2471
                            3322
                            4238
                            5221
                            6129
                            7089
                            8339
                            9399
                            10538
                            11643
                            13092
                            14478
                            15915
                            17385
                            19055
                            21205
                            23044
                            25393
                            27935
                            30062
                            32049
                            33952
                            35804
                            37431
                            39197
                            45000
                            43000
                            41000
                            39000
                            37000
                            35000
                            33000
                            31000
                            29000
                            27000
                            25000
                            24000
                            23000
                            22000
                            21000
                            20000
                            19000
                            18000
                            18000
                            17000
                            16000
                        ]
                    } ]
            }
                
        pie: ->     
            tags = Tags.find().fetch()
            pie_data = []
            for tag in tags
                pie_data.push(
                    [
                        tag.name
                        tag.count
                    ]
                )

            {
                chart:
                    plotBackgroundColor: null
                    plotBorderWidth: null
                    plotShadow: false
                title: text: 'area'
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
                    name: 'tag'
                    data: pie_data
                } ]
            }
        gauge: ->
            {
                chart: type: 'solidgauge'
                title: null
                pane:
                    center: [
                        '50%'
                        '85%'
                    ]
                    size: '140%'
                    startAngle: -90
                    endAngle: 90
                    background:
                        backgroundColor: '#EEE'
                        innerRadius: '60%'
                        outerRadius: '100%'
                        shape: 'arc'
                tooltip: enabled: false
                yAxis:
                    min: 0
                    max: 200
                    title: text: 'Speed'
                    stops: [
                        [
                            0.1
                            '#55BF3B'
                        ]
                        [
                            0.5
                            '#DDDF0D'
                        ]
                        [
                            0.9
                            '#DF5353'
                        ]
                    ]
                    lineWidth: 0
                    minorTickInterval: null
                    tickPixelInterval: 400
                    tickWidth: 0
                    title: y: -70
                    labels: y: 16
                plotOptions: solidgauge: dataLabels:
                    y: 5
                    borderWidth: 0
                    useHTML: true
                credits: enabled: false
                series: [ {
                    name: 'Speed'
                    data: [ 80 ]
                    dataLabels: format: '<div style="text-align:center"><span style="font-size:25px;color:#7e7e7e">{y}</span><br/>' + '<span style="font-size:12px;color:silver">km/h</span></div>'
                    tooltip: valueSuffix: ' km/h'
                }]
                }
                
    #     maps: ->
    #         Template.myTemplate.mapConfig = ->
            # mapData = Highcharts.geojson(Highcharts.maps['custom/world'])
            # $.each mapData, ->
            #     @id = @properties['hc-key']
            #     return
            # {
            #     title: text: 'My highmap'
            #     mapNavigation:
            #         enabled: true
            #         buttonOptions: verticalAlign: 'bottom'
            #     colorAxis:
            #         type: 'logarithmic'
            #         endOnTick: false
            #         startOnTick: false
            #         min: 50000
            #     series: [ {
            #         data: [
            #             {
            #                 code3: 'BR'
            #                 name: 'Brazil'
            #                 value: 2500000
            #             }
            #             {
            #                 code3: 'ES'
            #                 name: 'Spain'
            #                 value: 10000
            #             }
            #             {
            #                 code3: 'US'
            #                 name: 'United States'
            #                 value: 300000
            #             }
            #         ]
            #         mapData: mapData
            #         joinBy: [
            #             'iso-a2'
            #             'code3'
            #         ]
            #         name: 'Some text here'
            #         allowPointSelect: true
            #         cursor: 'pointer'
            #         states: select:
            #             color: '#a4edba'
            #             borderColor: 'black'
            #             dashStyle: 'shortdot'
            #     } ]
            # }


        threed: ->
            {
                chart:
                    type: 'pie'
                    options3d:
                        enabled: true
                        alpha: 45
                        beta: 0
                title: text: 'Browser market shares at a specific website, 2014'
                tooltip: pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
                plotOptions: pie:
                    allowPointSelect: true
                    cursor: 'pointer'
                    depth: 35
                    dataLabels:
                        enabled: true
                        format: '{point.name}'
                series: [ {
                    type: 'pie'
                    name: 'Browser share'
                    data: [
                        [
                            'Firefox'
                            45.0
                        ]
                        [
                            'IE'
                            26.8
                        ]
                        {
                            name: 'Chrome'
                            y: 12.8
                            sliced: true
                            selected: true
                        }
                        [
                            'Safari'
                            8.5
                        ]
                        [
                            'Opera'
                            6.2
                        ]
                        [
                            'Others'
                            0.7
                        ]
                    ]
                } ]
            }
        
        column: ->
            {
                chart: type: 'column'
                title: text: 'Monthly Average Rainfall'
                subtitle: text: 'Source: WorldClimate.com'
                credits: enabled: false
                xAxis: categories: [
                    'Jan'
                    'Feb'
                    'Mar'
                    'Apr'
                    'May'
                    'Jun'
                    'Jul'
                    'Aug'
                    'Sep'
                    'Oct'
                    'Nov'
                    'Dec'
                ]
                yAxis:
                    min: 0
                    title: text: 'Rainfall (mm)'
                tooltip:
                    headerFormat: '<span style="font-size:10px">{point.key}</span><table>'
                    pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' + '<td style="padding:0"><b>{point.y:.1f} mm</b></td></tr>'
                    footerFormat: '</table>'
                    shared: true
                    useHTML: true
                plotOptions: column:
                    pointPadding: 0.2
                    borderWidth: 0
                series: [
                    {
                        name: 'Tokyo'
                        data: [
                            49.9
                            71.5
                            106.4
                            129.2
                            144.0
                            176.0
                            135.6
                            148.5
                            216.4
                            194.1
                            95.6
                            54.4
                        ]
                    }
                    {
                        name: 'New York'
                        data: [
                            83.6
                            78.8
                            98.5
                            93.4
                            106.0
                            84.5
                            105.0
                            104.3
                            91.2
                            83.5
                            106.6
                            92.3
                        ]
                    }
                    {
                        name: 'London'
                        data: [
                            48.9
                            38.8
                            39.3
                            41.4
                            47.0
                            48.3
                            59.0
                            59.6
                            52.4
                            65.2
                            59.3
                            51.2
                        ]
                    }
                    {
                        name: 'Berlin'
                        data: [
                            42.4
                            33.2
                            34.5
                            39.7
                            52.6
                            75.5
                            57.4
                            60.4
                            47.6
                            39.1
                            46.8
                            51.1
                        ]
                    }
                ]
            }
            
        rgauge: ->
            chart = undefined
            data = new Array
            data[0] = 80
            if Session.get('reactive') != undefined
                data[0] = Session.get('reactive')
            {
                chart: type: 'solidgauge'
                title: null
                pane:
                    center: [
                        '50%'
                        '85%'
                    ]
                    size: '140%'
                    startAngle: -90
                    endAngle: 90
                    background:
                        backgroundColor: '#EEE'
                        innerRadius: '60%'
                        outerRadius: '100%'
                        shape: 'arc'
                tooltip: enabled: false
                yAxis:
                    stops: [
                        [
                            0.1
                            '#55BF3B'
                        ]
                        [
                            0.5
                            '#DDDF0D'
                        ]
                        [
                            0.9
                            '#DF5353'
                        ]
                    ]
                    lineWidth: 0
                    minorTickInterval: null
                    tickPixelInterval: 400
                    tickWidth: 0
                    title: y: -70
                    labels: y: 16
                    min: 0
                    max: 200
                    title: text: 'Speed'
                plotOptions: solidgauge: dataLabels:
                    y: 5
                    borderWidth: 0
                    useHTML: true
                credits: enabled: false
                series: [ {
                    name: 'Speed'
                    data: data
                    dataLabels: format: '<div style="text-align:center"><span style="font-size:25px;color:black">{y}</span><br/>' + '<span style="font-size:12px;color:silver">km/h</span></div>'
                    tooltip: valueSuffix: ' km/h'
                } ]
            }


    Template.charts.events = 'change #reactive': (event, template) ->
        newValue = $(event.target).val()
        Session.set 'reactive', parseInt(newValue)
