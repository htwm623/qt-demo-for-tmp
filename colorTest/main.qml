import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")
    
    Item {
        width: 200
        height: parent.height
        ColorWheel {
            onUpdateRGB: {
                console.log("update rgb")
                console.log(R, G, B)
            }
        }
    }
}
