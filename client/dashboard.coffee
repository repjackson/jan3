FlowRouter.route '/', action: ->
    BlazeLayout.render 'layout', 
        main: 'dashboard'

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

Template.my_office_contacts.helpers
    crew: -> Meteor.users.find {_id:$ne:Meteor.userId()}, limit:5

Template.dashboard.helpers
    office_contacts: -> Meteor.users.find( _id:$ne:Meteor.userId() )
    customer_incidents: -> Docs.find type:'incident'
    my_special_services: ->
        Docs.find
            type:'special_service'