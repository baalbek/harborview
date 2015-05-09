var HARBORVIEW = HARBORVIEW || {};

HARBORVIEW.utils = (function() {
    "use strict";
    var fetchFloorPlanSystems = function(bid, fid, floorplanSystemElement) {
        if (bid === "-1") return;
        $.ajax({
            url: "/systems/fetchfloorplansystems",
            type: "GET",
            dataType: "html",
            data: {
                "bid" : bid,
                "fid" : fid
            },
            success: function(result) {
                floorplanSystemElement.html(result);
            },
            error: onError
        });
    };
    /*
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
    //*/
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
    var getLeftPos = function(elem) {
        var r = elem.getBoundingClientRect();
        return r.left;
    };
    return {
        fetchBuildings : fetchBuildings,
        fetchFloorPlanSystems : fetchFloorPlanSystems,
        addOption : addOption,
        relativeTop : relativeTop,
        getLeftPos : getLeftPos
    };
})();


jQuery(document).ready(function() {
    var dlg1 = document.querySelector("#dlg1");
    /*
    $("body").on("click", ".jax", function() {
        alert('YES!!!');
    });
    */
    $("#floorplan").change(function() {
        var bid = $("#building").val();
        var fid = $("#floorplan").val();
        HARBORVIEW.utils.fetchFloorPlanSystems(bid,fid,$("#floorplansystems"));
    });
    $("#building").change(function() {
        var fid = $("#floorplan").val();
        if (fid != "na")
        {
            var bid = $("#building").val();
            HARBORVIEW.utils.fetchFloorPlanSystems(bid,fid,$("#floorplansystems"));
        }
        /*HARBORVIEW.utils.fetchFloorPlans(bid,$("#floorplansystems"));*/
    });
    $("#project").change(function() {
        var pid = $("#project").val();
        HARBORVIEW.utils.fetchBuildings(pid,$("#building"));
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
        dlg1.style.left = "" + HARBORVIEW.utils.getLeftPos(elem) + "px";
        /*var oid = $(this).attr("data-oid");*/
        var pid = $("#project").val();
        var bid = $("#building").val();
        $("#dlg1-header").html("Prosjekt: " + pid + ", bygg: " + bid);
        /*$("#dlg1-oid").val(oid);*/
        dlg1.show();
        return false;
    });
})
