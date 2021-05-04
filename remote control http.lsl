// -----------------------------------------------------------------------------------------------
// --- Project: Remote Scan Module
// -----------------------------------------------------------------------------------------------

// -----------------------------------------------------------------------------------------------
// --- Type: Module 
// --- Name: Web module
// --- Vers: 0.1
// --- Desc: This module is supposed to get controled over http requests (outside SL)
// -----------------------------------------------------------------------------------------------

// -----------------------------------------------------------------------------------------------
// --- Changelog:
// ---        Version: 0.1
// ---                    + Initial version
// -----------------------------------------------------------------------------------------------


// -----------------------------------------------------------------------------------------------
// --- General settings and storage --------------------------------------------------------------
// -----------------------------------------------------------------------------------------------

string owner_password = "";

integer callback;

// -----------------------------------------------------------------------------------------------
// --- General functions and procedures ----------------------------------------------------------
// -----------------------------------------------------------------------------------------------


// --- initializes the web module
setup()
{
    owner_password = create_pwd();
    llRequestURL();
}

// --- creates a password based on owner key
string create_pwd()
{
    string owner = (string)llGetOwner();
    owner = llMD5String(owner,0);
    return owner;
}

// --- returns text to the requesting client
answer(key server,string returnme)
{
    if(llStringLength(returnme)!=0)
    {
        llHTTPResponse(server,200,returnme);
    }
}

string all_avatars()
{
    list uuid = llGetAgentList(AGENT_LIST_REGION, []);
    string mystring = "001";
    integer i = 0;
    integer count = llGetListLength(uuid);
    while(i<count-1)
    {
        mystring += llList2String(uuid,i)+"|"+llKey2Name(llList2Key(uuid,i))+",";
        i++;
    }
    return mystring;
}


// -----------------------------------------------------------------------------------------------
// --- Main part starts here ---------------------------------------------------------------------
// -----------------------------------------------------------------------------------------------

default
{
    on_rez(integer start_param)
    {
        if(start_param != 0)
        {
            setup();
            callback = start_param;
        }
    }
    
    touch_start(integer total_number)
    {
        if(llDetectedKey(0)==llGetOwner())
        {
            setup();
        }
    }

    http_request(key id, string method, string body)
    {
        if (method == URL_REQUEST_GRANTED)
        {
            llOwnerSay("URL: " + body+"/"+owner_password+"?001=whatever");
            llRegionSay(callback,body+"/"+owner_password);
        }
        else if (method == URL_REQUEST_DENIED)
        {
            llSay(0, "Something went wrong, no url. " + body);
        }
        else if (method == "GET")
        {
        // answer(id,"message");
            string pwd = llGetHTTPHeader(id,"x-path-info");
            string query = llGetHTTPHeader(id,"x-query-string");
            if (pwd = owner_password)
            {
                string cmd = llGetSubString(query,0,2);
                string param = llGetSubString(query,4,-1);
                if(llGetSubString(cmd,0,2)=="001")
                {
                    if(param == "scan")
                    {
                        answer(id,all_avatars());
                    }
                }
            }
        }
        else
        {
            llHTTPResponse(id,405,"Unsupported Method");
        }
    }
}