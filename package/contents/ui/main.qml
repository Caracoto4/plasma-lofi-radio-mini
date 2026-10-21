import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

import "components" as Components

PlasmoidItem {
    id: root

    preferredRepresentation: fullRepresentation

    readonly property Components.StreamPlayer engine: Components.StreamPlayer

    // Восстановление состояния при загрузке
    Component.onCompleted: {
        var savedVol = Plasmoid.configuration.readEntry("volume", -1);
        if (savedVol >= 0) {
            engine.volume = savedVol;
        }
        var wasPlaying = Plasmoid.configuration.readEntry("playing", false);
        if (wasPlaying) {
            engine.play();
        }
    }

    // Сохранение громкости
    Connections {
        target: engine
        function onVolumeChanged() {
            Plasmoid.configuration.writeEntry("volume", engine.volume);
        }
    }

    // Сохранение состояния play/pause + уведомление о смене трека
    Connections {
        target: engine
        function onPlayingChanged() {
            Plasmoid.configuration.writeEntry("playing", engine.playing);
        }
        function onTrackChanged() {
            if (engine.title.length > 0 || engine.artist.length > 0) {
                sendNotification(
                    engine.artist.length > 0 ? engine.artist : "Lofi Radio",
                    engine.title.length > 0 ? engine.title : "Новый трек"
                );
            }
        }
    }

    function sendNotification(title, text) {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status !== 200) {
                    console.log("Notification failed:", xhr.status);
                }
            }
        };
        xhr.open("POST", "http://127.0.0.1:8731/notify", true);
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(JSON.stringify({ title: title, text: text }));
    }

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
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.expanded = !root.expanded;
            }
        }
    }
}
