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
    var relativeTop = function(elem) {
        var r = elem.getBoundingClientRect();
        var body = document.body;
        var docElem = document.documentElement;
        var scrollTop = window.pageYOffset || docElem.scrollTop || body.scrollTop;
        var clientTop = docElem.clientTop || body.clientTop || 0;
        return r.top +  scrollTop - clientTop;
    };
    return {
        fetchBuildings : fetchBuildings,
        fetchFloorPlans : fetchFloorPlans,
        addOption : addOption,
        relativeTop : relativeTop
    };
})();


jQuery(document).ready(function() {
    var dlg1 = document.querySelector("#dlg1");
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
    $("#dlg1-ok").click(function() {
        alert($("#dlg1-purchasetype").val());
        dlg1.close();
        return false;
    });
    $("#dlg1-close").click(function() {
        dlg1.close();
        return false;
    });
    $("#shownewsystem").click(function() {
        var elem = $(this)[0];
        var relTop = HARBORVIEW.utils.relativeTop(elem) - 50;
        dlg1.style.top = "" + relTop  + "px";
        /*var oid = $(this).attr("data-oid");*/
        var pid = $("#projects").val();
        var bid = $("#buildings").val();
        $("#dlg1-header").html("Prosjekt: " + pid + ", bygg: " + bid);
        /*$("#dlg1-oid").val(oid);*/
        dlg1.show();
        return false;
    });
})
