var HARBORVIEW = HARBORVIEW || {};

HARBORVIEW.utils = (function() {
    var fetchBuildings = function(pid, buildingsDropDown) {
        if (pid === "-1") return;
        $.ajax({
            url: "/systems/fetchbuildings",
            type: "GET",
            dataType: "json",
            data: {
                "pid" : pid
            },
            success: function(result) {
                var objs = result.result;
                buildingsDropDown.empty();
                addOption(buildingsDropDown, "-1", "-");
                for (var i=0; i<objs.length;i++) {
                    var item = objs[i];
                    addOption(buildingsDropDown,item.val,item.oid);
                }
            },
            error: function(XMLHttpRequest, textStatus, errorThrown) {
                alert(textStatus)
                alert(errorThrown)
            }
        });
    };
    var addOption = function(selectbox,text,value ) {
        /*
        var optn = document.createElement("OPTION");
        optn.text = text;
        optn.value = value;
        selectbox.options.add(optn);
        */
        selectbox.append($('<option></option>').val(value).html(text));
    };
    return {
        fetchBuildings : fetchBuildings,
        addOption : addOption
    };
    var onError = function(XMLHttpRequest, textStatus, errorThrown) {
        alert(textStatus)
        alert(errorThrown)
    };
})();


jQuery(document).ready(function() {
    $("#buildings").change(function() {
        alert('hi');
    });
    $("#projects").change(function() {
        var pid = $("#projects").val();
        HARBORVIEW.utils.fetchBuildings(pid,$("#buildings"));
    });
})
