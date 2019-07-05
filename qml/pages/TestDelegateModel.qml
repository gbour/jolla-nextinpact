import QtQuick 2.0
import QtQml.Models 2.1
import Sailfish.Silica 1.0

Page {

    ListModel {
        id: myModel
        ListElement { name: "foo"; count: 42; sec: "aa" }
        ListElement { name: "bar"; count: 31; sec: "aa" }
        ListElement { name: "baz"; count: 1;  sec:"bb" }
    }

    DelegateModel {
        id: myDelegateModel
        property var orig

        delegate: ListItem {
            //anchors.fill: parent
            height: 100

            Row {
                Label {
                    text: "xx " + name
                }
                Label {
                    leftPadding: 10
                    text: count
                }
            }
        }

        model: myModel
        groups: [
            DelegateModelGroup {
                includeByDefault: false
                name: "filters"
            }
        ]
        filterOnGroup: "filters"
        Component.onCompleted: filter(true)

        function filter(first) {

            var rowCount = myModel.rowCount()
            /*var elt = myModel.get(1)
            console.log(rowCount, elt, typeof(elt), Object.keys(elt), elt.name, elt.count)

            // copy items
            var orig = [] //Object.assign({}, items)
            for(var i = 0; i < items.count; i++) {
                console.log(i, items.get(i), items.get(i).model.name, items.get(i).model, Object.keys(items.get(i).model))
                orig.push(items.get(i).model)

            }*/

            var cnt = 3//Math.floor(Math.random()*3)
            console.log('filter', rowCount, items.count, cnt, rootIndex, rootIndex.data)

            /*
            if (!first) {
                if(items.count > 0) {
                    //items.remove(0, items.count)
                    items.removeGroups(0, items.count, ["filters"])
                }
                return
            }
            */


            console.log(myModel.get(0), myModel.get(0).name, Object.keys(myModel.get(0)))
            if(items.count > 0) {
                items.removeGroups(0, items.count, ["filters"])
                    items.remove(0, items.count)
            }

            console.log('l', items.count)
            for(var i = 0; i < cnt; i++) {
                items.insert(myModel.get(i), "filters")
            }
            console.log('m', items.count)

            //console.log(items.count, orig.length)
            /*
            console.log(orig[0].model, myModel.get(0),
                        Object.keys(orig[0].model),
                        Object.keys(myModel.get(0)),
                        orig[0].model.name, myModel.get(0).name
                        )
            */
            //items.insert({'name': 'plop', count: 123}, "filters")


            /*
            orig.forEach(function(itm) {
                console.log('add', itm.name)
                items.insert(itm, "filters")
            })
            */
            /*
            var itm = items.get(1)
            console.log('itm', itm, Object.keys(itm), itm.model, itm.model.name)
            */
            //var itm = orig.get(1)
            //console.log('itm2', itm), Object.keys(itm), itm.model, itm.model.name)
            //console.log(orig, orig.count, orig.get(1).name, items, items.count, items.get(1).name, Object.keys(items))
        }
    }

    SilicaListView {
        id: slv
        anchors.fill: parent
        model: myDelegateModel
        /*
        model: myModel
        delegate: ListItem {
            //anchors.fill: parent
            height: 100

            Row {
                Label {
                    text: "xx " + name
                }
                Label {
                    leftPadding: 10
                    text: count + "," + seck
                }
            }

        }
        */


        section.property: "model.sec"
        section.delegate: SectionHeader {
            text: "sec"
        }



    }
    Component.onCompleted: {
        //read_timer.start()
    }

    Timer {
        id: read_timer
        interval: 2000 // 5 secsQMap<int, QVariant> QAbstractItemModel::itemData(const QModelIndex &index) const
        running: false
        onTriggered: {
            console.log('TIMER')
            myDelegateModel.filter(false)
            //slv.update()
            //slv.forceLayout()

            console.log("slv count:", slv.count)
            /*, slv.data, Object.keys(slv.data), slv.data[0],
                        slv.data[1], slv.data[2])
            console.log(slv.model, slv.resources, slv.resources[0])*/
            //slv.populate()



        }
    }
}


//QMap<int, QVariant> QAbstractItemModel::itemData(const QModelIndex &index) const
