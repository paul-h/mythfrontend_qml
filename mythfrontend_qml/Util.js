.pragma library


/* Convert strings like "one-two-three" to "OneTwoThree" */
function convertToCamelCase( name )
{
    var chunksArray = name.split('-')
    var camelName = ''

    for (var i=0; i<chunksArray.length; i++)
    {
        camelName = camelName + chunksArray[i].charAt(0).toUpperCase() + chunksArray[i].slice(1);
    }

    return camelName
}

function fromUTC(object)
{
    var de = new Date(object).toUTCString()
    var mytime = new Date(de).toLocaleString()

    return mytime.toString()
}

function toUTC(object)
{
    var year = Qt.formatDateTime(object,"yyyy")
    var month = Qt.formatDateTime(object,"MM")
    var day = Qt.formatDateTime(object,"dd")
    var hour = Qt.formatDateTime(object,"hh")
    var minute = Qt.formatDateTime(object,"mm")
    var de = new Date(object).toLocaleString()

    return de
}

function milliSecondsToString(milliseconds)
{
    milliseconds = milliseconds > 0 ? milliseconds : 0
    var timeInSeconds = Math.floor(milliseconds / 1000)
    var hours = Math.floor(timeInSeconds / (60 * 60))
    var hourString = hours < 10 ? "0" + hours : hours
    timeInSeconds %= 3600;
    var minutes = Math.floor(timeInSeconds / 60)
    var minutesString = minutes < 10 ? "0" + minutes : minutes
    var seconds = Math.floor(timeInSeconds % 60)
    var secondsString = seconds < 10 ? "0" + seconds : seconds

    if (hours > 0)
        return hourString + ":" + minutesString + ":" + secondsString

    return minutesString + ":" + secondsString
}

function milliSecondsToMinutes(milliseconds)
{
    milliseconds = milliseconds > 0 ? milliseconds : 0
    var timeInSeconds = Math.floor(milliseconds / 1000)
    var minutes = Math.floor(timeInSeconds / 60)
    var minutesString = minutes < 10 ? "0" + minutes : minutes
    var seconds = Math.floor(timeInSeconds % 60)
    var secondsString = seconds < 10 ? "0" + seconds : seconds

    return minutesString
}


function timeOff(timeto)
{
    var q = Date(timeto)
    var w = q.substring(q.indexOf("-"))
    var e = w.substring(0,w.indexOf(" "))
    return e
}

function addSeconds(date, seconds)
{
    return new Date(date.getTime() + (seconds * 1000));
}

function addDays(date, days)
{
  var result = new Date(date);
  result.setDate(result.getDate() + days);
  return result;
}

function format_time(time_in_milliseconds, formatting)
{
    /* We are using Qt.formatTime to format the time_in_milliseconds because
       this is more practical that doing the formatting manually (JavaScript
       does not provide any string formatting function natively).

       WARNING: this will break for media longer than 24 hours.
    */

    /* Hack JavaScript's Date to ignore timeone offset */
    var zero = new Date(0)
    var offset = zero.getTimezoneOffset()*60*1000
    var date = new Date(time_in_milliseconds+offset)

    return Qt.formatTime(date, formatting)
}

function formatFileSize(bytes, si)
{
    var thresh = si ? 1000 : 1024;
    if (Math.abs(bytes) < thresh)
    {
        return bytes + ' B';
    }
    var units = si
        ? ['kB','MB','GB','TB','PB','EB','ZB','YB']
        : ['KiB','MiB','GiB','TiB','PiB','EiB','ZiB','YiB'];
    var u = -1;
    do
    {
        bytes /= thresh;
        ++u;
    } while(Math.abs(bytes) >= thresh && u < units.length - 1);
    return bytes.toFixed(1)+' '+units[u];
}

function fromIso8601(date)
{
    var timestamp, struct, minutesOffset = 0;
    var numericKeys = [ 1, 4, 5, 6, 7, 10, 11 ];

    // ES5 §15.9.4.2 states that the string should attempt to be parsed as a Date Time String Format string
    // before falling back to any implementation-specific date parsing, so that’s what we do, even if native
    // implementations could be faster
    //              1 YYYY                2 MM       3 DD           4 HH    5 mm       6 ss        7 msec        8 Z 9 ±    10 tzHH    11 tzmm
    if ((struct = /^(\d{4}|[+\-]\d{6})(?:-(\d{2})(?:-(\d{2}))?)?(?:T(\d{2}):(\d{2})(?::(\d{2})(?:\.(\d{3}))?)?(?:(Z)|([+\-])(\d{2})(?::(\d{2}))?)?)?$/.exec(date))) 
    {
        // avoid NaN timestamps caused by “undefined” values being passed to Date.UTC
        for (var i = 0, k; (k = numericKeys[i]); ++i)
        {
            struct[k] = +struct[k] || 0;
        }

        // allow undefined days and months
        struct[2] = (+struct[2] || 1) - 1;
        struct[3] = +struct[3] || 1;

        if (struct[8] !== 'Z' && struct[9] !== undefined)
        {
            minutesOffset = struct[10] * 60 + struct[11];

            if (struct[9] === '+')
            {
                minutesOffset = 0 - minutesOffset;
            }
        }

        timestamp = Date(struct[1], struct[2], struct[3], struct[4], struct[5] + minutesOffset, struct[6], struct[7]).toUTCString();
        return new Date(timestamp);
    }
    else
        return null;
}

function updateTime(nw)
{
    var e  = Qt.formatDateTime(nw,"ddd MMMM d yyyy hh:mm:ss");
    var td = new Date(e);
    return "\t"+ td
}

function isSameDay(date1, date2)
{
    return (date1.getFullYear() === date2.getFullYear() &&
            date1.getMonth === date2.getMonth &&
            date1.getDay() === date2.getDay())
}

function pad(text, len, paddingChar)
{
    var padding = ""
    for (var i = text.length; i < len; i++) padding += paddingChar
    return padding + text
}

function updateChannel(chanID, chanName, callsign, chanNo, XMLTVID)
{
    var http = new XMLHttpRequest();
    var url = "http://localhost:8080";
    var params = "num=22&num2=333";
    http.open("POST", url, true);

    // Send the proper header information along with the request
    http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    http.setRequestHeader("Content-length", params.length);
    http.setRequestHeader("Connection", "close");

    http.onreadystatechange = function() { // Call a function when the state changes.
        if (http.readyState == 4) {
            if (http.status == 200) {
                console.log("ok")
            } else {
                console.log("error: " + http.status)
            }
        }
    }
    http.send(params);
}

function reportBroken(type, version, systemid, name, feedurl)
{
    var http = new XMLHttpRequest();
    var url = "https://mythqml.net/report-broken.php";
    var params = "t=" + type + "&v=" + version + "&s=" + systemid + "&n=" + encodeURIComponent(name) + "&u=" + encodeURIComponent(feedurl);

    http.open("POST", url, true);

    // Send the proper header information along with the request
    http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    http.setRequestHeader("Content-length", params.length);
    http.setRequestHeader("Connection", "close");

    http.onreadystatechange = function()
    {
        if (http.readyState == 4)
        {
            if (http.status == 200)
            {
                if (http.responseText.length > 0)
                    console.log("reportBroken : got ok but response was: " + http.responseText)
            }
            else
            {
                console.log("reportBroken error: " + http.status + "\n" + http.responseText)
            }
        }
    }
    http.send(params);
}

function randomIntFromRange(min, max) // min and max included
{
    return Math.floor(Math.random()*(max-min+1)+min);
}

// compare v1 version string to v2 version string like 1.2.3.alpha and 1.2.4.alpha
// return 0 for equal, -1 for less than, 1 for greater than or false for error
function compareVersion(v1, v2)
{
    if (typeof v1 !== 'string') return false;
    if (typeof v2 !== 'string') return false;

    v1 = v1.split('.');
    v2 = v2.split('.');

    if (v1.length < 3)
    {
        console.log("compareVersion got bad version: " + v1);
        return false
    }

    if (v2.length < 3)
    {
        console.log("compareVersion got bad version: " + v2);
        return false
    }

    for (var i = 0; i < 3; i++)
    {
        v1[i] = parseInt(v1[i], 10);
        v2[i] = parseInt(v2[i], 10);
        if (v1[i] > v2[i]) return 1;
        if (v1[i] < v2[i]) return -1;
    }

    return 0;
}

function getPath(filePath)
{
    return filePath.substring(0, filePath.lastIndexOf("/"));
}

function basename(path)
{
    return (path.slice(path.lastIndexOf("/")+1))
}

function removeExtension(path)
{
    if (path && path.length > 1)
        return path.replace(/\.[^/.]+$/, "")

    return ""
}

function monthToString(idx)
{
    var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

    if (idx >= 0 && idx < months.length)
        return months[idx];

    return "Invalid";
}

// extract a named setting from a string list.
// format of each setting must be like 'SettingName: Value'
function getSetting(source, setting)
{
    var lines = source.split("\n");

    for (var x = 0; x < lines.length; x++)
    {
        var line = lines[x];
        if (line.startsWith(setting))
        {
            var result = line.replace(setting + ": ", "");
            return result;
        }
    }

    return undefined;
}
