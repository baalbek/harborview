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
    var jsonGet = function(myUrl,
                            args,
                            onSuccess) {
        $.ajax({
            url: myUrl,
            type: "GET",
            dataType: "json",
            data: args,
            success: function(result) {
                onSuccess(result);
            },
            error: onError
        });
    };
    var jsonPut = function(myUrl,
                            args,
                            onSuccess) {
        $.ajax({
            url: myUrl,
            type: "PUT",
            dataType: "json",
            data: args,
            success: function(result) {
                onSuccess(result);
            },
            error: onError
        });
    };
    return {
        addOption : addOption,
        onError : onError,
        relativeTop : relativeTop,
        jsonGet : jsonGet,
        jsonPut : jsonPut
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
    var newSystem = function(pid, bid, fid, sd, gid, onSuccess) {
        if (pid < 0) {
            alert("Project id must be set!");
            return;
        }
        if (bid < 0) {
            alert("Building must be set!");
            return;
        }
        if ((fid === "na") || (fid == "all")) {
            alert("Floor must be set!");
            return;
        }
        HARBORVIEW.utils.jsonPut("/systems/newsystem",
                                    {
                                        "pid" : pid,
                                        "bid" : bid,
                                        "fid" : fid,
                                        "sd"  : sd,
                                        "gid" : gid
                                    },
                                    onSuccess);
    };
    var newVinapuElement = function(args, onSuccess) {
        HARBORVIEW.utils.jsonPut("/systems/newvinapuelement", args, onSuccess);
    };
    var newVinapuElementLoads = function(args, onSuccess) {
        HARBORVIEW.utils.jsonPut("/systems/newvinapuelementloads", args, onSuccess);
    };
    return {
        fetchFloorPlanSystems : fetchFloorPlanSystems,
        fetchAllFloorPlanSystems : fetchAllFloorPlanSystems,
        newSystem : newSystem,
        newVinapuElement : newVinapuElement,
        newVinapuElementLoads : newVinapuElementLoads
    };
})();

HARBORVIEW.buildings = (function() {

    var fetchBuildings = function(pid, buildingsDropDown) {
        if (pid === "-1") return;
        HARBORVIEW.utils.jsonGet("/systems/fetchbuildings",
                                  { "pid" : pid },
                                  function(result) {
                                    var objs = result.buildings;
                                    buildingsDropDown.empty();
                                    if (objs.length === 0) {
                                        HARBORVIEW.utils.addOption(buildingsDropDown, "No buildings", "-1");
                                    }
                                    else {
                                        HARBORVIEW.utils.addOption(buildingsDropDown, "-", "-1");
                                    }
                                    for (var i=0, oblen = objs.length; i<oblen; i++) {
                                        var item = objs[i];
                                        HARBORVIEW.utils.addOption(buildingsDropDown,item.text,item.oid);
                                    }
                                  });
    };
    return {
        fetchBuildings : fetchBuildings
    };
})();

HARBORVIEW.loads = (function() {
    var fetchVinapuDeadLoads = function(loadsDropDown) {
        HARBORVIEW.utils.jsonGet("/loads/vinapudeadloads",
                                 null,
                                function(result) {
                                    var objs = result.loads;
                                    loadsDropDown.empty();
                                    /*if (canBeNull === true) {
                                        HARBORVIEW.utils.addOption(loadsDropDown, "-", "-1");
                                    };*/
                                    HARBORVIEW.utils.addOption(loadsDropDown, "-", "-1");
                                    for (var i=0, oblen = objs.length; i<oblen; i++) {
                                        var item = objs[i];
                                        HARBORVIEW.utils.addOption(loadsDropDown,item.text,item.oid);
                                    }
                                });
    };
    var fetchVinapuLiveLoads = function(loadsDropDown) {
        HARBORVIEW.utils.jsonGet("/loads/vinapuliveloads",
                                 null,
                                function(result) {
                                    var objs = result.loads;
                                    loadsDropDown.empty();
                                    HARBORVIEW.utils.addOption(loadsDropDown, "-", "-1");
                                    for (var i=0, oblen = objs.length; i<oblen; i++) {
                                        var item = objs[i];
                                        HARBORVIEW.utils.addOption(loadsDropDown,item.text,item.oid);
                                    }
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
        HARBORVIEW.floorplans.newSystem(pid,bid,fid,sd,gid, function(result) {
            fetchFloorPlans();
        });
        return false;
    });
    $("#dlg1-close").click(function() {
        dlg1.close();
        return false;
    });
    $("#shownewsystem").click(function() {
        var elem = $(this)[0];
        var relTop = HARBORVIEW.utils.relativeTop(elem);
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
        HARBORVIEW.floorplans.newVinapuElement(args, function(result) {
            fetchFloorPlans();
        });
        resetAndCloseDlg2();
        return false;
    });
    $("#dlg2-coordsys").change(function() {
        var cosyid = $("#dlg2-coordsys").val();
        var pid = $("#project").val();
        HARBORVIEW.nodes.fetchNodes(pid,cosyid,$("#dlg2-n1"),$("#dlg2-n2"));
    });
    //-------------------------------------- dlg3 --------------------------------
    $("#dlg3-close").click(function() {
        dlg3.close();
        return false;
    });
    $("#dlg3-ok").click(function() {
        var args = {
            "oid"   : $("#dlg3-oid").val(),
            "dload" : $("#dlg3-deadloads").val(),
            "dff"   : $("#dlg3-dff").val(),
            "lload" : $("#dlg3-liveloads").val(),
            "lff"   : $("#dlg3-lff").val()
            };
        dlg3.close();
        HARBORVIEW.floorplans.newVinapuElementLoads(args, function(result) {
            fetchFloorPlans();
        });
        return false;
    });
    //-------------------------------------- body.on("click") --------------------------------
    $("body").on("click", ".shownewvinapuelload", function() {
        var elem = $(this)[0];
        var relTop = HARBORVIEW.utils.relativeTop(elem) - 100;
        dlg3.style.top = "" + relTop  + "px";
        var oid = $(this).attr("data-oid");
        $("#dlg3-oid").val(oid);
        $("#dlg3-header").html("Vinapu element id: " + oid);
        HARBORVIEW.loads.fetchVinapuDeadLoads($("#dlg3-deadloads"));
        HARBORVIEW.loads.fetchVinapuLiveLoads($("#dlg3-liveloads"));
        dlg3.show();
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
