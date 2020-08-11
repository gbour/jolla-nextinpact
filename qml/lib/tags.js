/*
    Copyright 2020 Guillaume Bour.
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
.pragma library

var COLORS = {
    "culture-numerique": "#89571c",
    "droit": "#e74f4f",
    "economie": "#b1b1b1",
    "internet": "#00c1e8",
    "logiciel": "#167dac",
    "mobilite": "#af67b1",
    "tech": "#1cc38a",
    "next-inpact": "#ea8212",
}

// tags translations
QT_TRANSLATE_NOOP("Tags", "culture-numerique")
QT_TRANSLATE_NOOP("Tags", "droit")
QT_TRANSLATE_NOOP("Tags", "economie")
QT_TRANSLATE_NOOP("Tags", "internet")
QT_TRANSLATE_NOOP("Tags", "logiciel")
QT_TRANSLATE_NOOP("Tags", "mobilite")
QT_TRANSLATE_NOOP("Tags", "tech")
QT_TRANSLATE_NOOP("Tags", "next-inpact")

function color(tag) {
    var c = COLORS[tag];
    if (c === undefined) {
        return "#fff"; // white
    }

    return c;
}

/*
    'Foo Bar' -> foo-bar'
*/
function normalize(raw) {
    var tag = raw.toLowerCase().replace(/\s+/g, '-')
    tag = tag.replace(/é/g, 'e')

    return tag
}
