import QtQuick 2.0
import Base 1.0
import Dialogs 1.0
import Models 1.0

BaseScreen
{
    defaultFocusItem: edit

    Component.onCompleted:
    {
        showTitle(true, "Rich Text Test");
        showTime(true);
        showTicker(true);
        muteAudio(true);

        ticker.scenePreload();
        ticker.sceneStart();
    }

    BaseMultilineEdit
    {
        id: edit
        x: 100; y: 100; width: 700

        onTextChanged: richText.text = text
    }

    RichText
    {
        id: richText
        x: 100; y: 300; width: 400; height: 200
    }

    Ticker
    {
        id: ticker
        x : 10; y: 620; width: parent.width - 20; height: 40
        showTitle: true
        showDescription: true

        feedType: ["rss",
                   "rss",
                   "rss"
                  ]
        urls: ["https://weather-broker-cdn.api.bbci.co.uk/en/observation/rss/2644547",
               "https://weather-broker-cdn.api.bbci.co.uk/en/forecast/rss/3day/2644547",
               "http://feeds.bbci.co.uk/news/uk/rss.xml"
              ]
        namespaces: ["http://www.w3.org/2005/Atom",
                     "http://www.w3.org/2005/Atom",
                     "http://www.w3.org/2005/Atom"
                    ]
    }
}
