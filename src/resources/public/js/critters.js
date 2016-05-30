var Critters = new function () {
    "use strict";
    /*------------------ Acc Rule ---------------------*/
    var showNewAccRule = function(critId,purchaseId) {
        Critters.purchaseId = purchaseId;
        Critters.critId = critId;
        $("#acc-header").text("[ " + Critters.purchaseId + " ] Critter Oid: " + Critters.critId);
        Critters.setRuleTypes();
    }
    var onNewAccRuleAjax = function(rule,ruleAmount) {
        HARBORVIEW.Utils.htmlPUT(
            "/critters/addaccrule",
            {cid: Critters.critId, value: ruleAmount, rtyp: rule},
            function(result){
                var critterArea = "#critter-area-".concat(Critters.purchaseId.toString());
                $(critterArea).html(result);
            });
    }
    var onNewAccRule = function(rule,ruleAmount) {
        console.log("critId: " + Critters.critId + ", rule: " + rule + ", rule amount: " + ruleAmount);
        onNewAccRuleAjax(rule,ruleAmount);
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
        HARBORVIEW.Utils.htmlPUT(
            "/critters/adddenyrule",
            {accid: Critters.accId, value: rule_amount, rtyp: rule, hasmem: mem},
            function(result){
                var critterArea = "#critter-area-".concat(Critters.purchaseId.toString());
                $(critterArea).html(result);
            })
        var cancel = document.getElementById("new-dny-cancel");
        cancel.click();
    }
    /*------------------ New Critter ---------------------*/
    /*
    var showNewCritter = function() {
        Critters.setRuleTypes();
    }
    */
    var onNewCritter = function(sellVol,rule,ruleAmount) {
        onNewAccRuleAjax(rule,ruleAmount);
        var cancel = document.getElementById("new-critter-cancel");
        cancel.click();
    }

    var setRuleTypes = function() {
        if (Critters.hasRuleTypes === false) {
            Critters.hasRuleTypes = true;
            HARBORVIEW.Utils.jsonGET("/critters/rtyp",null,function(items) {
                var cb_acc = document.getElementById("acc-rtyp");
                var cb_dny = document.getElementById("dny-rtyp");
                var critter_rtyp =  document.getElementById("critter-acc-rtyp");
                for (var i = 0; i < items.length; i++) {
                    HARBORVIEW.Utils.addHtmlOption(cb_acc,items[i].value,items[i].name);
                    HARBORVIEW.Utils.addHtmlOption(cb_dny,items[i].value,items[i].name);
                    HARBORVIEW.Utils.addHtmlOption(critter_rtyp,items[i].value,items[i].name);
                }
            });
        }
    }
    var setPurchases = function(purchaseType) {
        HARBORVIEW.Utils.jsonGET("/critters/purchases",{ptyp: purchaseType},function(items) {
            var cb = document.getElementById("critter-opx");
            HARBORVIEW.Utils.emptyHtmlOptions(cb);
            HARBORVIEW.Utils.addHtmlOption(cb,"-1","-");
            for (var i = 0; i < items.length; i++) {
                var ci = items[i];
                var o = HARBORVIEW.Utils.createHtmlOption(ci.value,ci.name);
                o.setAttribute("data-remsellvol",ci.rem_sell_vol);
                o.setAttribute("data-totvol",ci.total_vol);
                o.setAttribute("data-price",ci.price);
                o.setAttribute("data-buy",ci.buy);
                o.setAttribute("data-spot",ci.spot);
                cb.options.add(o);
            }
            /*
            for (var i = 0; i < items.length; i++) {
                var curItem = items[i];
                HARBORVIEW.Utils.addHtmlOptionWithAttr(cb,curItem.value,curItem.name,"data-remsellvol",curItem.rem_sell_vol);
            }
            */
        });
    }
    var toggleRule = function(oid,isActive,isAccRule) {
        var url = isAccRule === true ? "/critters/toggleacc" : "/critters/toggledny";
        HARBORVIEW.Utils.jsonPUT("/critters/togglerule",
            {"oid": oid, "isactive": isActive, "isaccrule": isAccRule},
            function(result) {
                /*alert(result.result);*/
        });
    }

    var transferAttribute = function(fromEl,fromAttr,toElementId,toAttr) {
        var sourceVal = fromEl.getAttribute(fromAttr);
        var target = document.getElementById(toElementId);
        target.setAttribute(toAttr,sourceVal);
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
        setRuleTypes: setRuleTypes,
        setPurchases: setPurchases,
        onNewCritter: onNewCritter,
        toggleRule: toggleRule,
        transferAttribute: transferAttribute
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
        var rule = $("#acc-rtyp").val();
        var rule_amount = $("#acc-value").val();
        Critters.onNewAccRule(rule,rule_amount);
    })
    $("body").on("click", "a.newaccrule", function() {
        var critId = $(this).attr("data-critid");
        var purchaseId = $(this).attr("data-puid");
        Critters.showNewAccRule(critId,purchaseId);
        return true;
    })
    $("body").on("change", ".acc-active", function() {
        var oid = $(this).attr("data-oid");
        var isActive = $(this).is(":checked") === true ? "y" : "n";
        /*alert("oid: " + oid + ", isActive: " + isActive);*/
        Critters.toggleRule(oid,isActive,true);
    });
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

    $("body").on("change", ".dny-active", function() {
        var oid = $(this).attr("data-oid");
        var isActive = $(this).is(":checked") === true ? "y" : "n";
        Critters.toggleRule(oid,isActive,false);
    });
    /*------------------ Deny Critter ---------------------*/
    $("body").on("click", "#new-critter-ok", function() {
        var sell_vol = $("#sell-vol").val();
        var rtyp = $("#critter-acc-rtyp").val();
        var rtyp_amount = $("#acc-val").val();
        Critters.onNewCritter(sell_vol);
    })
    $("body").on("click", "a.newcritter", function() {
        Critters.setRuleTypes();
        Critters.setPurchases(11);
        return true;
    })



    $("body").on("change", "#critter-opx", function() {
        var opx = $(this)[0];
        var i = opx.selectedIndex;
        var selOpt = opx.options[i];
        Critters.transferAttribute(selOpt,"data-remsellvol","rem-sell-vol","value");
        Critters.transferAttribute(selOpt,"data-price","price","value");
        Critters.transferAttribute(selOpt,"data-buy","buy","value");
        Critters.transferAttribute(selOpt,"data-spot","spot","value");
        Critters.transferAttribute(selOpt,"data-totvol","total-vol","value");
        Critters.purchaseId = selOpt.getAttribute("value");
        alert(Critters.purchaseId);
        return true;
    });
})


