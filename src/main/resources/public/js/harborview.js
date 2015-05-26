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
    var myAjax = function(
                         myType,
                         myDataType,
                         myUrl,
                         args,
                         onSuccess) {
        $.ajax({
            url: myUrl,
            type: myType,
            dataType: myDataType,
            data: args,
            success: function(result) {
                onSuccess(result);
            },
            error: onError
        });
    };
    var htmlGET = function(myUrl,
                            args,
                            onSuccess) {
        myAjax("GET","html",myUrl,args,onSuccess);
    };
    var jsonGET = function(myUrl,
                            args,
                            onSuccess) {
        myAjax("GET","json",myUrl,args,onSuccess);
    };

    var jsonPUT = function(myUrl,
                            args,
                            onSuccess) {
        myAjax("PUT","json",myUrl,args,onSuccess);
    };
    var jsonPOST = function(myUrl,
                            args,
                            onSuccess) {
        myAjax("POST","json",myUrl,args,onSuccess);
    };
    return {
        addOption : addOption,
        onError : onError,
        relativeTop : relativeTop,
        htmlGET : htmlGET,
        jsonGET : jsonGET,
        jsonPUT : jsonPUT,
        jsonPOST : jsonPOST
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
        HARBORVIEW.utils.jsonPUT("/systems/newsystem",
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
        HARBORVIEW.utils.jsonPUT("/systems/newvinapuelement", args, onSuccess);
    };
    var newVinapuElementLoads = function(args, onSuccess) {
        HARBORVIEW.utils.jsonPUT("/systems/newvinapuelementloads", args, onSuccess);
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
    "use strict";
    var fetchSteelElements = function(sysId, steelElementsArea) {
        HARBORVIEW.utils.htmlGET("/elements/steelelements", { "sysid" : sysId }, function(result) {
            steelElementsArea.html(result);
        });
    };
    var fetchElementSystems = function(bid, fid, dropdown) {
        HARBORVIEW.utils.jsonGET("/elements/elementsystems", { "bid" : bid, "fid" : fid }, function(result) {
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
    var fetchSteelBeams = function(dropdown) {
        if ((dropdown[0]).length > 2) {
            return;
        };
        HARBORVIEW.utils.jsonGET("/elements/steelbeams", null, function(result) {
            var items = result.steelbeams;
            HARBORVIEW.utils.addOption(dropdown, "-", "-1");
            for (var i=0,  itemlen = items.length; i<itemlen; i++) {
                var item = items[i];
                HARBORVIEW.utils.addOption(dropdown,item.text,item.oid);
            }
        });
    };
    var fetchWoodStClass = function(dropdown) {
        if ((dropdown[0]).length > 1) {
            return;
        };
        HARBORVIEW.utils.jsonGET("/elements/woodstclass", null, function(result) {
            var items = result.stclass;
            HARBORVIEW.utils.addOption(dropdown, "-", "-1");
            for (var i=0,  itemlen = items.length; i<itemlen; i++) {
                var item = items[i];
                HARBORVIEW.utils.addOption(dropdown,item.text,item.oid);
            }
        });
    };
    var newSteelElements = function(sysId,
                                    steelBeam,
                                    nodes,
                                    distLoads,
                                    nodeLoads,
                                    nodeLf) {
        HARBORVIEW.utils.jsonPUT("/elements/newsteel",
                                  { "sysid" : sysId,
                                    "steel" : steelBeam,
                                    "nodes" : nodes,
                                    "qloads" : distLoads,
                                    "nloads" : nodeLoads,
                                    "nlf" : nodeLf}, function(result) {
            alert(result.result);
        });
    };
    var newWoodElements = function(args) {
        HARBORVIEW.utils.jsonPUT("/elements/newwood",args,function(result) {
            alert(result.result);
        });
    };
    var newDistLoad = function(args) {
        HARBORVIEW.utils.jsonPUT("/elements/newdistload",
                                 args,
                                 function(result) {
            alert(result.result);
        });
    };
    var fetchDistLoads = function(sysId,dropdowns) {
        HARBORVIEW.utils.jsonGET("/elements/distloads", { "sysid" : sysId }, function(result) {
            var items = result.distloads;
            for (var j=0, jlen = dropdowns.length; j<jlen; j++) {
                var dropdown = dropdowns[j];
                dropdown.empty();
                HARBORVIEW.utils.addOption(dropdown, "-", "-1");
                for (var i=0,  itemlen = items.length; i<itemlen; i++) {
                    var item = items[i];
                    HARBORVIEW.utils.addOption(dropdown,item.text,item.oid);
                };
            };
        });
    };
    return {
        fetchElementSystems : fetchElementSystems,
        fetchSteelBeams : fetchSteelBeams,
        newSteelElements : newSteelElements,
        newWoodElements : newWoodElements,
        newDistLoad : newDistLoad,
        fetchDistLoads : fetchDistLoads,
        fetchSteelElements : fetchSteelElements,
        fetchWoodStClass : fetchWoodStClass
    };
})();

HARBORVIEW.buildings = (function() {
    "use strict";
    var fetchBuildings = function(pid, buildingsDropDown) {
        if (pid === "-1") return;
        HARBORVIEW.utils.jsonGET("/systems/fetchbuildings",
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
    "use strict";
    var fetchVinapuDeadLoads = function(loadsDropDown) {
        HARBORVIEW.utils.jsonGET("/loads/vinapudeadloads",
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
        HARBORVIEW.utils.jsonGET("/loads/vinapuliveloads",
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
    "use strict";
    var fillNodeDropdowns = function(result,nodeDropdowns) {
        var objs = result.nodes;
        for (var j=0, nlen=nodeDropdowns.length; j<nlen; j++) {
            var cur = nodeDropdowns[j];
            cur.empty();
            HARBORVIEW.utils.addOption(cur, "-", "-1");
        }
        for (var i=0, oblen = objs.length; i<oblen; i++) {
            var item = objs[i];
            for (var j=0, nlen=nodeDropdowns.length; j<nlen; j++) {
                HARBORVIEW.utils.addOption(nodeDropdowns[j],item.text,item.oid);
            }
        }
    };
    var fetchNodes = function(pid, cosyid, nodes) {
        HARBORVIEW.utils.jsonGET("/nodes/nodes",
                                { "pid" : pid, "cosyid" : cosyid },
                                function(result) {
            fillNodeDropdowns(result,nodes);
        });
    };
    var fetchSystemNodes = function(sysId, nodes) {
        HARBORVIEW.utils.jsonGET("/nodes/systemnodes",
                                { "sysid" : sysId },
                                function(result) {
            fillNodeDropdowns(result,nodes);
        });
    };
    var fetchSystemNodes2 = function(sysId, cosyid, nodes) {
        HARBORVIEW.utils.jsonGET("/nodes/systemnodes2",
                                { "sysid" : sysId,
                                  "cosyid" : cosyid },
                                function(result) {
            fillNodeDropdowns(result,nodes);
        });
    };

    return {
        fetchNodes : fetchNodes,
        fetchSystemNodes : fetchSystemNodes,
        fetchSystemNodes2 : fetchSystemNodes2
    };
})();
