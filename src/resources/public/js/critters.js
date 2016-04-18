var Critters = new function () {
    "use strict";
    /*------------------ Acc Rule ---------------------*/
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
    /*------------------ Deny Rule ---------------------*/
    var showNewDenyRule = function(accId,purchaseId) {
        Critters.purchaseId = purchaseId;
        Critters.accId = accId;
        $("#dny-header").text("[ " + Critters.purchaseId + " ] Acc. Rule Oid: " + Critters.accId);
        Critters.setRuleTypes();
    }
    var onNewDenyRule = function() {
        var rule        = $("#dny-rtyp").val();
        var rule_amount = $("#dny-value").val();
        var mem         = $("#dny-mem").is(":checked") ? "y" : "n";
        HARBORVIEW.Utils.jsonPUT(
            "/critters/adddenyrule",
            {accid: Critters.accId, value: rule_amount, rtyp: rule, hasmem: mem},
            function(result){
                var critterArea = "#critter-area-".concat(Critters.purchaseId.toString());
                $(critterArea).html(result.result);
            })
        var cancel = document.getElementById("new-dny-cancel");
        cancel.click();
    }
    /*------------------ New Critter ---------------------*/
    var showNewDenyRule = function() {

    }

    var setRuleTypes = function() {
        if (Critters.hasRuleTypes === false) {
            Critters.hasRuleTypes = true;
            HARBORVIEW.Utils.jsonGET("/critters/rtyp",null,function(items) {
                var cb_acc = document.getElementById("acc-rtyp");
                var cb_dny = document.getElementById("dny-rtyp");
                for (var i = 0; i < items.length; i++) {
                    HARBORVIEW.Utils.createHtmlOption(cb_acc,items[i].value,items[i].name);
                    HARBORVIEW.Utils.createHtmlOption(cb_dny,items[i].value,items[i].name);
                }
            })
        }
    }
    return {
        showNewAccRule: showNewAccRule,
        onNewAccRule: onNewAccRule,
        showNewDenyRule: showNewDenyRule,
        onNewDenyRule: onNewDenyRule,
        critId: undefined,
        purchaseId: undefined,
        accId: undefined,
        hasRuleTypes: false,
        setRuleTypes: setRuleTypes
    }
}()

jQuery(document).ready(function() {
    /*------------------ Acc Rule ---------------------*/
    var toggleValue2 = function(rtypId,val2id,lbl2id) {
        var selectedRtyp = $(rtypId).val();
        var lbl2 = document.getElementById(lbl2id);
        var val2= document.getElementById(val2id);

        if (selectedRtyp === "9") {
            lbl2.style.display = "block";
            val2.style.display = "block";
        }
        else {
            lbl2.style.display = "none";
            val2.style.display = "none";
        }
    }
    $("body").on("click", "#acc-rtyp", function() {
        toggleValue2("#acc-rtyp","acc-value-2","acc-lbl-2");
    })
    $("body").on("click", "#dny-rtyp", function() {
        toggleValue2("#dny-rtyp","dny-value-2","dny-lbl-2");
    })
    $("body").on("click", "#new-acc-ok", function() {
        Critters.onNewAccRule();
    })
    $("body").on("click", "a.newaccrule", function() {
        var critId = $(this).attr("data-critid");
        var purchaseId = $(this).attr("data-puid");
        Critters.showNewAccRule(critId,purchaseId);
        return true;
    })
    /*------------------ Deny Rule ---------------------*/
    $("body").on("click", "#new-dny-ok", function() {
        Critters.onNewDenyRule();
    })
    $("body").on("click", "a.newdenyrule", function() {
        var accId = $(this).attr("data-accid");
        var purchaseId = $(this).attr("data-puid");
        Critters.showNewDenyRule(accId,purchaseId);
        return true;
    })
    /*------------------ Deny Critter ---------------------*/
    $("body").on("click", "#new-critter", function() {
    })

})


