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

    readonly property var notifyPorts: [8731, 8732, 8733]

    // Восстановление состояния при загрузке
    Component.onCompleted: {
        var savedVol = plasmoid.configuration.readEntry("volume", -1);
        if (savedVol >= 0) {
            engine.volume = savedVol;
        }
        var wasPlaying = plasmoid.configuration.readEntry("playing", false);
        if (wasPlaying) {
            engine.play();
        }
    }

    // Сохранение громкости
    Connections {
        target: engine
        function onVolumeChanged() {
            plasmoid.configuration.writeEntry("volume", engine.volume);
        }
    }

    // Сохранение состояния play/pause + уведомление о смене трека
    Connections {
        target: engine
        function onPlayingChanged() {
            plasmoid.configuration.writeEntry("playing", engine.playing);
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
        for (var i = 0; i < notifyPorts.length; i++) {
            var xhr = new XMLHttpRequest();
            xhr.open("POST", "http://127.0.0.1:" + notifyPorts[i] + "/notify", true);
            xhr.setRequestHeader("Content-Type", "application/json");
            xhr.send(JSON.stringify({ title: title, text: text }));
            // Не ждём ответа, просто отправляем на первый доступный порт
            break;
        }
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
