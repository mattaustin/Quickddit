import QtQuick 1.1
import com.nokia.meego 1.0
import Quickddit 1.0

Sheet {
    id: subredditDialog
    acceptButtonText: "Go"
    rejectButtonText: "Cancel"

    property SubredditModel subredditModel

    property alias text: subredditTextField.text
    property bool browseSubreddits: false

    content: Item {
        anchors.fill: parent

        TextField {
            id: subredditTextField
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: constant.paddingMedium }
            placeholderText: "Go to specific subreddit..."
            platformSipAttributes: SipAttributes {
                actionKeyLabel: "Go"
            }
            onAccepted: subredditDialog.accept();
        }

        Column {
            id: mainOptionColumn
            anchors {
                left: parent.left; right: parent.right
                top: subredditTextField.bottom; topMargin: constant.paddingMedium
            }
            height: childrenRect.height

            Repeater {
                id: mainOptionRepeater
                anchors { left: parent.left; right: parent.right }
                model: ["Front", "All", "Browse for Subreddits..."]

                ListItem {
                    height: subredditText.paintedHeight + 2 * constant.paddingXLarge
                    width: mainOptionRepeater.width

                    Text {
                        id: subredditText
                        anchors {
                            left: parent.left; right: parent.right; margins: constant.paddingLarge
                            verticalCenter: parent.verticalCenter
                        }
                        font.pixelSize: constant.fontSizeMedium
                        color: constant.colorLight
                        text: modelData
                    }

                    onClicked: {
                        switch (index) {
                        case 0: subredditDialog.text = ""; break;
                        case 1: subredditDialog.text = "all"; break;
                        case 2: browseSubreddits = true; break;
                        }
                        subredditDialog.accept();
                    }
                }
            }
        }

        Item {
            id: subscribedSubredditHeader
            anchors {
                top: mainOptionColumn.bottom; left: parent.left; right: parent.right
            }
            height: constant.headerHeight
            visible: subredditModel ? true : false

            Text {
                id: headerTitleText
                anchors {
                    left: parent.left; right: refreshWrapper.left; margins: constant.paddingMedium
                    verticalCenter: parent.verticalCenter
                }
                font.bold: true
                font.pixelSize: constant.fontSizeLarge
                color: constant.colorLight
                elide: Text.ElideRight
                text: "Subscribed Subreddit"
            }

            Loader {
                id: refreshWrapper
                anchors {
                    right: parent.right; margins: constant.paddingMedium
                    verticalCenter: parent.verticalCenter
                }
                sourceComponent: visible ? (subredditModel.busy ? busyComponent : refreshComponent)
                                         : undefined

                Component {
                    id: refreshComponent
                    Image {
                        id: refreshImage
                        source: "image://theme/icon-m-toolbar-refresh"
                                + (appSettings.whiteTheme ? "" : "-selected")
                    }
                }

                Component {
                    id: busyComponent
                    BusyIndicator { running: true }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: visible && !subredditModel.busy
                    onClicked: subredditModel.refresh(false);
                }
            }

            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 1
                color: constant.colorMid
            }
        }

        ListView {
            id: subscribedSubredditListView
            anchors {
                top: subscribedSubredditHeader.bottom; bottom: parent.bottom
                left: parent.left; right: parent.right
            }
            visible: subredditModel ? true : false
            clip: true
            model: visible ? subredditModel : 0
            delegate: ListItem {
                height: subscribedSubredditText.paintedHeight + 2 * constant.paddingXLarge

                Text {
                    id: subscribedSubredditText
                    anchors {
                        left: parent.left; right: parent.right; margins: constant.paddingLarge
                        verticalCenter: parent.verticalCenter
                    }
                    font.pixelSize: constant.fontSizeMedium
                    color: constant.colorLight
                    text: model.url
                }

                onClicked: {
                    subredditDialog.text = model.displayName;
                    subredditDialog.accept();
                }
            }
        }
    }
}
