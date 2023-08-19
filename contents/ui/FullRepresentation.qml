/*
 * Copyright 2016  Daniel Faust <hessijames@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http: //www.gnu.org/licenses/>.
 */
import QtQuick 2.5
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.private.quicklaunch 1.0


Item {
    property real mediumSpacing: 1.5*units.smallSpacing
    property real itemHeight: Math.max(units.iconSizes.smallMedium, theme.defaultFont.pixelSize)
    property bool showSeparators: plasmoid.configuration.separatorStyle
    property int separatorHeight: showSeparators ? 6 : 10
    property int visibleItemCount: calculateVisibleItemCount()
    property int emptyItemCount: calculateEmptyItemCount()


    function calculateVisibleItemCount() {
        var count = 0;
        var emptyCount = 0;

        for (var i = 0; i < apps.length; ++i) {
            if (appsSource.data[apps[i]]) {
                ++count;
            }
        }
        return count;
    }

     function calculateEmptyItemCount() {
        var count = 0;
        var emptyCount = 0;

        for (var i = 0; i < apps.length; ++i) {
            if (!appsSource.data[apps[i]]) {
                ++count;
            }
        }

        return count; // + (emptyCount * separatorHeight);
    }

    Layout.alignment: Qt.AlignLeft // Align to the left edge of the parent
    Layout.minimumWidth: widgetWidth
    Layout.minimumHeight: ( (itemHeight + 2 * mediumSpacing) * visibleItemCount)+(emptyItemCount*separatorHeight)
    //Layout.minimumHeight: (itemHeight + 2*mediumSpacing) * listView.count

    Layout.maximumWidth: Layout.minimumWidth
    Layout.maximumHeight: Layout.minimumHeight

    Layout.preferredWidth: Layout.minimumWidth
    Layout.preferredHeight: Layout.minimumHeight

    Component.onCompleted: {
        // trigger adding all sources already available
        for (var i in appsSource.sources) {
            appsSource.sourceAdded(appsSource.sources[i]);
        }
        //console.log("separatorHeight " + separatorHeight);
        //console.log("visibleItemCount " + visibleItemCount);
        //console.log("emptyItemCount " + emptyItemCount);
    }

    PlasmaCore.DataSource {
        id: appsSource
        engine: 'apps'

        onSourceAdded: {
            connectSource(source)
        }

        onSourceRemoved: {
            disconnectSource(source);
        }
    }

    Logic {
        id: kRun
    }

    PlasmaExtras.ScrollArea {
        anchors.fill: parent

        ListView {
            id: listView
            anchors.fill: parent
            model: apps
            //clip:true
            highlight: PlasmaComponents.Highlight {}
            highlightMoveDuration: 0
            highlightResizeDuration: 0

            delegate: Item {
                width: parent.width
                height: !appName.trim() ? separatorHeight : itemHeight + 2 * mediumSpacing
                //height: !appName.trim() ? units.dp(2) : itemHeight + 2*mediumSpacing

                property bool isHovered: false
                property string appName: appsSource.data[modelData] ? appsSource.data[modelData].name : "";
                property string appIconName: appsSource.data[modelData] ? appsSource.data[modelData].iconName : "";

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    visible: appName.trim()
                    onEntered: {
                        listView.currentIndex = index
                        isHovered = true
                    }
                    onExited: {
                        isHovered = false
                    }
                    onClicked: {
                        plasmoid.expanded = false
                        kRun.openUrl("file:" + appsSource.data[modelData].entryPath)
                    }

                    Row {
                        x: mediumSpacing
                        Layout.fillHeight: !appName.trim()
                        //height: !appName.trim() ? 1 : itemHeight
                        y: !appName.trim() ? 1 : mediumSpacing
                        width: parent.width - 2*mediumSpacing
                        spacing: !appName.trim() ? 1 : mediumSpacing
                        id: myRow
                        //Layout.fillHeight: true

                        Item { // Hack - since setting the dimensions of PlasmaCore.IconItem won't work

                            height: !appName.trim() ? 1 : units.iconSizes.smallMedium
                            width: height
                            anchors.verticalCenter: parent.verticalCenter
                            Layout.fillHeight: true
                            Layout.margins: 0

                            PlasmaCore.IconItem {
                                anchors.fill: parent
                                source: appIconName
                                active: isHovered
                                visible: appName.trim()
                            }
                        }

                        PlasmaComponents.Label {
                            text: appName
                            width: parent.width - units.iconSizes.smallMedium - mediumSpacing
                            height: parent.height
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                            visible: appName.trim()

                            // Component.onCompleted: {
                            //     console.log("Label padding:", padding);
                            // }


                        }
                    }


                }
                //the actual separator
                Rectangle {
                    height: 1 // You can adjust the separator height as needed
                    width: parent.width
                    Layout.fillHeight: true
                    color: "gray" // You can change the color of the separator
                    border.color: "transparent"
                    z:1
                    visible: !appName.trim() && separatorStyle
                    anchors.verticalCenter: parent.verticalCenter


                        MouseArea {
                        anchors.fill: parent
                        enabled: false // This will disable hovering and interaction for the Rectangle
                        hoverEnabled: false // Disable hover interaction for the MouseArea
                        onClicked: mouse.accepted = true // Consume the click event
                    }
                }

            }//delegate: Item

        } //ListView

    } //ScrollArea

} //ITem
