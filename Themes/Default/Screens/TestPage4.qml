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
}
