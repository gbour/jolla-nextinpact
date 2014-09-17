/*
    This file is part of «NextINpact app».

    «NextINpact app» is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    any later version.

    «NextINpact app» is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with «NextINpact app».  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: about

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height
        contentWidth: column.width

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column


            PageHeader {
                title: qsTr("About «NextINpact»")
            }

            Label {
                x: Theme.paddingLarge
                width: about.width - 2*Theme.paddingLarge

                text: qsTr("
                    version %1, released at %2.<br/>
                    <br/>
                    The NextINpact Jolla application is developped by <a href=\"http://guillaume.bour.cc\">Guillaume Bour</a>, </br>
                    and distributed under GPLv3 license.<br/>
                    You are welcome to download source code at <a href=\"https://github.com/gbour/jolla-nextinpact\">github.com/gbour/jolla-nextinpact</a> and contribute.
                    <br/><br/>
                    Articles and their contents displayed in this application; as NextINpact logo; are the entire property of <b>PC INpact SARL de presse</b>.<br/>
                    If you like it, please <a href=\"http://www.nextinpact.com/abonnement?utm_source=pcinpact&utm_medium=header&utm_campaign=premium\">subscribe to a member/premium account</a>."
                    ).arg(APP_VERSION).arg(Date().toLocaleString(Qt.locale()))
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeMedium
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignJustify

                onLinkActivated: Qt.openUrlExternally(link)
            }
        }
    }
}
