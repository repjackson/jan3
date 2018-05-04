if Meteor.isClient
    FlowRouter.route '/charts', action: ->
        BlazeLayout.render 'layout', 
            main: 'charts'
    
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