Meteor.methods
    call_ev: ()->
        self = @
        
        res = HTTP.call 'GET',"http://avalon.extraview.net/jan-pro-sandbox/ExtraView/ev_api.action",
            headers:
                "User-Agent": "Meteor/1.0"
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

            for doc in json_result.EXTRAVIEW_RESULTS.PROBLEM_RECORD[1..5]
                # console.log doc.CUST_NAME
                # doc.type = 'customer'
                Docs.insert 
                    parent_id: parent_id
                    ev: doc