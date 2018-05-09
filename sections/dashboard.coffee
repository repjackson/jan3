if Meteor.isClient
    FlowRouter.route '/', action: ->
        BlazeLayout.render 'layout', 
            main: 'dashboard'
    
    Template.dashboard.onCreated ->
        @autorun -> Meteor.subscribe('docs', [], 'office')
        @autorun -> Meteor.subscribe('docs', [], 'incident')
    Template.my_cleaning_crew.onCreated ->
        @autorun -> Meteor.subscribe('users')
    
    Template.dashboard.onRendered ->
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 400

    
    
    Template.my_cleaning_schedule.helpers
        cal_options: -> {
            # defaultView: 'agendaWeek'
            nowIndicator: true
            # customButtons:
            #     agendaAll:
            #         text: 'Agenda'
            #         click:  ()->
            #             # $('#calendar').fullCalendar('removeEventSource', 'list');
            #             # $('#calendar').fullCalendar('addEventSource', 'list'); 
            #             $('#calendar').fullCalendar('changeView', 'list');
            header:
                left: 'prev,today,next'
                center: 'month,agendaWeek,agendaDay,agendaAll'
                right: 'title'
            editable: true
            firstDay: 1
            height: 400
            selectable: true
            defaultView: 'agendaWeek'
            allDaySlot: false
            selectHelper: true
            showWeekNumbers: true
        }




    Template.local_office_information.helpers
        office: -> Docs.findOne type:'office'
    Template.general_account_info.helpers
        person: -> Docs.findOne type:'person'
    Template.my_cleaning_crew.helpers
        crew: -> Meteor.users.find {}, limit:5
    Template.incident_widget.helpers
        incidents: -> Docs.find {type:'incident'}, limit:5
    