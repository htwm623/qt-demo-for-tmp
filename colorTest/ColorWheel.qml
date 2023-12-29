import QtQuick 2.2
import QtQuick.Window 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15

Item {
    id: root
    width: 600
    height: 400
    focus: true

    // Color value in RGBA with floating point values between 0.0 and 1.0.

    // creates color value from hue, saturation, brightness, alpha
    function hsba(h, s, b, a) {
        var lightness = (2 - s)*b;
        var satHSL = s*b/((lightness <= 1) ? lightness : 2 - lightness);
        lightness /= 2;
        return Qt.hsla(h, satHSL, lightness, a);
    }

    function clamp(val, min, max){
        return Math.max(min, Math.min(max, val)) ;
    }

    function mix(x, y , a)
    {
        return x * (1 - a) + y * a ;
    }

    function hsva2rgba(hsva) {
        var c = hsva.z * hsva.y ;
        var x = c * (1 - Math.abs( (hsva.x * 6) % 2 - 1 )) ;
        var m = hsva.z - c ;
        console.log("update hsva2rgba")

        if (hsva.x < 1/6 )
            return Qt.vector4d(c+m, x+m, m, hsva.w) ;
        else if (hsva.x < 1/3 )
            return Qt.vector4d(x+m, c+m, m, hsva.w) ;
        else if (hsva.x < 0.5 )
            return Qt.vector4d(m, c+m, x+m, hsva.w) ;
        else if (hsva.x < 2/3 )
            return Qt.vector4d(m, x+m, c+m, hsva.w) ;
        else if (hsva.x < 5/6 )
            return Qt.vector4d(x+m, m, c+m, hsva.w) ;
        else
            return Qt.vector4d(c+m, m, x+m, hsva.w) ;

    }

    function rgba2hsva(rgba)
    {
        var r = rgba.x;
        var g = rgba.y;
        var b = rgba.z;
        var max = Math.max(r, g, b), min = Math.min(r, g, b);
        var h, s, v = max;

        var d = max - min;
        s = max === 0 ? 0 : d / max;

        if(max == min){
            h = 0; // achromatic
        } else{
            switch(max){
                case r:
                    h = (g - b) / d + (g < b ? 6 : 0);
                    break;
                case g:
                    h = (b - r) / d + 2;
                    break;
                case b:
                    h = (r - g) / d + 4;
                    break;
            }
            h /= 6;
        }

        return Qt.vector4d(h, s, v, rgba.w);
    }


    // extracts integer color channel value [0..255] from color value
    function getChannelStr(clr, channelIdx) {
        return parseInt(clr.toString().substr(channelIdx*2 + 1, 2), 16);
    }

    //convert to hexa with nb char
    function intToHexa(val , nb)
    {
        var hexaTmp = val.toString(16) ;
        var hexa = "";
        var size = hexaTmp.length
        if (size < nb )
        {
            for(var i = 0 ; i < nb - size ; ++i)
            {
                hexa += "0"
            }
        }
        return hexa + hexaTmp
    }

    function hexaFromRGBA(red, green, blue, alpha)
    {
        return intToHexa(Math.round(red * 255), 2)+intToHexa(Math.round(green * 255), 2)+intToHexa(Math.round(blue * 255), 2);
    }


    property vector4d colorHSVA: Qt.vector4d(1, 0, 1, 1)
    QtObject {
        id: m
        // Color value in HSVA with floating point values between 0.0 and 1.0.
        property vector4d colorRGBA: hsva2rgba(root.colorHSVA)
    }

    signal accepted
    signal updateRGB(var R, var G, var B)

    function handleClick () {
        console.log("handleClick")
        // r 255 g 247 b 48
        const temp = Qt.vector4d(255/255, 247/255, 48/255, 1)
        colorHSVA = rgba2hsva(temp)
        console.log("colorHSVA", colorHSVA)
    }

    onAccepted: {
        console.debug("DATA => accepted")
        console.log(Math.round(m.colorRGBA.x * 255), "R")
        console.log(Math.round(m.colorRGBA.y * 255), "G")
        console.log(Math.round(m.colorRGBA.z * 255), "B")
        root.updateRGB(Math.round(m.colorRGBA.x * 255), Math.round(m.colorRGBA.y * 255), Math.round(m.colorRGBA.z * 255))
    }

    RowLayout {
        spacing: 20
        anchors.fill: parent

        Wheel {
            id: wheel
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 200
            Layout.minimumHeight: 200

            hue: colorHSVA.x
            saturation: colorHSVA.y
            onUpdateHS: {
                colorHSVA = Qt.vector4d(hueSignal,saturationSignal, colorHSVA.z, colorHSVA.w)
            }
            onAccepted: {
                root.accepted()
            }
        }

        // brightness picker slider
        Item {
            Layout.fillHeight: true
            Layout.minimumWidth: 20
            Layout.minimumHeight: 200

            //Brightness background
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop {
                        id: brightnessBeginColor
                        position: 0.0
                        color: {
                            var rgba = hsva2rgba(
                                        Qt.vector4d(colorHSVA.x,
                                                    colorHSVA.y, 1, 1))
                            return Qt.rgba(rgba.x, rgba.y, rgba.z, rgba.w)
                        }
                    }
                    GradientStop {
                        position: 1.0
                        color: "#000000"
                    }
                }
            }

            VerticalSlider {
                id: brigthnessSlider
                anchors.fill: parent
                value: colorHSVA.z
                onValueChanged: {
                    colorHSVA = Qt.vector4d(colorHSVA.x, colorHSVA.y, value, colorHSVA.w)
                }
                onAccepted: {
                    root.accepted()
                }
            }
        }

        // Alpha picker slider
        Item {
            Layout.fillHeight: true
            Layout.minimumWidth: 20
            Layout.minimumHeight: 200
            CheckerBoard {
                cellSide: 4
            }
            //  alpha intensity gradient background
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: Qt.rgba(m.colorRGBA.x, m.colorRGBA.y, m.colorRGBA.z, 1)
                    }
                    GradientStop {
                        position: 1.0
                        color: "#00000000"
                    }
                }
            }
            VerticalSlider {
                id: alphaSlider
                value: colorHSVA.w
                anchors.fill: parent
                onValueChanged: {
                    colorHSVA.w = value
                }
                onAccepted: {
                    root.accepted()
                }
            }
        }

        // text inputs
        ColumnLayout {
            Layout.fillHeight: true
            Layout.minimumWidth: 150
            Layout.minimumHeight: 200
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            // current color display
            Rectangle {
                Layout.minimumWidth: 150
                Layout.minimumHeight: 50
                CheckerBoard {
                    cellSide: 5
                }
                Rectangle {
                    id: colorDisplay
                    width: parent.width
                    height: parent.height
                    border.width: 1
                    border.color: "black"
                    color: Qt.rgba(m.colorRGBA.x, m.colorRGBA.y, m.colorRGBA.z)
                    opacity: m.colorRGBA.w
                }
            }


            // current color value
            Item {
                Layout.minimumWidth: 120
                Layout.minimumHeight: 25

                Text {
                    id: captionBox
                    text: "#"
                    width: 18
                    height: parent.height
                    color: "#AAAAAA"
                    font.pixelSize: 16
                    font.bold: true
                }
                PanelBorder {
                    height: parent.height
                    anchors.left : captionBox.right
                    width: parent.width - captionBox.width
                    TextInput {
                        id: currentColor
                        color: "#AAAAAA"
                        selectionColor: "#FF7777AA"
                        font.pixelSize: 20
                        font.capitalization: "AllUppercase"
                        maximumLength: 9
                        focus: true
                        text: hexaFromRGBA(m.colorRGBA.x, m.colorRGBA.y,
                                                      m.colorRGBA.z, m.colorRGBA.w)
                        font.family: "TlwgTypewriter"
                        selectByMouse: true
                        validator: RegExpValidator {
                            regExp: /^([A-Fa-f0-9]{6})$/
                        }
                        onEditingFinished: {
                            var colorTmp = Qt.vector4d( parseInt(text.substr(0, 2), 16) / 255,
                                                    parseInt(text.substr(2, 2), 16) / 255,
                                                    parseInt(text.substr(4, 2), 16) / 255,
                                                    colorHSVA.w) ;
                            colorHSVA = rgba2hsva(colorTmp)
                        }
                    }
                }
            }
            // H, S, B color value boxes
            Column {
                Layout.minimumWidth: 80
                Layout.minimumHeight: 25
                NumberBox {
                    id: hue
                    caption: "H"
                    // TODO: put in NumberBox
                    value: Math.round(colorHSVA.x * 100000) / 100000 // 5 Decimals
                    decimals: 2
                    max: 1
                    min: 0
                    onAccepted: {
                        colorHSVA =  Qt.vector4d(boxValue, colorHSVA.y, colorHSVA.z, colorHSVA.w)
                        root.accepted()
                    }
                }
                NumberBox {
                    id: sat
                    caption: "S"
                    value: Math.round(colorHSVA.y * 100) / 100 // 2 Decimals
                    decimals: 2
                    max: 1
                    min: 0
                    onAccepted: {
                        colorHSVA = Qt.vector4d(colorHSVA.x, boxValue, colorHSVA.z, colorHSVA.w)
                        root.accepted()
                    }
                }
                NumberBox {
                    id: brightness
                    caption: "B"
                    value: Math.round(colorHSVA.z * 100) / 100 // 2 Decimals
                    decimals: 2
                    max: 1
                    min: 0
                    onAccepted: {
                        colorHSVA = Qt.vector4d(colorHSVA.x, colorHSVA.y, boxValue, colorHSVA.w)
                        root.accepted()
                    }
                }
                NumberBox {
                    id: hsbAlpha
                    caption: "A"
                    value: Math.round(colorHSVA.w * 100) / 100 // 2 Decimals
                    decimals: 2
                    max: 1
                    min: 0
                    onAccepted: {
                        colorHSVA.w = boxValue
                        root.accepted()
                    }
                }
            }

            // R, G, B color values boxes
            Column {
                Layout.minimumWidth: 100
                Layout.minimumHeight: 25
                // 添加输入框显示RGB值中的G值

                Button {
                    id: btn
                    text: "click"
                    onClicked: {
                        handleClick()
                    }
                }

                NumberBox {
                    id: red
                    caption: "R"
                    value: Math.round(m.colorRGBA.x * 255)
                    min: 0
                    max: 255
                    decimals: 0
                    onAccepted: {
                        var colorTmp = Qt.vector4d( boxValue / 255,
                                                    m.colorRGBA.y,
                                                    m.colorRGBA.z,
                                                    colorHSVA.w) ;
                        colorHSVA = rgba2hsva(colorTmp)
                        root.accepted()
                    }
                }
                NumberBox {
                    id: green
                    caption: "G"
                    value: Math.round(m.colorRGBA.y * 255)
                    min: 0
                    max: 255
                    decimals: 0
                    onAccepted: {
                        var colorTmp = Qt.vector4d( m.colorRGBA.x,
                                                    boxValue / 255,
                                                    m.colorRGBA.z,
                                                    colorHSVA.w) ;
                        colorHSVA = rgba2hsva(colorTmp)
                        root.accepted()
                    }
                }
                NumberBox {
                    id: blue
                    caption: "B"
                    value: Math.round(m.colorRGBA.z * 255)
                    min: 0
                    max: 255
                    decimals: 0
                    onAccepted: {
                        var colorTmp = Qt.vector4d( m.colorRGBA.x,
                                                    m.colorRGBA.y,
                                                    boxValue / 255,
                                                    colorHSVA.w) ;
                        colorHSVA = rgba2hsva(colorTmp)
                        root.accepted()
                    }
                }
                NumberBox {
                    id: rgbAlpha
                    caption: "A"
                    value: Math.round(m.colorRGBA.w * 255)
                    min: 0
                    max: 255
                    decimals: 0
                    onAccepted: {
                        root.colorHSVA.w = boxValue / 255
                        root.accepted()
                    }
                }
            }
        }
    }
}
