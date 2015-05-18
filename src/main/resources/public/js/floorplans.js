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
        HARBORVIEW.nodes.fetchNodes(pid,cosyid,[$("#dlg2-n1"),$("#dlg2-n2")]);
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
