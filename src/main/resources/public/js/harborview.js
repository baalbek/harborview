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
    var fetchAllFloorPlanSystems = function(bid, floorplansElement) {
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
    var fetchVinapuDeadLoads = function(loadsDropDown) {
        $.ajax({
            url: "/loads/vinapudeadloads",
            type: "GET",
            dataType: "json",
            success: function(result) {
                var objs = result.loads;
                loadsDropDown.empty();
                for (var i=0, oblen = objs.length; i<oblen; i++) {
                    var item = objs[i];
                    addOption(loadsDropDown,item.text,item.oid);
                }
            },
            error: onError
        });
    };
    var fetchVinapuLiveLoads = function(loadsDropDown) {
        $.ajax({
            url: "/loads/vinapuliveloads",
            type: "GET",
            dataType: "json",
            success: function(result) {
                var objs = result.loads;
                loadsDropDown.empty();
                for (var i=0, oblen = objs.length; i<oblen; i++) {
                    var item = objs[i];
                    addOption(loadsDropDown,item.text,item.oid);
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
        fetchAllFloorPlanSystems : fetchAllFloorPlanSystems,
        fetchVinapuDeadLoads : fetchVinapuDeadLoads,
        fetchVinapuLiveLoads : fetchVinapuLiveLoads,
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
        var fid = $("#floorplan").val();
        if (fid == "na") return false;
        var bid = $("#building").val();
        if (fid == "all") {
            HARBORVIEW.utils.fetchAllFloorPlanSystems(bid,$("#floorplansystems"));
        }
        else {
            HARBORVIEW.utils.fetchFloorPlanSystems(bid,fid,$("#floorplansystems"));
        }
    });
    $("#building").change(function() {
        var fid = $("#floorplan").val();
        if (fid == "na") return false;
        var bid = $("#building").val();
        if (fid == "all") {
            HARBORVIEW.utils.fetchAllFloorPlanSystems(bid,$("#floorplansystems"));
        }
        else {
            HARBORVIEW.utils.fetchFloorPlanSystems(bid,fid,$("#floorplansystems"));
        }
    });
    $("#project").change(function() {
        var pid = $("#project").val();
        HARBORVIEW.utils.fetchBuildings(pid,$("#building"));
    });
    $("#dlg1-ok").click(function() {
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
        /* dlg1.style.left = "" + HARBORVIEW.utils.getLeftPos(elem) + "px"; */
        var pid = $("#project").val();
        var bid = $("#building").val();
        var fid = $("#floorplan").val();
        $("#dlg1-header").html("Prosjekt: " + pid + ", bygg: " + bid + ", floor plan: " + fid);
        HARBORVIEW.utils.fetchVinapuDeadLoads($("#dlg1-deadloads"));
        HARBORVIEW.utils.fetchVinapuLiveLoads($("#dlg1-liveloads"));
        dlg1.show();
        return false;
    });
    $("body").on("click", ".shownewvinapuelement", function() {
        alert('YES!!!');
        return false;
    });
})
