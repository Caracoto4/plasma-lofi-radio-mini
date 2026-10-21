import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

import "components" as Components

PlasmoidItem {
    id: root

    preferredRepresentation: fullRepresentation

    property var engine: Components.StreamPlayer

    // Таймер дебаунса для сохранения громкости — не писать на каждое
    // микро-движение ползунка, а только когда пользователь перестал
    // крутить. Финальный sync гарантируется в onDestruction.
    Timer {
        id: volumeSaveTimer
        interval: 500
        repeat: false
        onTriggered: Plasmoid.configuration.sync()
    }

    // Восстановление состояния при загрузке
    Component.onCompleted: {
        // Надёжный автозапуск средствами Plasma: сервис создаётся только
        // когда пользователь включил опцию в настройках
        Plasmoid.autoStartEnabled = Plasmoid.configuration.autoplay;

        // Восстановить громкость
        var savedVol = Plasmoid.configuration.volume;
        if (savedVol >= 0 && savedVol <= 1) {
            engine.volume = savedVol;
        }

        // Воспроизводить, если автозапуск включён в настройках
        if (Plasmoid.configuration.autoplay) {
            engine.play();
        }
    }

    // Финальное сохранение при закрытии виджета — гарантирует, что
    // все pending-записи (особенно volume) успеются записаться в файл
    // до того, как Plasma отключит виджет.
    Component.onDestruction: {
        volumeSaveTimer.stop();
        Plasmoid.configuration.sync();
    }

    // Сохранение громкости (с дебаунсом — не писать на каждое движение ползунка)
    Connections {
        target: engine
        function onVolumeUpdated() {
            Plasmoid.configuration.writeEntry("volume", engine.volume);
            volumeSaveTimer.restart();
        }
    }

    // Запоминаем фактический порт helper-сервиса в конфиг — окно настроек
    // не имеет доступа к engine, а кнопке «Проверить обновление» нужен порт
    Connections {
        target: engine
        function onHelperPortChanged() {
            Plasmoid.configuration.writeEntry("helperPort", engine.helperPort);
            Plasmoid.configuration.sync();
        }
    }

    // Сохранение состояния play/pause + уведомление о смене трека
    Connections {
        target: engine
        function onPlaybackStateChanged() {
            Plasmoid.configuration.writeEntry("playing", engine.playing);
            Plasmoid.configuration.sync();
        }
        function onTrackChanged() {
            if (!Plasmoid.configuration.notifications)
                return;
            if (engine.title.length > 0 || engine.artist.length > 0) {
                sendNotification(
                    engine.artist.length > 0 ? engine.artist : "Lofi Radio",
                    engine.title.length > 0 ? engine.title : qsTr("Новый трек")
                );
            }
        }
    }

    function sendNotification(title, text) {
        var xhr = new XMLHttpRequest();
        xhr.open("POST", engine.helperUrl("/notify"), true);
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
