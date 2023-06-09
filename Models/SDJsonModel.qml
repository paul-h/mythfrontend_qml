import QtQuick 2.0
import QtQuick.XmlListModel 2.0

import Process 1.0
import mythqml.net 1.0

Item
{
    id: root

    signal loaded();

    property string username: settings.sdUserName;
    property string password: settings.sdPassword;
    property string token: ""
    property var lineups

    property string apiBaseURL: "https://json.schedulesdirect.org/"
    property string apiVersion: "20141201"
    //property string apiVersion: "20191022"

    Component.onCompleted:
    {
        getToken();
    }

    function apiRequest(method, url, params, needsToken, callback)
    {
        var http = new XMLHttpRequest();

        http.open(method, url, true);

        if (needsToken)
            http.setRequestHeader("token", root.token);

        if (url === apiBaseURL + apiVersion + "/programs")
            http.setRequestHeader("Accept-Encoding", "deflate,gzip");

        http.onerror = function ()
        {
          log.error(Verbose.MODEL,"SDJsonModel: An error occurred during the transaction - '" + http.statusText + "'");
        };

        http.onreadystatechange = function()
        {
            if (http.readyState == 4)
            {
                if (http.status == 200)
                {
                    var json = JSON.parse(http.responseText)
                    if (typeof(callback === 'function'))
                        callback(json)
                    else
                        log.info(Verbose.MODEL, "SDJsonModel: reply - \n" + JSON.stringify(json, null, 4));
                }
                else
                {
                    log.error(Verbose.MODEL, "apiRequest ERROR: got status '" + http.statusText + "' - " + http.responseText)
                    log.error(Verbose.MODEL, "Headers '" + http.getAllResponseHeaders())
                }
            }
        }

        http.send(params);
    }

    function getToken(username, password)
    {
        var http = new XMLHttpRequest();
        var url = apiBaseURL + apiVersion + "/token";
        var params = '{"username":"' + root.username + '","password":"' + sha1(root.password) + '"}';

        http.open("POST", url, true);

        http.onerror = function ()
        {
            log.error(Verbose.MODEL,"SDJsonModel: An error occurred during the transaction '" + http.statusText + "'");
        };

        http.onreadystatechange = function()
        {
            if (http.readyState == 4)
            {
                if (http.status == 200)
                {
                    var json = JSON.parse(http.responseText)
                    if (json.code === 0)
                    {
                        log.debug(Verbose.MODEL, "SDJsonModel getToken: token is: " + json.token)
                        root.token = json.token

                        //getStatus(debugStatusCallback);
                        //getCountries(debugCountriesCallback);
                        //getTransmitters(("GBR"), debugTransmittersCallback);
                        //getHeadends("GBR", "BL66SL", debugHeadendsCallback);
                        //getLineupPreview("GBR-1008053-DEFAULT", debugLineupPreviewCallback);
                        //getLineups(debugCallback);
                        //getLineup("GBR-1000041-DEFAULT", debugCallback);
                        getPrograms('["EP012811800381"]', debugCallback)
                        //getGenericDescription('["EP016736560025"]', debugCallback)
                        //getArtwork('["EP01281180"]', debugCallback)
                        //getCastImages(58321, debugCallback);


                        var stations = ["24325", "68051"];
                        var dates = ["2023-06-01", "2023-06-02"];
                        //getLastModified(stations, dates, debugCallback)
                        //getSchedule(stations, dates, debugCallback);
                    }
                    else
                    {
                        log.error(Verbose.MODEL, "SDJsonModel.getToken: ERROR: got status code '" + json.code + "' - " + json.message)
                    }
                }
                else
                {
                    log.error(Verbose.MODEL, "SDJsonModel.getToken: ERROR: got status '" + http.statusText + "' - " + http.responseText)
                    log.error(Verbose.MODEL, "Headers '" + http.getAllResponseHeaders())
                }
            }
        }

        http.send(params);
    }

    function debugCallback(json)
    {
        log.debug(Verbose.MODEL,"SDJsonModel: reply - \n" + JSON.stringify(json, null, 4));
    }

    function getStatus(callback)
    {
        apiRequest("GET", apiBaseURL + apiVersion + "/status", "", true, callback);
    }

    function debugStatusCallback(json)
    {
        if (json.code === 0)
        {
            log.debug(Verbose.MODEL,"SDJsonModel: getStatus - account.maxLineups: " + json.account.maxLineups)

            for (var x = 0; x < json.lineups.length; x++)
            {
                log.debug(Verbose.MODEL,"SDJsonModel: getStatus - " + json.lineups[x].lineup);
            }
        }
    }

    function getCountries(callback)
    {
        apiRequest("GET", apiBaseURL + apiVersion + "/available/countries", "", false, callback);
    }

    function debugCountriesCallback(json)
    {
        for (const area in json)
        {
            log.debug(Verbose.MODEL,"SDJsonModel: getCountries - ****" + area + "****");
            for (var y in json[area])
            {
                log.debug(Verbose.MODEL,"SDJsonModel: getCountries - " + json[area][y].fullName);
            }
        }
    }

    function getTransmitters(country, callback)
    {
        apiRequest("GET", apiBaseURL + apiVersion + "/transmitters/" + country, "", false, callback);
    }

    function debugTransmittersCallback(json)
    {
        for (const trans in json)
        {
            log.debug(Verbose.MODEL,"SDJsonModel: getTransmitters - " + trans + ":" + json[trans]);
        }
    }

    function getHeadends(country, postcode, callback)
    {
        apiRequest("GET", apiBaseURL + apiVersion + "/headends?country=" + country + "&postalcode=" + postcode, "", true, callback);
    }

    function debugHeadendsCallback(json)
    {
        for (var x = 0; x < json.length; x++)
        {
            log.debug(Verbose.MODEL,"SDJsonModel: getTransmitters - " + json[x].headend + " : " + json[x].transport + " : " + json[x].location);
            for (var y = 0; y < json[x].lineups.length; y++)
            {
                log.debug(Verbose.MODEL,"SDJsonModel: getTransmitters -     " + json[x].lineups[y].name + " : " + json[x].lineups[y].lineup);
            }
        }
    }

    function getLineupPreview(lineup, callback)
    {
        apiRequest("GET", apiBaseURL + apiVersion + "/lineups/preview/" + lineup, "", true, callback);
    }

    function debugLineupPreviewCallback(json)
    {
        log.debug(Verbose.MODEL,"SDJsonModel: getLineupPreview - " + JSON.stringify(json, null, 4));
    }

    function getLineups(callback)
    {
        apiRequest("GET", apiBaseURL + apiVersion + "/lineups", "", true, callback);
    }

    function getLineup(lineup, callback)
    {
        apiRequest("GET", apiBaseURL + apiVersion + "/lineups/" + lineup, "", true, callback);
    }

    function getPrograms(progIDs, callback)
    {
        var json = JSON.stringify(progIDs);
        apiRequest("POST", apiBaseURL + apiVersion + "/programs", json, true, callback)
    }

    function getGenericDescription(progIDs, callback)
    {
        apiRequest("POST", apiBaseURL + apiVersion + "/metadata/description", progIDs, true, callback);
    }

    function getArtwork(progIDs, callback)
    {
        apiRequest("POST", apiBaseURL + apiVersion + "/metadata/programs", progIDs, true, callback);
    }

    function getCastImages(nameID, callback)
    {
        apiRequest("GET", apiBaseURL + apiVersion + "/metadata/celebrity/" + nameID, "", true, callback);
    }

    function getLastModified(stationIDs, dates, callback)
    {
        var json = {};
        var datesArray = [];
        var stationArray = [];

        for (var x = 0; x < dates.length; x++)
        {
            datesArray.push(dates[x]);
        }

        for (var y = 0; y < stationIDs.length; y++)
        {
            if (dates.length)
                stationArray.push({ "stationID" : stationIDs[y], "date" : datesArray});
            else
                stationArray.push({ "stationID" : stationIDs[y]});
        }

        json = stationArray;
        log.debug(Verbose.MODEL,"SDJsonModel: getLastModified request - " +JSON.stringify(json));

        apiRequest("POST", apiBaseURL + apiVersion + "/schedules/md5", JSON.stringify(json), true, callback);
    }

    function getSchedule(stationIDs, dates, callback)
    {
        var json = {};
        var datesArray = [];
        var stationArray = [];

        for (var x = 0; x < dates.length; x++)
        {
            datesArray.push(dates[x]);
        }

        for (var y = 0; y < stationIDs.length; y++)
        {
            if (dates.length)
                stationArray.push({ "stationID" : stationIDs[y], "date" : datesArray});
            else
                stationArray.push({ "stationID" : stationIDs[y]});
        }

        json = stationArray;

        apiRequest("POST", apiBaseURL + apiVersion + "/schedules", JSON.stringify(json), true, callback)
    }

    /**
    * Secure Hash Algorithm (SHA1)
    * http://www.webtoolkit.info/
    **/
    function sha1(msg)
    {
        function rotate_left(n,s)
        {
            var t4 = ( n<<s ) | (n>>>(32-s));
            return t4;
        };
        function lsb_hex(val)
        {
            var str='';
            var i;
            var vh;
            var vl;
            for( i=0; i<=6; i+=2 )
            {
                vh = (val>>>(i*4+4))&0x0f;
                vl = (val>>>(i*4))&0x0f;
                str += vh.toString(16) + vl.toString(16);
            }
            return str;
        };
        function cvt_hex(val)
        {
            var str='';
            var i;
            var v;
            for( i=7; i>=0; i-- )
            {
                v = (val>>>(i*4))&0x0f;
                str += v.toString(16);
            }
            return str;
        };
        function utf8Encode(string)
        {
            string = string.replace(/\r\n/g,'\n');
            var utftext = '';
            for (var n = 0; n < string.length; n++)
            {
                var c = string.charCodeAt(n);
                if (c < 128) {
                    utftext += String.fromCharCode(c);
                }
                else if((c > 127) && (c < 2048)) {
                    utftext += String.fromCharCode((c >> 6) | 192);
                    utftext += String.fromCharCode((c & 63) | 128);
                }
                else {
                    utftext += String.fromCharCode((c >> 12) | 224);
                    utftext += String.fromCharCode(((c >> 6) & 63) | 128);
                    utftext += String.fromCharCode((c & 63) | 128);
                }
            }
            return utftext;
        };
        var blockstart;
        var i, j;
        var W = new Array(80);
        var H0 = 0x67452301;
        var H1 = 0xEFCDAB89;
        var H2 = 0x98BADCFE;
        var H3 = 0x10325476;
        var H4 = 0xC3D2E1F0;
        var A, B, C, D, E;
        var temp;
        msg = utf8Encode(msg);
        var msg_len = msg.length;
        var word_array = new Array();
        for( i=0; i<msg_len-3; i+=4 )
        {
            j = msg.charCodeAt(i)<<24 | msg.charCodeAt(i+1)<<16 |
                    msg.charCodeAt(i+2)<<8 | msg.charCodeAt(i+3);
            word_array.push( j );
        }
        switch( msg_len % 4 )
        {
        case 0:
            i = 0x080000000;
            break;
        case 1:
            i = msg.charCodeAt(msg_len-1)<<24 | 0x0800000;
            break;
        case 2:
            i = msg.charCodeAt(msg_len-2)<<24 | msg.charCodeAt(msg_len-1)<<16 | 0x08000;
            break;
        case 3:
            i = msg.charCodeAt(msg_len-3)<<24 | msg.charCodeAt(msg_len-2)<<16 | msg.charCodeAt(msg_len-1)<<8 | 0x80;
            break;
        }
        word_array.push( i );
        while( (word_array.length % 16) != 14 ) word_array.push( 0 );
        word_array.push( msg_len>>>29 );
        word_array.push( (msg_len<<3)&0x0ffffffff );
        for ( blockstart=0; blockstart<word_array.length; blockstart+=16 )
        {
            for( i=0; i<16; i++ ) W[i] = word_array[blockstart+i];
            for( i=16; i<=79; i++ ) W[i] = rotate_left(W[i-3] ^ W[i-8] ^ W[i-14] ^ W[i-16], 1);
            A = H0;
            B = H1;
            C = H2;
            D = H3;
            E = H4;
            for( i= 0; i<=19; i++ )
            {
                temp = (rotate_left(A,5) + ((B&C) | (~B&D)) + E + W[i] + 0x5A827999) & 0x0ffffffff;
                E = D;
                D = C;
                C = rotate_left(B,30);
                B = A;
                A = temp;
            }
            for( i=20; i<=39; i++ ) {
                temp = (rotate_left(A,5) + (B ^ C ^ D) + E + W[i] + 0x6ED9EBA1) & 0x0ffffffff;
                E = D;
                D = C;
                C = rotate_left(B,30);
                B = A;
                A = temp;
            }
            for( i=40; i<=59; i++ ) {
                temp = (rotate_left(A,5) + ((B&C) | (B&D) | (C&D)) + E + W[i] + 0x8F1BBCDC) & 0x0ffffffff;
                E = D;
                D = C;
                C = rotate_left(B,30);
                B = A;
                A = temp;
            }
            for( i=60; i<=79; i++ ) {
                temp = (rotate_left(A,5) + (B ^ C ^ D) + E + W[i] + 0xCA62C1D6) & 0x0ffffffff;
                E = D;
                D = C;
                C = rotate_left(B,30);
                B = A;
                A = temp;
            }
            H0 = (H0 + A) & 0x0ffffffff;
            H1 = (H1 + B) & 0x0ffffffff;
            H2 = (H2 + C) & 0x0ffffffff;
            H3 = (H3 + D) & 0x0ffffffff;
            H4 = (H4 + E) & 0x0ffffffff;
        }
        var temp = cvt_hex(H0) + cvt_hex(H1) + cvt_hex(H2) + cvt_hex(H3) + cvt_hex(H4);

        return temp.toLowerCase();
    }

}
