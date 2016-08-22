string notecard_name = "configuration";  // name of notecard goes here
 
// internals
integer DEBUG = FALSE;
integer line;
key queryhandle;                   // to separate Dataserver requests
key notecarduuid;
 
init()
{
    queryhandle = llGetNotecardLine(notecard_name, line = 0);// request line
    notecarduuid = llGetInventoryKey(notecard_name);
}
 
// Config data loaded from notecard, with some sane defaults
integer channel = 1000;
string email_address = "support@secondlife.com";
default
{
    changed(integer change)         
    {
        // We want to reload channel notecard if it changed
        if (change & CHANGED_INVENTORY)
            if(notecarduuid != llGetInventoryKey(notecard_name))
                init();
    }
 
    state_entry()
    {
        init();
    }
 
    dataserver(key query_id, string data)
    {
        if (query_id == queryhandle)
        {
            if (data != EOF)
            {   // not at the end of the notecard
                // yay!  Parsing time
 
                // pesky whitespace
                data = llStringTrim(data, STRING_TRIM_HEAD);
 
                // is it a comment?
                if (llGetSubString (data, 0, 0) != "#")
                {
                    integer s = llSubStringIndex(data, "=");
                    if(~s)//does it have an "=" in it?
                    {
                        string token = llToLower(llStringTrim(llDeleteSubString(data, s, -1), STRING_TRIM));
                        data = llStringTrim(llDeleteSubString(data, 0, s), STRING_TRIM);
 
                        //Insert your token parsers here.
                        if (token == "email_address")
                            email_address = data;
                        else if (token == "channel")
                            channel = (integer)data;
                    }
                }
 
                queryhandle = llGetNotecardLine(notecard_name, ++line);
                if(DEBUG) llOwnerSay("Notecard Data: " + data);
            }
            else
            {
                if(DEBUG) llOwnerSay("Done Reading Notecard");
                state configuration ;
            }
        }
    }
}
 
state configuration
{
 
    state_entry()
    {
        llListen(channel, "", "", "");
        llShout(0, "Channel set to " + (string)channel);
        llShout(0, "Email set to " + (string)email_address);
    }   
}