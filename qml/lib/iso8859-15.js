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

// from https://github.com/mathiasbynens/iso-8859-15/blob/master/data/index-by-pointer.json
var _tablemap = {
    '#39': "'",
    '#128': "\u0080",
    '#129': "\u0081",
    '#130': "\u0082",
    '#131': "\u0083",
    '#132': "\u0084",
    '#133': "\u0085",
    '#134': "\u0086",
    '#135': "\u0087",
    '#136': "\u0088",
    '#137': "\u0089",
    '#138': "\u008A",
    '#139': "\u008B",
    '#140': "\u008C",
    '#141': "\u008D",
    '#142': "\u008E",
    '#143': "\u008F",
    '#144': "\u0090",
    '#145': "\u0091",
    '#146': "\u0092",
    '#147': "\u0093",
    '#148': "\u0094",
    '#149': "\u0095",
    '#150': "\u0096",
    '#151': "\u0097",
    '#152': "\u0098",
    '#153': "\u0099",
    '#154': "\u009A",
    '#155': "\u009B",
    '#156': "\u009C",
    '#157': "\u009D",
    '#158': "\u009E",
    '#159': "\u009F",
    '#160': "\u00A0",
    '#161': "\u00A1",
    '#162': "\u00A2",
    '#163': "\u00A3",
    '#164': "\u20AC",
    '#165': "\u00A5",
    '#166': "\u0160",
    '#167': "\u00A7",
    '#168': "\u0161",
    '#169': "\u00A9",
    '#170': "\u00AA",
    '#171': "\u00AB",
    '#172': "\u00AC",
    '#173': "\u00AD",
    '#174': "\u00AE",
    '#175': "\u00AF",
    '#176': "\u00B0",
    '#177': "\u00B1",
    '#178': "\u00B2",
    '#179': "\u00B3",
    '#180': "\u017D",
    '#181': "\u00B5",
    '#182': "\u00B6",
    '#183': "\u00B7",
    '#184': "\u017E",
    '#185': "\u00B9",
    '#186': "\u00BA",
    '#187': "\u00BB",
    '#188': "\u0152",
    '#189': "\u0153",
    '#190': "\u0178",
    '#191': "\u00BF",
    '#192': "\u00C0",
    '#193': "\u00C1",
    '#194': "\u00C2",
    '#195': "\u00C3",
    '#196': "\u00C4",
    '#197': "\u00C5",
    '#198': "\u00C6",
    '#199': "\u00C7",
    '#200': "\u00C8",
    '#201': "\u00C9",
    '#202': "\u00CA",
    '#203': "\u00CB",
    '#204': "\u00CC",
    '#205': "\u00CD",
    '#206': "\u00CE",
    '#207': "\u00CF",
    '#208': "\u00D0",
    '#209': "\u00D1",
    '#210': "\u00D2",
    '#211': "\u00D3",
    '#212': "\u00D4",
    '#213': "\u00D5",
    '#214': "\u00D6",
    '#215': "\u00D7",
    '#216': "\u00D8",
    '#217': "\u00D9",
    '#218': "\u00DA",
    '#219': "\u00DB",
    '#220': "\u00DC",
    '#221': "\u00DD",
    '#222': "\u00DE",
    '#223': "\u00DF",
    '#224': "\u00E0",
    '#225': "\u00E1",
    '#226': "\u00E2",
    '#227': "\u00E3",
    '#228': "\u00E4",
    '#229': "\u00E5",
    '#230': "\u00E6",
    '#231': "\u00E7",
    '#232': "\u00E8",
    '#233': "\u00E9",
    '#234': "\u00EA",
    '#235': "\u00EB",
    '#236': "\u00EC",
    '#237': "\u00ED",
    '#238': "\u00EE",
    '#239': "\u00EF",
    '#240': "\u00F0",
    '#241': "\u00F1",
    '#242': "\u00F2",
    '#243': "\u00F3",
    '#244': "\u00F4",
    '#245': "\u00F5",
    '#246': "\u00F6",
    '#247': "\u00F7",
    '#248': "\u00F8",
    '#249': "\u00F9",
    '#250': "\u00FA",
    '#251': "\u00FB",
    '#252': "\u00FC",
    '#253': "\u00FD",
    '#254': "\u00FE",
    '#255': "\u00FF",

    'amp': "&",
    'quot': "\"",
    'nbsp': " "
};

// stage2 table map
// we want to replace those character sequences only if target field
// is not able to render HTML codes (eg not a RichText field)
var _tablemap2 = {
    'lt': "<",
    'gt': ">"
}


function iso_map(text, stage2) {
    var regex = /&([^;]+);/g;
    var stage2 = (typeof stage2 !== 'undefined' ? stage2 : true);

    return text.replace(regex, function(match, icode, rest, unary) {
        if (icode in _tablemap) {
            return _tablemap[icode];
        }

        if (stage2 && icode in _tablemap2) {
            return _tablemap2[icode]
        }

        return '&'+icode+';';
    });
}
