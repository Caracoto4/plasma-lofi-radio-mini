import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

Item {
    id: configPage

    implicitWidth: 400
    implicitHeight: 300

    property int currentVersion: 10100  // 1.1.0
    property string currentVersionString: "1.1.0"
    property string latestVersionString: ""
    property bool checking: false
    property bool updateAvailable: false

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing

        Kirigami.Heading {
            level: 2
            text: qsTr("Настройки Lofi Radio Mini")
            Layout.fillWidth: true
        }

        // Информация о версии
        Kirigami.Separator {
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.largeSpacing

            Kirigami.Heading {
                level: 4
                text: qsTr("Версия:")
            }

            Controls.Label {
                text: configPage.currentVersionString
                opacity: 0.7
            }

            Item { Layout.fillWidth: true }

            Controls.Button {
                text: checking ? qsTr("Проверка...") : qsTr("Проверить обновления")
                enabled: !checking
                onClicked: checkForUpdates()
            }
        }

        // Сообщение о результате проверки
        Controls.Label {
            visible: latestVersionString.length > 0
            text: updateAvailable
                  ? qsTr("Доступна новая версия: %1").arg(latestVersionString)
                  : qsTr("У вас установлена последняя версия")
            color: updateAvailable ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.textColor
            opacity: 0.9
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        // Кнопка обновления
        Controls.Button {
            visible: updateAvailable
            text: qsTr("Скачать обновление")
            onClicked: Qt.openUrlExternally("https://github.com/Caracoto4/plasma-lofi-radio-mini/releases/latest")
            Layout.fillWidth: true
        }

        Item { Layout.fillHeight: true }

        // Информация
        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Controls.Label {
            text: qsTr("Виджет использует поток с lofiradio.ru")
            opacity: 0.6
            font.pixelSize: Kirigami.Units.gridUnit * 0.8
            Layout.fillWidth: true
        }

        Controls.Label {
            text: '<a href="https://github.com/Caracoto4/plasma-lofi-radio-mini">GitHub</a>'
            onLinkActivated: Qt.openUrlExternally(link)
            opacity: 0.6
            font.pixelSize: Kirigami.Units.gridUnit * 0.8
            Layout.fillWidth: true
        }
    }

    function checkForUpdates() {
        checking = true;
        latestVersionString = "";
        updateAvailable = false;

        var xhr = new XMLHttpRequest();
        xhr.open("GET", "https://api.github.com/repos/Caracoto4/plasma-lofi-radio-mini/releases/latest", true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                checking = false;
                if (xhr.status === 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        var tagName = data.tag_name || "";
                        // Убираем 'v' в начале если есть
                        latestVersionString = tagName.replace(/^v/, "");
                        
                        // Парсим версии для сравнения
                        var current = parseVersion(configPage.currentVersionString);
                        var latest = parseVersion(latestVersionString);
                        
                        if (latest > current) {
                            updateAvailable = true;
                        }
                    } catch (e) {
                        console.log("Failed to parse update info:", e);
                    }
                } else {
                    console.log("Failed to check for updates, status:", xhr.status);
                }
            }
        };
        xhr.send();
    }

    function parseVersion(versionString) {
        var parts = versionString.split(".");
        if (parts.length < 3) return 0;
        return parseInt(parts[0]) * 10000 + parseInt(parts[1]) * 100 + parseInt(parts[2]);
    }
}
