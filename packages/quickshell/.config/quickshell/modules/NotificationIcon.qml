pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "."

Item {
    id: root

    required property var notification
    property int size: 36

    function resolve(icon) {
        if (icon.startsWith("image://icon/"))
            icon = icon.slice("image://icon/".length);
        if (icon === "" || icon.startsWith("/") || icon.startsWith("file:") || icon.startsWith("image://"))
            return icon;

        // O marcador de ícone ausente carrega como imagem válida; sem isto o fallback nunca pega.
        return Quickshell.hasThemeIcon(icon) ? Quickshell.iconPath(icon) : "";
    }

    readonly property string source: {
        if (!root.notification)
            return "";
        return root.resolve(root.notification.image) || root.resolve(root.notification.appIcon);
    }

    implicitWidth: root.size
    implicitHeight: root.size

    Rectangle {
        anchors.fill: parent
        radius: Math.min(8, root.size / 4)
        color: Theme.surface
        visible: icon.status !== Image.Ready

        Text {
            anchors.centerIn: parent
            text: {
                const name = root.notification ? root.notification.appName : "";
                return name !== "" ? name.charAt(0).toUpperCase() : "󰂚";
            }
            color: Theme.subtle
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

        sourceSize.width: root.size * 2
        sourceSize.height: root.size * 2
        asynchronous: true
    }
}
