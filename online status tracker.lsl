// -----------------------------------------------------------------------
// --- Stalkers best friend ----------------------------------------------
// -----------------------------------------------------------------------

// -----------------------------------------------------------------------
// --- Type: module
// --- Func: Keeps track if someone is on or offline
// --- Vers: 0.2
// --- Written by Peter Bartels
// -----------------------------------------------------------------------

// -----------------------------------------------------------------------
// --- global definitions ------------------------------------------------
// -----------------------------------------------------------------------

integer is_on = FALSE;
key target_key = NULL_KEY;
string target_name = "";
string start = "";

key handle_on;
key handle_name;

float delay = 60.0; // delay in seconds

// -----------------------------------------------------------------------
// --- global functions --------------------------------------------------
// -----------------------------------------------------------------------

check_status(string s)
{
    if(s == "1") // online
    {
        if(is_on == TRUE)
        {
			// nothing
        }
        else
            if(is_on == FALSE)
        {
            is_on = TRUE;
			start = elapsed("");
            llInstantMessage(llGetOwner(),target_name+" is online.");
        }
    }
    else
    if(s == "0") // offline
    {
        if(is_on == TRUE)
        {
            is_on = FALSE;
			llInstantMessage(llGetOwner(),target_name+" is offline. Online duration: "+elapsed(start));
			start = "";
        }
        else
        if(is_on == FALSE)
        {
            // nothing
        }
    }
}

string elapsed(string sTime)
{
    if (sTime == "" )
    {
        sTime = llGetTimestamp();                          
    }
    else
    {
        string sH;
        string sM;
        string sS;
        
        string sTimeEnd = llGetTimestamp();
        
        integer iHour = (integer)llGetSubString( sTimeEnd, 11, 12 );
        integer iMin =  (integer)llGetSubString( sTimeEnd, 14, 15 );
        float fSec =      (float)llGetSubString( sTimeEnd, 17, 22 );
        
        integer iHour_start =   (integer)llGetSubString( sTime, 11, 12 );
        integer iMin_start =    (integer)llGetSubString( sTime, 14, 15 );
        float fSec_start =        (float)llGetSubString( sTime, 17, 22 );
        
        if (iHour < iHour_start) 
        {
            iHour += 24;
        }
        if (iMin < iMin_start)
        {
            iMin += 60;
        }
        if (fSec < fSec_start)
        {
            fSec += 60.0;
        }

        iHour = iHour - iHour_start;
        iMin = iMin - iMin_start;
        fSec = fSec - fSec_start;

        if (iHour < 10)
        {
            sH = "0";
        }
        if (iMin < 10)
        {
            sM = "0";
        }
        if (fSec < 10.0)
        {
            sS = "0";
        }
                                                    
        sTime = llGetSubString(sM + (string)iHour + ":" + sM + (string)iMin + ":" + sS + (string)fSec,0,7);;     
    }
    
    return sTime;
}

// -----------------------------------------------------------------------
// --- main part ---------------------------------------------------------
// -----------------------------------------------------------------------

default
{
    on_rez(integer start_param)
    {
        llResetScript();
    }
    
    link_message(integer sender_number, integer number, string message, key id)
    {
        if((message == "track") && (id != NULL_KEY))
        {
            llOwnerSay("[-] Requesting name.");
            target_key = id;
            handle_name = llRequestAgentData(target_key,DATA_NAME);
        }
        else
        if(message == "stop")
        {
            llSetTimerEvent(0.0);
        }
    }

    timer()
    {
        handle_on = llRequestAgentData(target_key,DATA_ONLINE);
    }

    dataserver(key requested, string data)
    {
        if(requested == handle_name)
        {
            target_name = data;
            llOwnerSay("[+] Name retrieved: "+target_name);
            llSetTimerEvent(delay);
        }
        else
        if(requested == handle_on)
        {
            if(data == "1" || data == "0")
            {
                //llOwnerSay("[-] Checking online status.");
                check_status(data);
            }
        }
    }
}