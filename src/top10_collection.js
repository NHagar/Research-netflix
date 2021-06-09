
(function(console){

console.save = function(data, filename){

    if(!data) {
        console.error('Console.save: No data')
        return;
    }

    if(!filename) filename = 'console.json'

    if(typeof data === "object"){
        data = JSON.stringify(data, undefined, 4)
    }

    var blob = new Blob([data], {type: 'text/json'}),
        e    = document.createEvent('MouseEvents'),
        a    = document.createElement('a')

    a.download = filename
    a.href = window.URL.createObjectURL(blob)
    a.dataset.downloadurl =  ['text/json', a.download, a.href].join(':')
    e.initMouseEvent('click', true, false, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null)
    a.dispatchEvent(e)
 }
})(console)


var mostwatched = document.querySelector('[data-list-context="mostWatched"]');
var items = mostwatched.getElementsByClassName("slider-item");

var results = [];
var page = document.location['pathname'];
var coll_time = Date.now();

for (i=0;i<items.length;i++) {
    var entry = items[i];
    var link = entry.getElementsByTagName("a")[0];
    var url = link.getAttribute("href");
    var title = link.getAttribute("aria-label");
    var rank_element = entry.getElementsByTagName("svg")[0];
    var rank = rank_element.className['baseVal'].split(" ")[1].split("-").slice(-1)[0];
    var result = {"url": url, 
                  "title": title, 
                  "rank": rank,
                  "collected": coll_time};
    results.push(result);
}


console.save(results, `results_${coll_time}_${page}.json`);