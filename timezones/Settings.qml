import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Widgets
import qs.Services.UI
import "timezone-utils.js" as TimezoneUtils

// Settings Component - Same UI as Panel but adapted for settings page
ColumnLayout {
    id: root
    spacing: Style.marginM

    property var pluginApi: null

    // Configuration
    property var cfg: pluginApi?.pluginSettings || ({})
    property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

    property var timezones: cfg.timezones ?? defaults.timezones ?? []
    property int rotationInterval: (cfg.rotationInterval ?? defaults.rotationInterval ?? 5000) / 1000
    property string timeFormat: cfg.timeFormat ?? defaults.timeFormat ?? "HH:mm"
    property string tipTimeFormat: cfg.tipTimeFormat ?? defaults.tipTimeFormat ?? "HH:mm, ddd DD-MMM"

    Component.onCompleted: {
        if (pluginApi) {
            Logger.i("Timezones", "Settings initialized");
        }
    }

    // This function is called by the dialog to save settings
    function saveSettings() {
        if (!pluginApi) {
            Logger.e("Timezones", "Cannot save settings: pluginApi is null");
            return;
        }

        // Update the plugin settings object
        pluginApi.pluginSettings.timezones = timezones;
        pluginApi.pluginSettings.rotationInterval = rotationInterval * 1000;
        pluginApi.pluginSettings.timeFormat = timeFormat;
        pluginApi.pluginSettings.tipTimeFormat = tipTimeFormat;

        // Save to disk
        pluginApi.saveSettings();

        Logger.i("Timezones", "Settings saved successfully");
    }

    function updateTimezones(newTimezones) {
        timezones = newTimezones;
        if (pluginApi) {
            pluginApi.pluginSettings.timezones = newTimezones;
            pluginApi.saveSettings();
        }
    }

    // Display Settings
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginM

        NText {
            text: pluginApi?.tr("settings.display-settings")
            pointSize: Style.fontSizeM
            font.weight: Font.Medium
            color: Color.mOnSurface
        }

        // Rotation Interval
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginM

            NText {
                text: pluginApi?.tr("settings.rotationInterval")
                pointSize: Style.fontSizeS
                color: Color.mOnSurfaceVariant
                Layout.fillWidth: true
            }

            NSpinBox {
                id: rotationSpinBox
                from: 1
                to: 60
                value: root.rotationInterval
                suffix: " s"
                onValueChanged: {
                    root.rotationInterval = value;
                    if (pluginApi) {
                        pluginApi.pluginSettings.rotationInterval = value * 1000;
                        pluginApi.saveSettings();
                    }
                }
            }
        }

        // Time Format
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginM

            NText {
                text: pluginApi?.tr("settings.timeFormat")
                pointSize: Style.fontSizeS
                color: Color.mOnSurfaceVariant
                Layout.fillWidth: true
            }

            NComboBox {
                id: timeFormatCombo
                model: [
                    {
                        "key": "HH:mm",
                        "name": pluginApi?.tr("settings.format.24h")
                    },
                    {
                        "key": "HH:mm:ss",
                        "name": pluginApi?.tr("settings.format.24h-seconds")
                    },
                    {
                        "key": "h:mm A",
                        "name": pluginApi?.tr("settings.format.12h")
                    },
                    {
                        "key": "h:mm:ss A",
                        "name": pluginApi?.tr("settings.format.12h-seconds")
                    }
                ]
                currentKey: root.timeFormat
                onSelected: key => {
                    root.timeFormat = key;
                    if (pluginApi) {
                        pluginApi.pluginSettings.timeFormat = key;
                        pluginApi.saveSettings();
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginM
            NText {
                text: pluginApi?.tr("settings.tipTimeFormat")
                pointSize: Style.fontSizeS
                color: Color.mOnSurfaceVariant
                Layout.fillWidth: true
            }
            NTextInput {
                id: tipTimeFormatBox
                Layout.minimumWidth: 200
                Layout.maximumWidth: 200
                text: root.tipTimeFormat
                placeholderText: pluginApi?.tr("settings.ex-tip")
                onTextChanged: {
                    root.tipTimeFormat = text;
                    if (pluginApi) {
                        pluginApi.pluginSettings.tipTimeFormat = text;
                        pluginApi.saveSettings();
                    }
                }
            }
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.marginM
            NLabel {
                description: "https://momentjscom.readthedocs.io/en/latest/moment/04-displaying/01-format/"
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: Color.mOutline
    }

    // Timezones Section
    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Style.marginM
        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                NText {
                    text: pluginApi?.tr("settings.timezones")
                    pointSize: Style.fontSizeM
                    font.weight: Font.Medium
                    color: Color.mOnSurface
                }
                RowLayout {
                    Layout.fillWidth: true
                    // shift fields descriptions by 10 to right
                    NText {
                        Layout.fillWidth: false
                        Layout.minimumWidth: 10
                    }
                    NText {
                        Layout.fillWidth: false
                        Layout.minimumWidth: 150
                        color: Color.mOnSurfaceVariant
                        pointSize: Style.fontSizeS
                        text: pluginApi?.tr("settings.alias")
                    }
                    NText {
                        Layout.fillWidth: true
                        color: Color.mOnSurfaceVariant
                        pointSize: Style.fontSizeS
                        text: pluginApi?.tr("settings.iana-tz")
                    }
                }
                RowLayout {
                    Layout.alignment: Qt.AlignVBottom
                    Layout.fillWidth: true
                    NTextInput {
                        id: tzNewAlias
                        Layout.fillWidth: false
                        Layout.minimumWidth: 150
                        placeholderText: pluginApi?.tr("settings.ex-alias")
                    }
                    NTextInput {
                        id: tzNewTimezone
                        Layout.fillWidth: true
                        placeholderText: pluginApi?.tr("settings.ex-tz")
                    }
                    NButton {
                        icon: "plus"
                        enabled: tzNewAlias.text != "" && tzNewTimezone.text != ""
                        Layout.margins: 0
                        Layout.alignment: Qt.AlignVBottom
                        onClicked: {
                            let a = tzNewAlias.text;
                            let t = tzNewTimezone.text;
                            if (!TimezoneUtils.isZoneValid(t)) {
                                ToastService.showError(pluginApi?.tr("settings.err-tz") + ": " + t);
                                return;
                            }
                            tzNewAlias.text = "";
                            tzNewTimezone.text = "";
                            let newTimezones = root.timezones.slice();
                            // Add first available timezone from the list
                            newTimezones.push({
                                name: a,
                                timezone: t,
                                enabled: true
                            });
                            root.timezones = newTimezones;
                            if (pluginApi) {
                                pluginApi.pluginSettings.timezones = newTimezones;
                                pluginApi.saveSettings();
                            }
                        }
                    }
                }
            }
        }

        // Timezone list
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Style.marginS

            Repeater {
                model: root.timezones

                delegate: Rectangle {
                    required property int index
                    required property var modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: timezoneContent.implicitHeight + Style.marginS * 2
                    color: modelData.enabled ? Color.mSurface : Color.mSurfaceVariant
                    radius: Style.radiusM
                    border.color: Color.mOutline
                    border.width: 1

                    RowLayout {
                        id: timezoneContent
                        anchors.fill: parent
                        anchors.margins: Style.marginS
                        spacing: Style.marginS

                        NToggle {
                            id: toggleItem
                            Layout.alignment: Qt.AlignVCenter
                            checked: modelData.enabled
                            onToggled: checked => {
                                var tzs = root.timezones.slice();
                                tzs[index].enabled = checked;
                                root.updateTimezones(tzs);
                            }
                        }
                        NText {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            text: modelData.name + " (" + modelData.timezone + ")"
                        }

                        NIconButton {
                            id: deleteButton
                            Layout.alignment: Qt.AlignVCenter
                            icon: "trash"
                            onClicked: {
                                var tzs = root.timezones.slice();
                                tzs.splice(index, 1);
                                root.updateTimezones(tzs);
                            }
                        }
                    }
                }
            }
        }

        // API info footer
        NText {
            Layout.fillWidth: true
            text: pluginApi?.tr("settings.api-info")
            pointSize: Style.fontSizeXS
            color: Color.mOnSurfaceVariant
            opacity: 0.7
            horizontalAlignment: Text.AlignHCenter
            Layout.topMargin: Style.marginS
        }
    }

    Item {
        Layout.fillHeight: true
    }
}
