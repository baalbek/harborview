(ns harborview.generaljournal.dbx
  (:import
    [koteriku.beans GeneralJournalBean]
    [koteriku.models.mybatis
      GeneralJournalMapper
      Ns4102Mapper
      InvoiceMapper]
    [koteriku.models KoterikuFacade])
  (:require
    [harborview.service.htmlutils :as U]
    [harborview.service.db :as DB]
    [harborview.service.logservice :as LOG]
    [clj-json.core :as json]))

(def mva_25 0.2)

(def mva_15 (- 1.0 (/ 1.0 1.15)))

(def mva_08 (- 1.0 (/ 1.0 1.08)))

(def frac-debs [6300 6340])

(defn feedback [])

;;;-----------------------------------------------------------------
;;;--------------------------- KO TE RIKU  -------------------------
;;;-----------------------------------------------------------------

(defn fetch-by-bilag []
  (DB/with-session :koteriku GeneralJournalMapper
    (.selectByBilag it 5)))

(defn fetch-by-date []
  (DB/with-session :koteriku GeneralJournalMapper
    (.selectByDate it 1)))

(def fetch-ns4102
  (memoize (fn []
             (DB/with-session :koteriku Ns4102Mapper
               (.selectNs4102 it)))))

(defn insert-generaljournal [^GeneralJournalBean gj ^GeneralJournalBean mva]
  (DB/with-session :koteriku GeneralJournalMapper
    (do
      (if-not (nil? mva)
        (.insertGeneralJournal it mva))
      (.insertGeneralJournal it gj))))

(defn update-voucher [voucher invoicenum]
  (DB/with-session :koteriku InvoiceMapper
    (.updateVoucher it voucher invoicenum)))

(defn insert [bilag curdate credit debit desc amount mva mvaamt]
  (let [bilag  (U/rs bilag)
        credit (U/rs credit)
        debit  (U/rs debit)
        amount (let [tmp (U/rs amount)
                     fact (if (U/in? frac-debs debit) 0.15 1.0)]
                 (* fact tmp))
        mva    (U/rs mva)
        mvaamt (U/rs mvaamt)
        curdate (U/str->date curdate)
        calc-mva (cond
                  (> mvaamt 0) mvaamt
                  (< mva 0) 0.0
                  (= mva 2711) (* mva_25 amount)
                  (= mva 2713) (* mva_15 amount)
                  (= mva 2714) (* mva_08 amount))
        gj-bean (GeneralJournalBean. bilag curdate credit debit desc (- amount calc-mva))
        mva-bean (if (> calc-mva 0.0)
                   (GeneralJournalBean. bilag curdate credit mva desc calc-mva)
                   nil)]
    (LOG/info (str "Bilag: " bilag ", credit: " credit ", debit: " debit
                ", amount: " amount ", mva: " mva ", mvaamt: " mvaamt
                ", curdate: " curdate ", calc-mva: " calc-mva))

    (insert-generaljournal gj-bean mva-bean)
    gj-bean))

(defn insert-invoice [bilag curdate amount invoicenum]
  (let [bilag   (U/rs bilag)
        curdate (U/str->date curdate)
        amount  (U/rs amount)
        income (/ amount 1.25)
        mva (- amount income)
            invoicenumx (U/rs invoicenum)
             ;descx (if (nil? desc) (str "Fakturanr " invoicenumx))
             desc (str "Fakturanr " invoicenumx)
             gj-bean-inc (GeneralJournalBean. bilag curdate 3700 1500 desc income)
             gj-bean-mva (GeneralJournalBean. bilag curdate 2700 1500 desc mva)]
       (LOG/info (str "Invoice num: " invoicenum))
       (insert-generaljournal gj-bean-inc gj-bean-mva)
       (update-voucher bilag invoicenumx)
     gj-bean-inc))
