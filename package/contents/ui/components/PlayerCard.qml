import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

Item {
    id: card

    property var engine: null

    property bool compact: false
    property bool previewActive: false
    property bool previewPlaying: true
    property string previewTitle: ""
    property string previewArtist: ""

    property bool drawBackground: true

    readonly property var stream: engine !== null
                                  ? engine
                                  : ({
                                        playing: false,
                                        buffering: false,
                                        title: "",
                                        artist: "",
                                        stationName: "",
                                        volume: 0.75,
                                        stations: [{name: "lofi hip hop"}, {name: "lofi chill"}],
                                        stationIndex: 0,
                                        toggle: function(){},
                                        nextStation: function(){},
                                        previousStation: function(){},
                                        setVolume: function(){}
                                    })

    readonly property bool playing: previewActive ? previewPlaying : stream.playing
    readonly property bool buffering: previewActive ? false : stream.buffering
    readonly property string trackTitle: previewActive ? previewTitle : stream.title
    readonly property string trackArtist: previewActive ? previewArtist : stream.artist
    readonly property string currentStation: stream.stations ? stream.stations[stream.stationIndex].name : ""
    property real volume: stream.volume

    implicitWidth: 260
    implicitHeight: compact ? 34 : 180

    Rectangle {
        id: backdrop
        anchors.fill: parent
        visible: false
        radius: Kirigami.Units.cornerRadius
        color: Kirigami.Theme.backgroundColor
        border.width: 1
        border.color: Qt.rgba(Kirigami.Theme.textColor.r,
                               Kirigami.Theme.textColor.g,
                               Kirigami.Theme.textColor.b, 0.1)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: card.compact ? 0 : Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.smallSpacing

        Header {
            Layout.fillWidth: true
            visible: !card.compact
        }

        TrackInfo {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !card.compact
        }

        ControlsRow {
            Layout.fillWidth: true
            visible: !card.compact
        }

        VolumeRow {
            Layout.fillWidth: true
            visible: !card.compact
        }

        CompactIcon {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: card.compact
        }
    }

    component Header: RowLayout {
        spacing: Kirigami.Units.smallSpacing

        Rectangle {
            width: 6
            height: 6
            radius: 3
            color: card.playing ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.disabledTextColor

            SequentialAnimation on opacity {
                running: card.playing
                loops: Animation.Infinite
                NumberAnimation { to: 0.3; duration: 1000; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 1.0; duration: 1000; easing.type: Easing.InOutQuad }
            }
        }

        Kirigami.Heading {
            level: 5
            text: card.buffering ? qsTr("загрузка…") : qsTr("lofi radio")
            font.capitalization: Font.AllUppercase
            font.letterSpacing: 1.0
            opacity: 0.6
            Layout.fillWidth: true
        }
    }

    component TrackInfo: ColumnLayout {
        spacing: 2

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: titleText.implicitHeight + 2
            clip: true

            Kirigami.Heading {
                id: titleText
                level: 4
                text: card.trackTitle.length > 0 ? card.trackTitle : qsTr("Подключение…")
                elide: Text.ElideNone
                wrapMode: Text.NoWrap

                readonly property bool overflow: implicitWidth > parent.width + 2

                NumberAnimation on x {
                    running: titleText.overflow
                    loops: Animation.Infinite
                    from: 0
                    to: -(titleText.implicitWidth - titleText.parent.width + 16)
                    duration: Math.max(4000, titleText.implicitWidth * 22)
                    easing.type: Easing.InOutSine
                    onRunningChanged: if (!running) titleText.x = 0
                }
            }
        }

        Kirigami.Heading {
            level: 5
            text: card.trackArtist.length > 0 ? card.trackArtist : "lofiradio.ru"
            opacity: 0.5
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }

    component ControlsRow: RowLayout {
        spacing: Kirigami.Units.largeSpacing

        Item { Layout.fillWidth: true }

        Controls.ToolButton {
            implicitWidth: 40
            implicitHeight: 40
            display: Controls.AbstractButton.IconOnly
            background: Rectangle {
                radius: width / 2
                color: parent.hovered
                       ? Qt.rgba(Kirigami.Theme.highlightColor.r,
                                 Kirigami.Theme.highlightColor.g,
                                 Kirigami.Theme.highlightColor.b, 0.25)
                       : Qt.rgba(Kirigami.Theme.highlightColor.r,
                                 Kirigami.Theme.highlightColor.g,
                                 Kirigami.Theme.highlightColor.b, 0.12)
            }
            Kirigami.Icon {
                anchors.centerIn: parent
                width: 18
                height: 18
                source: card.playing ? "media-playback-pause" : "media-playback-start"
            }
            scale: pressed ? 0.92 : 1.0
            Behavior on scale { NumberAnimation { duration: 100 } }
            onClicked: {
                if (card.previewActive)
                    card.previewPlaying = !card.previewPlaying;
                else
                    stream.toggle();
            }
            Controls.ToolTip.text: card.playing ? qsTr("Пауза") : qsTr("Воспроизвести")
            Controls.ToolTip.visible: hovered
        }

        Item { Layout.fillWidth: true }
    }

    component VolumeRow: RowLayout {
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Icon {
            width: 14
            height: 14
            source: card.volume <= 0.01
                    ? "audio-volume-muted"
                    : (card.volume < 0.5 ? "audio-volume-low" : "audio-volume-high")
            opacity: 0.5
        }

        Controls.Slider {
            Layout.fillWidth: true
            from: 0
            to: 1
            value: card.volume
            onMoved: stream.setVolume(value)
        }
    }

    component CompactIcon: Item {
        Kirigami.Icon {
            anchors.centerIn: parent
            width: 20
            height: 20
            source: card.playing ? "media-playback-pause" : "media-playback-start"
        }
    }
}
