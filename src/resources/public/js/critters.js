var Critters = new function () {
    "use strict";
    /*
    this.showNewAccRule = function (oid, purchaseId, items) {
        $("#acc_header").html("[ " + purchaseId + " ] Critter Oid: " + oid);
        $("#acc_pu_oid").val(purchaseId);
        $("#acc_crit_oid").val(oid);
        if (items) {
            var cb = document.getElementById("acc_rtyp");

            for (var i = 0; i < items.length; i++) {
                Critters.createOption(cb,items[i].value,items[i].name);
            }
        };
        $("#newaccruledlg").show();
        $("#newaccruledlg").dialog("open");
    }
    this.showNewDenyRule = function (oid, purchaseId, items) {
        $("#dny_header").html("[ " + purchaseId + " ] Accept Oid: " + oid);
        $("#dny_pu_oid").val(purchaseId);
        $("#dny_acc_oid").val(oid);
        if (items) {
            var cb = document.getElementById("dny_rtyp");

            for (var i = 0; i < items.length; i++) {
                Critters.createOption(cb,items[i].value,items[i].name);
            }
        };
        $("#newdnyruledlg").show();
        $("#newdnyruledlg").dialog("open");
    }
    this.createOption = function(ddl, value, text) {
            var opt = document.createElement('option');
            opt.value = value;
            opt.text = text;
            ddl.options.add(opt);
    }
    this.accValInit = false;
    this.dnyValInit = false;
    this.onError = function(XMLHttpRequest, textStatus, errorThrown) {
        alert(textStatus)
        alert(errorThrown)
    }
    */
    var showNewAccRule = function(critId,purchaseId) {
        Critters.purchaseId = purchaseId;
        Critters.critId = critId;
        $("#acc-header").text("[ " + Critters.purchaseId + " ] Critter Oid: " + Critters.critId);
        Critters.setRuleTypes();
    }
    var onNewAccRule = function() {
        var rule = $("#acc-rtyp").val();
        var rule_amount = $("#acc-value").val();

        HARBORVIEW.Utils.jsonPUT(
            "/critters/addaccrule",
            {cid: Critters.critId, value: rule_amount, rtyp: rule},
            function(result){
                var critterArea = "#critter-area-".concat(Critters.purchaseId.toString());
                $(critterArea).html(result.result);
            })
        var cancel = document.getElementById("new-acc-cancel");
        cancel.click();
    }
    var setRuleTypes = function() {
        if (Critters.hasRuleTypes === false) {
            Critters.hasRuleTypes = true;
            HARBORVIEW.Utils.jsonGET("/critters/rtyp",null,function(items) {
                var cb = document.getElementById("acc-rtyp");
                for (var i = 0; i < items.length; i++) {
                    HARBORVIEW.Utils.createHtmlOption(cb,items[i].value,items[i].name);
                }
            })
        }
    }
    return {
        showNewAccRule: showNewAccRule,
        onNewAccRule: onNewAccRule,
        critId: undefined,
        purchaseId: undefined,
        hasRuleTypes: false,
        setRuleTypes: setRuleTypes
    }
}()

jQuery(document).ready(function() {
    $("body").on("click", "#new-acc-ok", function() {
        Critters.onNewAccRule();
    })
    $("body").on("click", "a.newaccrule", function() {
        var critId = $(this).attr("data-critid");
        var purchaseId = $(this).attr("data-puid");
        Critters.showNewAccRule(critId,purchaseId);
        return true;
    })
    $("body").on("click", "a.newdenyrule", function() {
        var accId = $(this).attr("data-accid");
        var purchaseId = $(this).attr("data-puid");

    })
    /*
    $("#newaccruledlg").dialog({ height: 350,
        width: 600,
        modal: true,
        position: "center",
        autoOpen:false,
        title:"New Acc Rule",
        overlay: { opacity: 0.5, background: "black"},
        buttons: {
            "Ok": function() {
                var oid   = $("#acc_crit_oid").val();
                var purchaseId = $("#acc_pu_oid").val();
                var rtyp  = $("#acc_rtyp").val();
                var value = $("#acc_val").val();
                $.ajax({
                    url: "/critters/addaccrule",
                    type: "PUT",
                    dataType: "json",
                    data: {
                        "cid": oid,
                        "value": value,
                        "rtyp": rtyp
                    },
                    success: function(result) {
                        var critterArea = "#critter-area-".concat(purchaseId.toString());
                        $(critterArea).html(result.result);
                    },
                    error: Critters.onError
                })
                $(this).dialog("close");
            },
            "Cancel": function() {
                $(this).dialog("close");
            }
        }
    })
    //$(".newaccrule").click(function() {
    $("body").on("click", "a.newaccrule", function() {
        var critId = $(this).attr("data-critid");
        var purchaseId = $(this).attr("data-puid");
        if (Critters.accValInit == false) {
            $.ajax({
                url: "/critters/rtyp",
                type: "GET",
                dataType: "json",
                success: function(result) {
                    Critters.accValInit = true;
                    Critters.showNewAccRule(critId, purchaseId, result);
                },
                error: Critters.onError
            })
        }
        else {
            Critters.showNewAccRule(critId, purchaseId, null);
        }
        return false;
    })
    $("#newdnyruledlg").dialog({ height: 350,
        width: 600,
        modal: true,
        position: "center",
        autoOpen:false,
        title:"New Deny Rule",
        overlay: { opacity: 0.5, background: "black"},
        buttons: {
            "Ok": function() {
                var oid        = $("#dny_acc_oid").val();
                var purchaseId = $("#dny_pu_oid").val();
                var value      = $("#dny_val").val();
                var rtyp       = $("#dny_rtyp").val();
                var mem        = $("#hasmemory").is(":checked") ? "y" : "n";
                alert("Oid: " + oid + ", puid: " + purchaseId + ", value: " + value + ", rtyp: " + rtyp + ", mem: " + mem);

                $.ajax({
                    url: "/critters/adddenyrule",
                    type: "PUT",
                    dataType: "json",
                    data: {
                        "accid": oid,
                        "value": value,
                        "rtyp": rtyp,
                        "hasmem": mem
                    },
                    success: function(result) {
                        var critterArea = "#critter-area-".concat(purchaseId.toString());
                        $(critterArea).html(result.result);
                    },
                    error: Critters.onError
                })
                $(this).dialog("close");
            },
            "Cancel": function() {
                $(this).dialog("close");
            }
        }
    })
    $("body").on("click", "a.newdenyrule", function() {
        var accId = $(this).attr("data-accid");
        var purchaseId = $(this).attr("data-puid");
        if (Critters.dnyValInit == false) {
            $.ajax({
                url: "/critters/rtyp",
                type: "GET",
                dataType: "json",
                success: function(result) {
                    Critters.dnyValInit = true;
                    Critters.showNewDenyRule(accId, purchaseId, result);
                },
                error: Critters.onError
            })
        }
        else {
            Critters.showNewDenyRule(accId, purchaseId, null);
        }
        return false;
    })
    */
})


