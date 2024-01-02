//  A toy QML colorpicker control, by Ruslan Shestopalyuk
import QtQuick 2.11
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.4

Rectangle {
    id: colorPicker
    property color colorValue: "transparent"
    property bool enableAlphaChannel: true
    property bool enableDetails: true
    property int colorHandleRadius : 8
    property bool paletteMode : false
    property bool enablePaletteMode : false
    property string switchToColorPickerString: "Palette..."
    property string switchToPalleteString: "Color Picker..."

    property color _changingColorValue : paletteMode ?
                                   _rgb(paletts.paletts_color, alphaSlider.value) :
                                   _hsla(hueSlider.value, sbPicker.saturation,
                                    sbPicker.brightness, alphaSlider.value)
    on_ChangingColorValueChanged: {
        colorValue = _changingColorValue
    }

    signal colorChanged(color changedColor)

    implicitWidth: picker.implicitWidth
    implicitHeight: palette_switch.implicitHeight + picker.implicitHeight
    color: "#3C3C3C"
    clip: true

    Text {
        id: palette_switch
        textFormat: Text.StyledText
        text: paletteMode ?
                  "<a href=\".\">" + switchToColorPickerString + "</a>" :
                  "<a href=\".\">" + switchToPalleteString + "</a>"
        visible: enablePaletteMode
        onLinkActivated: {
            paletteMode = !paletteMode
        }
        anchors.right: parent.right
        anchors.rightMargin: colorHandleRadius
        linkColor: "white"
    }

    RowLayout {
        id: picker
        anchors.top: enablePaletteMode　? palette_switch.bottom : parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: colorHandleRadius
        anchors.bottom: parent.bottom
        spacing: 0

        SwipeView {
            id: swipe
            clip: true
            interactive: false
            currentIndex: paletteMode ? 1 : 0

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: paletts.implicitWidth
            Layout.minimumHeight: paletts.implicitHeight

            SBPicker {
                id: sbPicker

                hueColor: {
                    var v = 1.0-hueSlider.value
                    console.debug("v:"+v)

                    if(0.0 <= v && v < 0.16) {
                        return Qt.rgba(1.0, 0.0, v/0.16, 1.0)
                    } else if(0.16 <= v && v < 0.33) {
                        return Qt.rgba(1.0 - (v-0.16)/0.17, 0.0, 1.0, 1.0)
                    } else if(0.33 <= v && v < 0.5) {
                        return Qt.rgba(0.0, ((v-0.33)/0.17), 1.0, 1.0)
                    } else if(0.5 <= v && v < 0.76) {
                        return Qt.rgba(0.0, 1.0, 1.0 - (v-0.5)/0.26, 1.0)
                    } else if(0.76 <= v && v < 0.85) {
                        return Qt.rgba((v-0.76)/0.09, 1.0, 0.0, 1.0)
                    } else if(0.85 <= v && v <= 1.0) {
                        return Qt.rgba(1.0, 1.0 - (v-0.85)/0.15, 0.0, 1.0)
                    } else {
                        console.log("hue value is outside of expected boundaries of [0, 1]")
                        return "red"
                    }
                }
            }

            Palettes {
                id: paletts
            }
        }

        // hue picking slider
        Item {
            id: huePicker
            visible: !paletteMode
            width: 12
            Layout.fillHeight: true
            Layout.topMargin: colorHandleRadius
            Layout.bottomMargin: colorHandleRadius

            Rectangle {
                anchors.fill: parent
                id: colorBar
                gradient: Gradient {
                    GradientStop { position: 1.0;  color: "#FF0000" }
                    GradientStop { position: 0.85; color: "#FFFF00" }
                    GradientStop { position: 0.76; color: "#00FF00" }
                    GradientStop { position: 0.5;  color: "#00FFFF" }
                    GradientStop { position: 0.33; color: "#0000FF" }
                    GradientStop { position: 0.16; color: "#FF00FF" }
                    GradientStop { position: 0.0;  color: "#FF0000" }
                }
            }
            ColorSlider {
                id: hueSlider; anchors.fill: parent
            }
        }

        // alpha (transparency) picking slider
        Item {
            id: alphaPicker
            visible: enableAlphaChannel
            width: 12
            Layout.leftMargin: 4
            Layout.fillHeight: true
            Layout.topMargin: colorHandleRadius
            Layout.bottomMargin: colorHandleRadius
            Checkerboard { cellSide: 4 }
            //  alpha intensity gradient background
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#FF000000" }
                    GradientStop { position: 1.0; color: "#00000000" }
                }
            }
            ColorSlider {
                id: alphaSlider; anchors.fill: parent
            }
        }

        // details column
        Column {
            id: detailColumn
            Layout.leftMargin: 4
            Layout.fillHeight: true
            Layout.topMargin: colorHandleRadius
            Layout.bottomMargin: colorHandleRadius
            Layout.alignment: Qt.AlignRight
            visible: enableDetails

            // current color/alpha display rectangle
            PanelBorder {
                width: parent.width
                height: 30
                visible: enableAlphaChannel
                Checkerboard { cellSide: 5 }
                Rectangle {
                    width: parent.width; height: 30
                    border.width: 1; border.color: "black"
                    color: colorPicker.colorValue
                }
            }

            // "#XXXXXXXX" color value box
            PanelBorder {
                id: colorEditBox
                height: 15; width: parent.width
                TextInput {
                    anchors.fill: parent
                    color: "#AAAAAA"
                    selectionColor: "#FF7777AA"
                    font.pixelSize: 11
                    maximumLength: 9
                    focus: false
                    text: _fullColorString(colorPicker.colorValue, alphaSlider.value)
                    selectByMouse: true
                }
            }

            // H, S, B color values boxes
            Column {
                visible: !paletteMode
                width: parent.width
                NumberBox { caption: "H:"; value: hueSlider.value.toFixed(2) }
                NumberBox { caption: "S:"; value: sbPicker.saturation.toFixed(2) }
                NumberBox { caption: "B:"; value: sbPicker.brightness.toFixed(2) }
            }

            // filler rectangle
            Rectangle {
                width: parent.width; height: 5
                color: "transparent"
            }

            // R, G, B color values boxes
            Column {
                width: parent.width
                NumberBox {
                    caption: "R:"
                    value: _getChannelStr(colorPicker.colorValue, 0)
                    min: 0; max: 255
                }
                NumberBox {
                    caption: "G:"
                    value: _getChannelStr(colorPicker.colorValue, 1)
                    min: 0; max: 255
                }
                NumberBox {
                    caption: "B:"
                    value: _getChannelStr(colorPicker.colorValue, 2)
                    min: 0; max: 255
                }
            }

            // alpha value box
            NumberBox {
                visible: enableAlphaChannel
                caption: "A:"; value: Math.ceil(alphaSlider.value*255)
                min: 0; max: 255
            }
        }
    }

    //  creates color value from hue, saturation, brightness, alpha
    function _hsla(h, s, b, a) {
        var lightness = (2 - s)*b
        var satHSL = s*b/((lightness <= 1) ? lightness : 2 - lightness)
        lightness /= 2

        var c = Qt.hsla(h, satHSL, lightness, a)
        console.log("handle _hsla", c)

        colorChanged(c)

        return c
    }

    // create rgb value
    function _rgb(rgb, a) {

        var c = Qt.rgba(rgb.r, rgb.g, rgb.b, a)
        console.log("handle _rgb", c)
        colorChanged(c)

        return c
    }

    //  creates a full color string from color value and alpha[0..1], e.g. "#FF00FF00"
    function _fullColorString(clr, a) {
        return "#" + ((Math.ceil(a*255) + 256).toString(16).substr(1, 2) + clr.toString().substr(1, 6)).toUpperCase()
    }

    //  extracts integer color channel value [0..255] from color value
    function _getChannelStr(clr, channelIdx) {
        return parseInt(clr.toString().substr(channelIdx*2 + 1, 2), 16)
    }

    // set color from outside
    function setColor(color) {

        // color object
        var c = Qt.tint(color, "transparent")

        console.debug('set_color is called with:'+c)

        // set alpha
        alphaSlider.setValue(c.a)

        // set rgb. Now it's insufficient to update hue related component.
        colorPicker.colorValue = c
    }

    // set color for sbpicker

    function setColorForSBPicker() {
        // r 64 g 125 b 118 a 255
        // 0.48 0.49 0.49 1
        console.log("handle setColorForSBPicker")
//         hueSlider.setValue(0.48)
        // sbPicker.saturation = 0.49
        // sbPicker.brightness = 0.49
//         sbPicker.setPickerCursor(0.49, 0.49)
        // const hsva = rgba2hsva(144/255, 25/255, 25/255, 1)
//        console.log("hsva", hsva)
        const hsba = rgbaToHsba(64, 125, 118, 1)
        console.log("hsba", hsba)
        hueSlider.setValue(hsba[0])
        sbPicker.setPickerCursor(hsba[1], hsba[2])
    }

    // convert rgba to hsba
    function rgbaToHsba(r, g, b, a) {
        r /= 255;
        g /= 255;
        b /= 255;

        const max = Math.max(r, g, b);
        const min = Math.min(r, g, b);
        const delta = max - min;

        let h, s, v, hsb;

        if (delta === 0) {
            h = 0;
        } else if (max === r) {
            h = ((g - b) / delta) % 6;
        } else if (max === g) {
            h = (b - r) / delta + 2;
        } else {
            h = (r - g) / delta + 4;
        }

        h = Math.round(h * 60);
        if (h < 0) {
            h += 360;
        }

        v = max;
        s = delta === 0 ? 0 : delta / v;

        hsb = [h / 360, s, v, a];
        
        return hsb;
    }



}