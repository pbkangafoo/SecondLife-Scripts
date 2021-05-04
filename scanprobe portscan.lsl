// -----------------------------------------------------------------------
// --- Scanprobe ---------------------------------------------------------
// -----------------------------------------------------------------------

// -----------------------------------------------------------------------
// --- Type: module
// --- Func: experimental script for performing portscans from Secondlife
// --- Vers: 0.3
// --- Written by Peter Bartels
// -----------------------------------------------------------------------

// ---------------------------------------------------------------------------
// --- global definitions and storage ----------------------------------------
// ---------------------------------------------------------------------------

// -- list with scripts/paths to scan for
list scanlist = [":80",
                ":443",
                ":1010",
                ":1111",
                ":1080",
                ":1337",
                ":2020",
                ":2222",
                ":3030",
                ":3333",
                ":3128",
                ":4040",
                ":4444",
                ":5050",
                ":5555",
                ":6060",
                ":6666",
                ":7070",
                ":7777",
                ":8080",
                ":8888",
                ":9090",
                ":9999"];

// -- hands off from internal stuff!
list resp_id = [];
string url;
key http_id;
string ip = "";

// ---------------------------------------------------------------------------
// --- global functions and procedures ---------------------------------------
// ---------------------------------------------------------------------------

string code_to_plain(integer error)
{
    string code = "CODE NOT KNOWN";
    if(error == 200) { code = "FOUND"; } else
    if(error == 401) { code = "AUTHORIZATION REQUIRED"; } else
    if(error == 403) { code = "FORBIDDEN ACCESS"; } else
    if(error == 404) { code = "NOT FOUND"; } else
    if(error == 405) { code = "METHOD NOT ALLOWED"; } else
    if(error == 407) { code = "PROXY AUTH REQUIRED"; } else
    if(error == 408) { code = "TIMEOUT"; } else
    if(error == 409) { code = "CONFLICT"; } else
    if(error == 499) { code = "PORT CLOSED"; } else
    if(error == 500) { code = "INTERNAL SERVER ERROR"; } else
    if(error == 504) { code = "GATEWAY TIMEOUT"; }
    return code;
}

// ----------------------------------------------------------------------------
// --- Main part starts here --------------------------------------------------
// ----------------------------------------------------------------------------

default
{
    on_rez(integer start_param)
    {
        llResetScript();
    }

    link_message(integer sender_number, integer number, string message, key id)
    {
        if(number == 55555)
        {
            ip = message;
            integer i;
            integer max = llGetListLength(scanlist);
            for(i=0;i<max;i++)
            {
                http_id = llHTTPRequest("http://"+ip+llList2String(scanlist,i),[HTTP_METHOD,"GET"],"test");
                resp_id += [http_id];
            }
        }
    }

    http_response(key id, integer status, list metadata, string body)
    {
        integer j;
        integer max = llGetListLength(scanlist);
        for(j=0;j<max;j++)
        {
            if(id == llList2Key(resp_id,j))
            {
                llOwnerSay("--- status code: "+(string)status+" "+code_to_plain(status)+" - "+"http://"+ip+llList2String(scanlist,j));
            }
        }
    }
}