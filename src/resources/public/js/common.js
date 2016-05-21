var HARBORVIEW = HARBORVIEW || {};

HARBORVIEW.Utils = (function () {
    var onError = function (xhr, status) {
        alert(status);
    }
    var myAjax = function (myType, myDataType, myUrl, args, onSuccess) {
        $.ajax({
            url: myUrl,
            type: myType,
            dataType: myDataType,
            data: args,
            success: function (result) {
                console.log(result);
                onSuccess(result);
            },
            error: onError
        });
    }
    var htmlPUT = function (myUrl, args, onSuccess) {
        myAjax("PUT", "html", myUrl, args, onSuccess);
    }
    var htmlGET = function (myUrl, args, onSuccess) {
        myAjax("GET", "html", myUrl, args, onSuccess);
    }
    var jsonGET = function (myUrl, args, onSuccess) {
        myAjax("GET", "json", myUrl, args, onSuccess);
    }
    var jsonPUT = function (myUrl, args, onSuccess) {
        myAjax("PUT", "json", myUrl, args, onSuccess);
    }
    var jsonPOST = function (myUrl, args, onSuccess) {
        myAjax("POST", "json", myUrl, args, onSuccess);
    }
    var createHtmlOption = function(ddl, value, text) {
            var opt = document.createElement('option');
            opt.value = value;
            opt.text = text;
            ddl.options.add(opt);
    }
    return {
        htmlGET: htmlGET,
        htmlPUT: htmlPUT,
        jsonGET: jsonGET,
        jsonPUT: jsonPUT,
        jsonPOST: jsonPOST,
        createHtmlOption : createHtmlOption
    }
})();

/*
var DragDrop = new function () {
    this.allowDrop = function (ev) {
        ev.preventDefault();
    }

    this.drag = function (ev) {
        ev.dataTransfer.setData("text", ev.target.id);
    }

    this.drop = function (ev) {
        ev.preventDefault();
        var data = ev.dataTransfer.getData("text");
        ev.target.appendChild(document.getElementById(data));
        document.getElementById("jax2").innerHTML = data;
        document.getElementById("jax").click();
    }
}();
*/
