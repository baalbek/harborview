var GeneralJournal = new function() {
    this.insert = function() {
        $.ajax({
            url: "/generaljournal/insert",
            type: "PUT",
            dataType: "json",
            data: { "debit"   : $("#debit").val(),
                    "credit"  : $("#credit").val(),
                    "curdate" : $("#curdate").val(),
                    "bilag"   : $("#bilag").val(),
                    "desc"    : $("#desc").val(),
                    "amount"  : $("#amount").val(),
                    "mvaamt"  : $("#mvaamt").val(),
                    "mva"     : $("#mva").val()
                    },
            success: this.onSuccess,
            error: this.onError
        })
    }
    this.insertInvoice = function() {
        $.ajax({
            url: "/generaljournal/insertinvoice",
            type: "PUT",
            dataType: "json",
            data: {
                    "curdate" : $("#curdate").val(),
                    "bilag"   : $("#bilag").val(),
                    "amount"  : $("#amount").val(),
                    "invoicenum"  : $("#invoicenum").val(),
            },
            success: this.onSuccess,
            error: this.onError
        })
    }
    this.onSuccess = function(result) {
        if ($("#incbilag").is(':checked')) {
            $("#bilag").val(result.nextreceipt);
        }
        //$("#feedback").html("<p>Last bean id: " + result.beanId + "</p>")
        //$("#feedback").html(result.lastreceipts);
    },
    this.onError = function(XMLHttpRequest, textStatus, errorThrown) {
        alert(textStatus)
        alert(errorThrown)
    }
    /*
    this.setNs4102 = function() {
        if (GeneralJournal.hasNs4102 == false) {
            GeneralJournal.hasNs4102 == true;
            HARBORVIEW.Utils.jsonGET("/generaljournal/rtyp",null,function(items) {
                var cb_acc = document.getElementById("acc-rtyp");
                var cb_dny = document.getElementById("dny-rtyp");

        }
    }
    this.hasNs4102 = false;
    //*/
}()


jQuery(document).ready(function() {
    $("#insertkassadagbok").click(function() {
        GeneralJournal.insert();
        return false;
    })
    $("#insertinvoice").click(function() {
        GeneralJournal.insertInvoice();
        return false;
    })
    $("#preset").click(function() {
        var tpl_id = $("#preset").val();
        $("#mvaamt").val('0.0');
        switch (tpl_id) {
            case '1':
                $("#credit").val('1902');
                $("#debit").val('7140');
                $("#mva").val('-1');
                $("#desc").val('Taxi');
                break;
            case '2':
                $("#credit").val('1902');
                $("#debit").val('6581');
                $("#mva").val('2711');
                $("#desc").val('Datautstyr');
                break;
            case '3':
                $("#credit").val('1902');
                $("#debit").val('6910');
                $("#mva").val('2711');
                $("#desc").val('NextGenTel');
                break;
            case '4':
                $("#credit").val('1902');
                $("#debit").val('6900');
                $("#mva").val('2711');
                $("#desc").val('NetCom');
                break;
            case '5':
                $("#credit").val('1902');
                $("#debit").val('6900');
                $("#mva").val('2711');
                $("#desc").val('Telenor');
                break;
            case '6':
                $("#credit").val('1902');
                $("#debit").val('6300');
                $("#mva").val('-1');
                $("#desc").val('OBOS');
                break;
            case '7':
                $("#credit").val('1902');
                $("#debit").val('6340');
                $("#mva").val('-1');
                $("#desc").val('Hafslund');
                break;
            case '8':
                $("#credit").val('1902');
                $("#debit").val('7160');
                $("#mva").val('-1');
                $("#desc").val('Lunsj');
                break;
            case '9':
                $("#credit").val('1902');
                $("#debit").val('7160');
                $("#mva").val('-1');
                $("#desc").val('Overtidsmat');
                break;
            case '10':
                $("#credit").val('1902');
                $("#debit").val('7140');
                $("#mva").val('-1');
                $("#desc").val('Ruter mnd kort');
                break;
            default:
                $("#credit").val('na');
                $("#debit").val('na');
                $("#mva").val('-1');
                $("#desc").val('');
        }
    })
})
