pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "."

Item {
    id: root

    required property var notification
    property int size: 36

    // O `check` faz o iconPath devolver vazio quando o tema não tem o ícone, em
    // vez de um caminho quebrado.
    readonly property string source: {
        if (!root.notification)
            return "";
        if (root.notification.image !== "")
            return root.notification.image;
        if (root.notification.appIcon !== "")
            return Quickshell.iconPath(root.notification.appIcon, true);
        return "";
    }

    implicitWidth: root.size
    implicitHeight: root.size

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: Theme.surface
        visible: icon.status !== Image.Ready

        Text {
            anchors.centerIn: parent
            text: {
                const name = root.notification ? root.notification.appName : "";
                return name !== "" ? name.charAt(0).toUpperCase() : "󰂚";
            }
            color: Theme.cyan
            font.family: "Hack Nerd Font"
            font.pixelSize: Math.round(root.size * 0.45)
            font.weight: Font.Bold
        }
    }

    Image {
        id: icon
        anchors.fill: parent
        source: root.source
        fillMode: Image.PreserveAspectFit
        mipmap: true
        visible: status === Image.Ready
    }
}
