var HARBORVIEW = HARBORVIEW || {};

HARBORVIEW.Utils = (function () {
    var onError = function (xhr, status) {
        alert("Ajax error: " + status);
    }
    var myAjax = function (myType, myDataType, myUrl, args, onSuccess) {
        $.ajax({
            url: myUrl,
            type: myType,
            dataType: myDataType,
            data: args,
            success: function (result) {
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
    var createHtmlOption = function(value, text) {
        var opt = document.createElement('option');
        opt.value = value;
        opt.text = text;
        return opt;
    }
    var addHtmlOption = function(ddl, value, text) {
        ddl.options.add(createHtmlOption(value,text));
    }
    var addHtmlOptionWithAttr = function(ddl, value, text, attr, attrVal) {
        var opt = createHtmlOption(value,text);
        opt.setAttribute(attr, attrVal);
        ddl.options.add(opt);
    }
    var emptyHtmlOptions = function(cb) {
        while (cb.options.length) {
          // remove the first and repeat
          cb.remove(0);
        }
    }
    return {
        htmlGET: htmlGET,
        htmlPUT: htmlPUT,
        jsonGET: jsonGET,
        jsonPUT: jsonPUT,
        jsonPOST: jsonPOST,
        addHtmlOption: addHtmlOption,
        addHtmlOptionWithAttr: addHtmlOptionWithAttr,
        emptyHtmlOptions: emptyHtmlOptions,
        createHtmlOption: createHtmlOption
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
