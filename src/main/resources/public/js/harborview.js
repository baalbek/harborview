var HARBORVIEW = HARBORVIEW || {};

HARBORVIEW.utils = (function() {
    "use strict";
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
        addOption : addOption,
        onError : onError,
        relativeTop : relativeTop
    };
})();

HARBORVIEW.floorplans = (function() {
    "use strict";
    var myFetch = function(myUrl, args, fps) {
        $.ajax({
            url: myUrl,
            type: "GET",
            dataType: "html",
            data: args,
            success: function(result) {
                fps.html(result);
            },
            error: HARBORVIEW.utils.onError
        });
    };
    var fetchFloorPlanSystems = function(bid, fid, floorplanSystemElement) {
        if (bid === "-1") return;
        myFetch("/systems/fetchfloorplansystems", { "bid" : bid, "fid" : fid }, floorplanSystemElement);
    };
    var fetchAllFloorPlanSystems = function(bid, floorplanSystemElement) {
        if (bid === "-1") return;
        myFetch("/systems/fetchfloorplans", { "bid" : bid }, floorplanSystemElement);
    };
    var newSystem = function(pid, bid, fid, sd, gid) {
        // alert("Pid: " + pid + ", bid: " + bid + ", fid: " + fid + ", sd: " + sd + ", gid: " + gid);
        $.ajax({
            url: "/systems/newsystem",
            type: "PUT",
            dataType: "json",
            data: {
                "pid" : pid,
                "bid" : pid,
                "fid" : fid,
                "sd"  : sd,
                "gid" : gid
            },
            success: function(result) {
                // alert("Updated with new system: " + result.oid);
            },
            error: HARBORVIEW.utils.onError
        });
    };
    var newVinapuElement = function(args) {
        //oid | sys_id |    dsc     | n1 | n2 | plw | w1  | w2 | angle | element_type | wnode
        $.ajax({
            url: "/systems/newvinapuelement",
            type: "PUT",
            dataType: "json",
            data : args,
            success: function(result) {
                alert("Updated with new vinapu element: " + result.oid);
            },
            error: HARBORVIEW.utils.onError
        });
    };
    return {
        fetchFloorPlanSystems : fetchFloorPlanSystems,
        fetchAllFloorPlanSystems : fetchAllFloorPlanSystems,
        newSystem : newSystem,
        newVinapuElement : newVinapuElement
    };
})();

HARBORVIEW.buildings = (function() {

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
                    HARBORVIEW.utils.addOption(buildingsDropDown, "-1", "No buildings");
                }
                else {
                    HARBORVIEW.utils.addOption(buildingsDropDown, "-1", "-");
                }
                for (var i=0, oblen = objs.length; i<oblen; i++) {
                    var item = objs[i];
                    HARBORVIEW.utils.addOption(buildingsDropDown,item.text,item.oid);
                }
            },
            error: HARBORVIEW.utils.onError
        });
    };
    return {
        fetchBuildings : fetchBuildings
    };
})();

HARBORVIEW.loads = (function() {
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
                    HARBORVIEW.utils.addOption(loadsDropDown,item.text,item.oid);
                }
            },
            error: HARBORVIEW.utils.onError
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
                HARBORVIEW.utils.addOption(loadsDropDown, "-", "-1");
                for (var i=0, oblen = objs.length; i<oblen; i++) {
                    var item = objs[i];
                    HARBORVIEW.utils.addOption(loadsDropDown,item.text,item.oid);
                }
            },
            error: HARBORVIEW.utils.onError
        });
    };
    return {
        fetchVinapuDeadLoads : fetchVinapuDeadLoads,
        fetchVinapuLiveLoads : fetchVinapuLiveLoads
    };
})();

HARBORVIEW.nodes = (function() {
    var fetchNodes = function(pid, cosyid, n1, n2) {
        $.ajax({
            url: "/nodes/nodes",
            type: "GET",
            dataType: "json",
            data: {
                "pid" : pid,
                "cosyid" : cosyid
            },
            success: function(result) {
                var objs = result.nodes;
                n1.empty();
                n2.empty();
                for (var i=0, oblen = objs.length; i<oblen; i++) {
                    var item = objs[i];
                    HARBORVIEW.utils.addOption(n1,item.text,item.oid);
                    HARBORVIEW.utils.addOption(n2,item.text,item.oid);
                }
            },
            error: HARBORVIEW.utils.onError
        });
    };

    return {
        fetchNodes : fetchNodes
    };
})();

jQuery(document).ready(function() {
    var dlg1 = document.querySelector("#dlg1");
    var dlg2 = document.querySelector("#dlg2");
    var fetchFloorPlans = function() {
        var fid = $("#floorplan").val();
        if (fid == "na") return false;
        var bid = $("#building").val();
        if (fid == "all") {
            HARBORVIEW.floorplans.fetchAllFloorPlanSystems(bid,$("#floorplansystems"));
        }
        else {
            HARBORVIEW.floorplans.fetchFloorPlanSystems(bid,fid,$("#floorplansystems"));
        }
    };
    $("#floorplan").change(function() {
        fetchFloorPlans();
    });
    $("#building").change(function() {
        fetchFloorPlans();
    });
    $("#project").change(function() {
        var pid = $("#project").val();
        HARBORVIEW.buildings.fetchBuildings(pid,$("#building"));
    });
    //-------------------------------------- dlg1 --------------------------------
    $("#dlg1-ok").click(function() {
        dlg1.close();
        var pid = $("#project").val();
        var bid = $("#building").val();
        var fid = $("#floorplan").val();
        var sd  = $("#dlg1-sd").val();
        var gid = $("#dlg1-group").val();
        HARBORVIEW.floorplans.newSystem(pid,bid,fid,sd,gid);
        fetchFloorPlans();
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
        var pid = $("#project").val();
        var bid = $("#building").val();
        var fid = $("#floorplan").val();
        $("#dlg1-header").html("Prosjekt: " + pid + ", bygg: " + bid + ", floor plan: " + fid);
        dlg1.show();
        return false;
    });
    //-------------------------------------- dlg2 --------------------------------
    var resetAndCloseDlg2 = function() {
        dlg2.close();
        $("#dlg2-n1").empty();
        $("#dlg2-n2").empty();
        $("#dlg2-coordsys").val("-1");
    };
    $("#dlg2-close").click(function() {
        resetAndCloseDlg2();
        return false;
    });
    $("#dlg2-ok").click(function() {
        //oid | sys_id |    dsc     | n1 | n2 | plw | w1  | w2 | angle | element_type | wnode
        var args = {
            "sys"   : $("#dlg2-sys").val(),
            "dsc"   : $("#dlg2-dsc").val(),
            "n1"    : $("#dlg2-n1").val(),
            "n2"    : $("#dlg2-n2").val(),
            "plw"   : $("#dlg2-plw").val(),
            "w1"    : $("#dlg2-w1").val(),
            "dload" : $("#dlg2-deadloads").val(),
            "dff"   : $("#dlg2-dff").val(),
            "lload" : $("#dlg2-liveloads").val(),
            "lff"   : $("#dlg2-lff").val()
            };
        HARBORVIEW.floorplans.newVinapuElement(args);
        resetAndCloseDlg2();
        fetchFloorPlans();
        return false;
    });
    $("#dlg2-coordsys").change(function() {
        var cosyid = $("#dlg2-coordsys").val();
        var pid = $("#project").val();
        HARBORVIEW.nodes.fetchNodes(pid,cosyid,$("#dlg2-n1"),$("#dlg2-n2"));
    });
    $("body").on("click", ".shownewvinapuelement", function() {
        var elem = $(this)[0];
        var relTop = HARBORVIEW.utils.relativeTop(elem) - 50;
        dlg2.style.top = "" + relTop  + "px";
        var oid = $(this).attr("data-oid");
        $("#dlg2-sys").val(oid);
        $("#dlg2-header").html("System id: " + oid);
        HARBORVIEW.loads.fetchVinapuDeadLoads($("#dlg2-deadloads"));
        HARBORVIEW.loads.fetchVinapuLiveLoads($("#dlg2-liveloads"));
        dlg2.show();
        return false;
    });
})
