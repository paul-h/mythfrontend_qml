import QtQuick 2.0

ListModel {
    id: model

    ListElement
    {
        itemTitle: "Christmas (6)"
        attributes:
        [
            ListElement { subItemTitle: "Subitem title 1/1" },
            ListElement { subItemTitle: "Subitem title 2/1" },
            ListElement { subItemTitle: "Subitem title 3/1" },
            ListElement { subItemTitle: "Subitem title 4/1" },
            ListElement { subItemTitle: "Subitem title 5/1" },
            ListElement { subItemTitle: "Subitem title 6/1" }
        ]
    }
    ListElement
    {
        itemTitle: "Classic Rock (2)"
        attributes:
        [
            ListElement { subItemTitle: "Subitem title 1/2" },
            ListElement { subItemTitle: "Subitem title 2/2 long text long text long text long text long text long text long text" }
        ]
    }
    ListElement
    {
        itemTitle: "Pop (3)"
        attributes:
        [
            ListElement { subItemTitle: "Subitem title 1/3" },
            ListElement { subItemTitle: "Subitem title 2/3" },
            ListElement { subItemTitle: "Subitem title 3/3" }
        ]
    }
}

