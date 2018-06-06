Meteor.methods
    sync_ev_reports: ()->
        self = @
        
        res = HTTP.call 'GET',"http://avalon.extraview.net/jan-pro-sandbox/ExtraView/ev_api.action",
            headers: "User-Agent": "Meteor/1.0"
            params:
                user_id:'JPI'
                password:'JPI'
                statevar:'GET_REPORTS'
        # return res.content
        split_res = res.content.split '\r\n'
        # console.log typeof split_res
        for report_string in split_res
            split_report = report_string.split '|'
            # console.log split_report
            report_ob = {}
            report_ob.report_id = split_report[0]
            report_ob.report_title = split_report[1]
            report_ob.report_type = split_report[2]
            report_ob.report_subtitle = split_report[3]
            # console.log report_ob
            if split_report[0]
                found_report = 
                    Docs.findOne 
                        type:'report'
                        report_id:split_report[0]
                
                unless found_report
                    new_report_id = Docs.insert
                        type:'report'
                        report_id:split_report[0]
                        report_title:split_report[1]
                        report_type:split_report[2]
                        report_subtitle:split_report[3]
                    console.log 'added report doc id:', new_report_id
                else
                    console.log 'existing report doc:', found_report._id
                    # new_report_id = Docs.update found_report._id,
                    #     $set:
                    #         type:'report'
                    #         report_id:split_report[0]
                    #         report_title:split_report[1]
                    #         report_type:split_report[2]
                    #         report_subtitle:split_report[3]

    run_report: (report_id, parent_id) ->
        res = HTTP.call 'GET',"http://avalon.extraview.net/jan-pro-sandbox/ExtraView/ev_api.action",
            headers:
                "User-Agent": "Meteor/1.0"
            params:
                user_id:'JPI'
                password:'JPI'
                statevar:'run_report'
                username_display:'ID'
                api_reverse_lookup:'NO'
                id:report_id
                page_length:'100'
                record_start:'1'
                record_count:'120'
                persist_handle:'xxx'
                field1:'value1'
                field2:'value2'
        # return res.content
        # console.log res.content
        xml2js.parseString res.content, {explicitArray:false, emptyTag:undefined, ignoreAttrs:true, trim:true}, (err, json_result)=>
            if err then console.error('errors',err)
            else
                # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
                # console.dir json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
                # new_id = Docs.insert 
                # console.log 'new id', new_id
            if json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD
                for doc in json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1..5]
                    # console.log doc.CUST_NAME
                    # doc.type = 'customer'
                    Docs.insert 
                        parent_id: parent_id
                        ev: doc
                        
    sync_ev_fields: ()->
        self = @
        
        res = HTTP.call 'GET',"http://avalon.extraview.net/jan-pro-sandbox/ExtraView/ev_api.action",
            headers: "User-Agent": "Meteor/1.0"
            params:
                user_id:'JPI'
                password:'JPI'
                statevar: 'fields'
                include_fields:'y'
                # select_list:field1
                
        console.dir res.content
        split_res = res.content.split '\r\n'
        
        for field_string in split_res
            split_field = field_string.split '|'
            # console.log split_field
            if split_field[0]
                found_field = 
                    Docs.findOne 
                        type:'field'
                        field_slug:split_field[0]
                
                unless found_field
                    new_field_id = Docs.insert
                        type:'field'
                        field_slug:split_field[0]
                        field_display_name:split_field[1]
                        field_display_type:split_field[2]
                    console.log 'added field doc id:', new_field_id
                else
                    console.log 'existing field doc:', found_field._id
 
    sync_ev_users: ()->
        self = @
        
        res = HTTP.call 'GET',"http://avalon.extraview.net/jan-pro-sandbox/ExtraView/ev_api.action",
            headers: "User-Agent": "Meteor/1.0"
            params:
                user_id:'JPI'
                password:'JPI'
                statevar: 'get_users'
                # disabled: [Y|N|
                # filter: pattern 
                # filter_type: "ID"


        # console.dir res.content
        split_res = res.content.split '\r\n'
        
        for user_string in split_res
            split_user = user_string.split '|'
            console.log split_user
            if split_user[0]
                found_user = 
                    Docs.findOne 
                        type:'user'
                        user_id:split_user[0]
                
                unless found_user
                    new_user_id = Docs.insert
                        type:'user'
                        user_id:split_user[0]
                        user_first_name:split_user[1]
                        user_last_name:split_user[2]
                    console.log 'added user doc id:', new_user_id
                else
                    console.log 'existing user doc:', found_user._id



    get_user_info: (user_doc_id) ->
        user_doc = Docs.findOne user_doc_id
        # console.log user_doc
        res = HTTP.call 'GET',"http://avalon.extraview.net/jan-pro-sandbox/ExtraView/ev_api.action",
            headers: "User-Agent": "Meteor/1.0"
            params:
                user_id:'JPI'
                password:'JPI'
                # statevar:'get_user_info'
                # statevar:'get_user_field_list'
                statevar:'get'
                # login_id:user_doc.user_id
                id:'33129271'
        console.log res.content
            

    get_areas: () ->
        res = HTTP.call 'GET',"http://avalon.extraview.net/jan-pro-sandbox/ExtraView/ev_api.action",
            headers: "User-Agent": "Meteor/1.0"
            params:
                user_id:'JPI'
                password:'JPI'
                statevar:'get_areas'
        console.log res.content
        split_res = res.content.split '\r\n'
        # console.log typeof split_res
        for area_string in split_res
            split_report = area_string.split '|'
            # console.log split_report
            Docs.insert
                type:'area'
                number: split_report[0]
                title: split_report[1]


    get_jp_id: (jp_id)->
        res = HTTP.call 'GET',"http://avalon.extraview.net/jan-pro-sandbox/ExtraView/ev_api.action",
            headers: "User-Agent": "Meteor/1.0"
            params:
                user_id:'JPI'
                password:'JPI'
                statevar:'get'
                id:jp_id
        # console.log res
        includes_boolean = res.content.includes("does not exist")
        if includes_boolean
            throw new Meteor.Error('no user', "JP Id #{jp_id} does not exist")
        else
            xml2js.parseString res.content, {explicitArray:false, emptyTag:undefined, ignoreAttrs:true, trim:true}, (err, json_result)=>
                if err then console.error('errors',err)
                else
                    # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
                    # console.dir json_result.PROBLEM_RECORD
                    updatedList = JSON.stringify(json_result.PROBLEM_RECORD, (key, value) ->
                        if value == undefined then '' else value
                    )
                    console.dir updatedList

                    
                    existing_jpid = 
                        Docs.findOne 
                            type: 'jpid'
                            jpid: jp_id
                    if existing_jpid
                        throw new Meteor.Error('existing doc', "Already imported #{jp_id}.")
                    else                    
                        new_jpid = Docs.insert 
                            type:'jpid'
                            jpid:jp_id
                            ev: json_result.PROBLEM_RECORD
                            
                            
    search_ev: (query)->
        res = HTTP.call 'GET',"http://avalon.extraview.net/jan-pro-sandbox/ExtraView/ev_api.action?",
            headers: "User-Agent": "Meteor/1.0"
            params:
                user_id:'JPI'
                password:'JPI'
                statevar:'search'
                page_length: 3 
                record_start: 1 
                # record_count: 10 
                # username_display: 'ID' 
                AREA: "*Bill"
                # release:{null}
                # "ASSIGNED_TO": "Brad57689 Wallace"
                # ACCOUNT_STATUS: "ACTIVE"
                # "FRANCHISEE": "Evan Cleaning LLC"


                
        console.log res.content
        # includes_boolean = res.content.includes("does not exist")
        # if includes_boolean
        #     throw new Meteor.Error('no user', "JP Id #{jp_id} does not exist")
        # else
        #     xml2js.parseString res.content, {explicitArray:false, emptyTag:undefined, ignoreAttrs:true, trim:true}, (err, json_result)=>
        #         if err then console.error('errors',err)
        #         else
        #             # json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1]
        #             console.dir json_result.PROBLEM_RECORD
        #             existing_jpid = 
        #                 Docs.findOne 
        #                     type: 'jpid'
        #                     jpid: jp_id
        #             if existing_jpid
        #                 throw new Meteor.Error('existing doc', "Already imported #{jp_id}.")
        #             else                    
        #                 Docs.insert 
        #                     type:'jpid'
        #                     jpid:jp_id
        #                     ev: json_result.PROBLEM_RECORD
                            
                            
                            
                            