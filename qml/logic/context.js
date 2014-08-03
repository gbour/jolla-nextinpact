
var state = {
    'key1': null,
}

function init() {
    console.log("context init");
    state['key1'] = 42;

    console.log('key1=' + state['key1']);
}
