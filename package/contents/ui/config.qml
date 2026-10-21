import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

Item {
    id: configPage

    implicitWidth: 400
    implicitHeight: 300

    property int currentVersion: 10100
    property string currentVersionString: "1.1.0"
    property string latestVersionString: ""
    property bool checking: false
    property bool updateAvailable: false
    property string statusMessage: ""

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing

        Kirigami.Heading {
            level: 2
            text: qsTr("Настройки Lofi Radio Mini")
            Layout.fillWidth: true
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        // Информация о версии
        RowLayout {
            Layout.fillWidth: true

            QQC2.Label {
                text: qsTr("Версия:")
            }

            QQC2.Label {
                text: configPage.currentVersionString
                opacity: 0.7
            }

            Item { Layout.fillWidth: true }

            QQC2.Button {
                text: configPage.checking ? qsTr("Проверка...") : qsTr("Проверить обновления")
                enabled: !configPage.checking
                onClicked: checkForUpdates()
            }
        }

        // Сообщение о результате проверки
        QQC2.Label {
            visible: configPage.statusMessage.length > 0
            text: configPage.statusMessage
            color: configPage.updateAvailable ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.textColor
            opacity: 0.9
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        // Кнопка обновления
        QQC2.Button {
            visible: configPage.updateAvailable
            text: qsTr("Скачать обновление")
            onClicked: Qt.openUrlExternally("https://github.com/Caracoto4/plasma-lofi-radio-mini/releases/latest")
            Layout.fillWidth: true
        }

        Item { Layout.fillHeight: true }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        // Информация
        QQC2.Label {
            text: qsTr("Виджет использует поток с lofiradio.ru")
            opacity: 0.6
            font.pixelSize: Kirigami.Units.gridUnit * 0.8
            Layout.fillWidth: true
        }

        QQC2.Label {
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
        statusMessage = qsTr("Проверка обновлений...");

        var xhr = new XMLHttpRequest();
        xhr.open("GET", "https://api.github.com/repos/Caracoto4/plasma-lofi-radio-mini/releases/latest", true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                checking = false;
                if (xhr.status === 200) {
                    try {
                        var data = JSON.parse(xhr.responseText);
                        var tagName = data.tag_name || "";
                        latestVersionString = tagName.replace(/^v/, "");
                        
                        var current = parseVersion(configPage.currentVersionString);
                        var latest = parseVersion(latestVersionString);
                        
                        if (latest > current) {
                            updateAvailable = true;
                            statusMessage = qsTr("Доступна новая версия: %1").arg(latestVersionString);
                        } else {
                            statusMessage = qsTr("У вас установлена последняя версия");
                        }
                    } catch (e) {
                        statusMessage = qsTr("Ошибка при проверке обновлений");
                        console.log("Failed to parse update info:", e);
                    }
                } else {
                    statusMessage = qsTr("Не удалось проверить обновления (ошибка %1)").arg(xhr.status);
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
