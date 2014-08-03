
.import "../lib/htmlparser2.js" as HtmlParser

var state = {
    'key1': null,
}

function init() {
    console.log("context init");
    state['key1'] = 42;

    console.log('key1=' + state['key1']);
}

function refresh() {
    //
    var http = new XMLHttpRequest()
    http.open("GET", "http://m.nextinpact.com/", true)
    // not possible - http.setRequestHeader("User-Agent", "Jolla/NextINpact 0.1")

    http.onreadystatechange = function() {
        if (http.readyState === XMLHttpRequest.DONE && http.status === 200) {
           //console.log(http.responseText)

            // 1. re.exec()
            //    FAIL: lastIndex() do not work
            /*
            var x = new RegExp("<h2[^>]+class=\"cv\"[^>]*>(.*?)</h2>")
            var res = x.exec(http.responseText);
            console.log("! "+res[1]+","+x.lastIndex)

            while ((res = x.exec(http.responseText)) !== null) {
                console.log("> " + res[1] + "," + x.lastIndex)
            }
            */

            // 2. XML enumeration
            //    FAIL: responseXML not initialized
            /*
            console.log('xml='+http.responseXML)

            var root = http.responseXML.documentElement
            for(var i = 0; i < root.childNodes.length; i++) {
                console.log('node=' + root.childNodes[i].nodeName)
            }
            */

            // 3. create DOM
            //    FAIL: now document element
            /*
            var dom = HtmlParser.HTMLtoDOM(http.responseText)
            console.log('dom=' + dom)
            */

            // 4. convert from HTML to XML, then query elements
            //    FAIL: not able to interpred XML string
            /*
            var xml = HtmlParser.HTMLtoXML(http.responseText)
            console.log('xml=' + xml)

            var h2s = xml.getElementByTagName('h2')
            console.log('h2=' + h2s)
            */

            // 5. parse HTML and traverse HTML tree
            //    OK
            var article = null;
            HtmlParser.HTMLParser(http.responseText, {
                start: function(tag, attrs, unary) {
                    //console.log("start> " + tag + "," + unary)
                    if (tag == 'article') {
                        console.log('start article')
                        article = {'h1': false}
                    }
                    else if (tag == 'h1' && article !== null) {
                        article['h1'] = true
                    }
                    else if(tag =='a' && article !== null && article['h1']) {
                        console.log("match link " + attrs['href'].value)
                        article['link'] = attrs['href'].value
                    }


                },

                end: function(tag) {
                    if(tag == 'h1' && article !== null) {
                        article['h1'] = false
                    }

                    if(tag == 'article' && article !== null) {
                        console.log("end article:" + article['link'])
                    }
                }
            })
        }
    }

    http.send()
}

