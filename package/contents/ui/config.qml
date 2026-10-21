import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCMUtils

KCMUtils.SimpleKCM {
    id: configPage

    property int currentVersion: 10100
    property string currentVersionString: "1.1.0"
    property string latestVersionString: ""
    property bool checking: false
    property bool updateAvailable: false
    property string statusMessage: ""

    KCMUtils.ConfigModule.buttons: KCMUtils.ConfigModule.NoAdditionalButton

    Kirigami.FormLayout {
        anchors.fill: parent

        Item {
            Kirigami.FormLayout.isSection: true
            Kirigami.FormLayout.label: i18n("Информация")

            QQC2.Label {
                text: i18n("Версия: %1", configPage.currentVersionString)
            }
        }

        Item {
            Kirigami.FormLayout.label: i18n("Обновления")

            QQC2.Button {
                text: configPage.checking ? i18n("Проверка...") : i18n("Проверить обновления")
                enabled: !configPage.checking
                onClicked: checkForUpdates()
            }
        }

        QQC2.Label {
            visible: configPage.statusMessage.length > 0
            text: configPage.statusMessage
            color: configPage.updateAvailable ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.textColor
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        QQC2.Button {
            visible: configPage.updateAvailable
            text: i18n("Скачать обновление")
            onClicked: Qt.openUrlExternally("https://github.com/Caracoto4/plasma-lofi-radio-mini/releases/latest")
        }

        Item {
            Kirigami.FormLayout.isSection: true
            Kirigami.FormLayout.label: i18n("О виджете")

            QQC2.Label {
                text: i18n("Минималистичный виджет lofi-радио для KDE Plasma 6")
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            QQC2.Label {
                text: i18n('Поток: <a href="https://lofiradio.ru">lofiradio.ru</a>')
                onLinkActivated: Qt.openUrlExternally(link)
            }

            QQC2.Label {
                text: i18n('Репозиторий: <a href="https://github.com/Caracoto4/plasma-lofi-radio-mini">GitHub</a>')
                onLinkActivated: Qt.openUrlExternally(link)
            }
        }
    }

    function checkForUpdates() {
        checking = true;
        latestVersionString = "";
        updateAvailable = false;
        statusMessage = i18n("Проверка обновлений...");

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
                            statusMessage = i18n("Доступна новая версия: %1", latestVersionString);
                        } else {
                            statusMessage = i18n("У вас установлена последняя версия");
                        }
                    } catch (e) {
                        statusMessage = i18n("Ошибка при проверке обновлений");
                        console.log("Failed to parse update info:", e);
                    }
                } else {
                    statusMessage = i18n("Не удалось проверить обновления (ошибка %1)", xhr.status);
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
