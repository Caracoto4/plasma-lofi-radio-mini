import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

import "components" as Components

PlasmoidItem {
    id: root

    preferredRepresentation: fullRepresentation

    readonly property Components.StreamPlayer engine: Components.StreamPlayer

    readonly property bool inPanel: plasmoid.location === PlasmaCore.Types.TopEdge
                                    || plasmoid.location === PlasmaCore.Types.LeftEdge
                                    || plasmoid.location === PlasmaCore.Types.RightEdge
                                    || plasmoid.location === PlasmaCore.Types.BottomEdge

    Plasmoid.status: engine.playing ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.PassiveStatus

    fullRepresentation: Item {
        implicitWidth: 260
        implicitHeight: 180
        Layout.preferredWidth: implicitWidth
        Layout.preferredHeight: implicitHeight
        Layout.minimumWidth: 220
        Layout.minimumHeight: 160

        Components.PlayerCard {
            anchors.fill: parent
            engine: root.engine
            drawBackground: false
        }
    }

    compactRepresentation: Item {
        id: compactRoot

        implicitWidth: Kirigami.Units.iconSizes.smallMedium
        implicitHeight: Kirigami.Units.iconSizes.smallMedium

        Layout.preferredWidth: implicitWidth
        Layout.preferredHeight: implicitHeight

        Kirigami.Icon {
            id: compactIcon
            anchors.centerIn: parent
            width: Math.min(parent.width, parent.height)
            height: width
            source: root.engine.playing ? "media-playback-pause" : "media-playback-start"

            opacity: mouseArea.containsMouse ? 0.8 : 1.0
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expanded = !root.expanded
        }
    }
}
