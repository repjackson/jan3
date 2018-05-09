if Meteor.isClient
    FlowRouter.route '/front', action: ->
        BlazeLayout.render 'layout', 
            main: 'front'
    
    Template.front.onCreated ->
        # @autorun -> Meteor.subscribe('docs', [], 'office')
        # @autorun -> Meteor.subscribe('docs', [], 'incident')
    Template.my_cleaning_crew.onCreated ->
        # @autorun -> Meteor.subscribe('docs', [], 'person')
    
    Template.front.onRendered ->
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 400

        Meteor.setTimeout ->
            $('.masthead').visibility
                once: false
                # onBottomPassed: ->
                #     $('.fixed.menu').transition 'fade in'
                #     console.log 'bottom passed'
                # onBottomPassedReverse: ->
                #     $('.fixed.menu').transition 'fade out'
                #     console.log 'bottom passed'
        , 400

    
    
    # Template.my_cleaning_schedule.helpers
    #     cal_options: -> {
    #         # defaultView: 'agendaWeek'
    #         nowIndicator: true
    #         # customButtons:
    #         #     agendaAll:
    #         #         text: 'Agenda'
    #         #         click:  ()->
    #         #             # $('#calendar').fullCalendar('removeEventSource', 'list');
    #         #             # $('#calendar').fullCalendar('addEventSource', 'list'); 
    #         #             $('#calendar').fullCalendar('changeView', 'list');
    #         header:
    #             left: 'prev,today,next'
    #             center: 'month,agendaWeek,agendaDay,agendaAll'
    #             right: 'title'
    #         editable: true
    #         firstDay: 1
    #         height: 400
    #         selectable: true
    #         defaultView: 'agendaWeek'
    #         allDaySlot: false
    #         selectHelper: true
    #         showWeekNumbers: true
    #     }




    # Template.local_office_information.helpers
    #     office: -> Docs.findOne type:'office'
    # Template.general_account_info.helpers
    #     person: -> Docs.findOne type:'person'
    # Template.my_cleaning_crew.helpers
    #     crew: -> Docs.find {type:'person'}, limit:5
    # Template.incident_widget.helpers
    #     incidents: -> Docs.find {type:'incident'}, limit:5
    