var HARBORVIEW = HARBORVIEW || {};

HARBORVIEW.utils = (function() {
    "use strict";
    var fetchFloorPlans = function(bid, floorplansElement) {
        if (bid === "-1") return;
        $.ajax({
            url: "/systems/fetchfloorplans",
            type: "GET",
            dataType: "html",
            data: {
                "bid" : bid
            },
            success: function(result) {
                floorplansElement.html(result);
            },
            error: onError
        });
    };
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
                var objs = result.buildings;
                buildingsDropDown.empty();
                if (objs.length === 0) {
                    addOption(buildingsDropDown, "-1", "No buildings");
                }
                else {
                    addOption(buildingsDropDown, "-1", "-");
                }
                for (var i=0, oblen = objs.length; i<oblen; i++) {
                    var item = objs[i];
                    addOption(buildingsDropDown,item.text,item.oid);
                }
            },
            error: onError
        });
    };
    var addOption = function(selectbox,text,value ) {
        selectbox.append($('<option></option>').val(value).html(text));
    };
    var onError = function(XMLHttpRequest, textStatus, errorThrown) {
        alert(textStatus)
        alert(errorThrown)
    };
    return {
        fetchBuildings : fetchBuildings,
        fetchFloorPlans : fetchFloorPlans,
        addOption : addOption
    };
})();


jQuery(document).ready(function() {
    $("body").on("click", ".jax", function() {
        alert('YES!!!');
    });
    $("#buildings").change(function() {
        var bid = $("#buildings").val();
        HARBORVIEW.utils.fetchFloorPlans(bid,$("#floorplans"));
    });
    $("#projects").change(function() {
        var pid = $("#projects").val();
        HARBORVIEW.utils.fetchBuildings(pid,$("#buildings"));
    });
})
