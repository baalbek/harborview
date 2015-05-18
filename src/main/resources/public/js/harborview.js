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

HARBORVIEW.stearnswharf = (function() {
    var fetchElementSystems = function(bid, fid, dropdown) {
        HARBORVIEW.utils.jsonGet("/elements/elementsystems", { "bid" : bid, "fid" : fid }, function(result) {
            var items = result.systems;
            dropdown.empty();
            if (items.length === 0) {
                HARBORVIEW.utils.addOption(dropdown, "No systems", "-1");
            }
            else {
                HARBORVIEW.utils.addOption(dropdown, "-", "-1");
            }
            for (var i=0,  itemlen = items.length; i<itemlen; i++) {
                var item = items[i];
                HARBORVIEW.utils.addOption(dropdown,item.text,item.oid);
            }
        });
    };
    return {
        fetchElementSystems : fetchElementSystems
    }
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
    var fillNodeDropdowns = function(result,nodeDropdowns) {
        var objs = result.nodes;
        for (var j=0, nlen=nodeDropdowns.length; j<nlen; j++) {
            nodeDropdowns[j].empty();
        }
        for (var i=0, oblen = objs.length; i<oblen; i++) {
            var item = objs[i];
            /*
            HARBORVIEW.utils.addOption(n1,item.text,item.oid);
            HARBORVIEW.utils.addOption(n2,item.text,item.oid);
            */
            for (var j=0, nlen=nodeDropdowns.length; j<nlen; j++) {
                HARBORVIEW.utils.addOption(nodeDropdowns[j],item.text,item.oid);
            }
        }
    };
    var fetchNodes = function(pid, cosyid, nodes) {
        HARBORVIEW.utils.jsonGet("/nodes/nodes",
                                { "pid" : pid, "cosyid" : cosyid },
                                function(result) {
            fillNodeDropdowns(result,nodes);
        });
        /*
        $.ajax({
            url: "/nodes/nodes",
            type: "GET",
            dataType: "json",
            data: {
                "pid" : pid,
                "cosyid" : cosyid
            },
            success: function(result) {
                fillNodeDropdowns(result,n1,n2);
            },
            error: HARBORVIEW.utils.onError
        });
        */
    };
    var fetchSystemNodes = function(sysId, nodes) {
        HARBORVIEW.utils.jsonGet("/nodes/systemnodes",
                                { "sysid" : sysId },
                                function(result) {
            fillNodeDropdowns(result,nodes);
        });
    };

    return {
        fetchNodes : fetchNodes,
        fetchSystemNodes : fetchSystemNodes
    };
})();
