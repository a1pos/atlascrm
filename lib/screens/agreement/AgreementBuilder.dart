import 'dart:async';
import 'dart:developer';
import 'package:atlascrm/components/agreement/Pricing.dart';
import 'package:atlascrm/components/shared/CenteredLoadingSpinner.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/services/UserService.dart';
import 'package:atlascrm/components/agreement/Documents.dart';
import 'package:atlascrm/components/agreement/OwnerInfo.dart';
import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/services/ApiService.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:atlascrm/components/agreement/BusinessInfo.dart';
import 'package:atlascrm/components/agreement/SettlementTransact.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class AgreementBuilder extends StatefulWidget {
  final ApiService apiService = new ApiService();

  final String leadId;

  AgreementBuilder(this.leadId);

  @override
  AgreementBuilderState createState() => AgreementBuilderState();
}

Map isDirtyStatus = {};
Map docsAttached = {};
// Map validatorPayload = {
//   "GeneralInfo": [],
//   "BusinessInfo": [],
//   "SiteInfo": [],
//   "MotoBBInet": [],
//   "MpaInfo": [],
//   "CorporateInfo": [],
//   "Ownership": [],
//   "Settlement": [],
//   "Transaction": []
// };
//MpaOutletInfo.Outlet
//--BUSINESS INFO TAB --
final List generalControllerNames = ["corpSame", "motoCheck"];

final List businessInfoControllerNames = [
  "Sic",
  "LocationAddress1",
  "City",
  "State",
  "IrsName",
  "First5Zip",
  "FederalTaxId",
  "ProductsSold",
  "LocationPhone",
  "BusinessCategory",
  "FederalTaxIdType",
  "LocationAddress1",
  "BusinessEmailAddress",
  "ForeignEntityOrNonResidentAlien",
  "BusinessWebsiteAddress",
];

final List siteInfoControllerNames = [
  "Zone",
  "Location",
  "RefundType",
  "NoOfRegister",
  // "RefundPolicy",
  "ReturnPolicy",
  "NoOfEmployees",
  "SquareFootage",
  "NumberOfLevels",
  "SiteVisitation",
  "StoreLocatedOn",
  "DepositRequired",
  "OtherOccupiedBy",
  "RefPolicyRefDays",
  "MerchantNameSiteDisplay"
];

final List motoBBInetControllerNames = [
  "MOTO",
  "CardholderBilling",
  "CCSalesProcessedAt",
  "TransDeliveredIn07",
  "TransDeliveredIn814",
  "TransDeliveredIn1530",
  "TransDeliveredOver30"
];

final List corporateInfoControllerNames = [
  "City",
  "State",
  "Address1",
  "SendCBTo",
  "First5Zip",
  "LegalName",
  "BusinessType",
  "CorporateContact",
  "SendRetRequestTo",
  "BusinessStartDate",
  "StateIncorporated",
  "SendMonthlyStmntTo",
  // "CurrentStmntProvided",
  "StatementHoldRefValue",
  "RetrievalFaxRptCodeRefValue"
];

//--OWNER INFO TAB--
final List ownershipControllerNames = [
  "Prin1Dob",
  "Prin1Ssn",
  "Prin1City",
  "Prin1Phone",
  "Prin1State",
  "Prin1Title",
  "Prin1Address",
  "Prin1LastName",
  "Prin1First5Zip",
  "Prin1FirstName",
  "Prin1EmailAddress",
  "Prin1GuarantorCode",
  "Prin1OwnershipPercent",
  "Prin1DriverLicenseState",
  "Prin1DriverLicenseNumber",
  "Prin2Dob",
  "Prin2Ssn",
  "Prin2City",
  "Prin2Phone",
  "Prin2State",
  "Prin2Title",
  "Prin2Address",
  "Prin2LastName",
  "Prin2First5Zip",
  "Prin2FirstName",
  "Prin2EmailAddress",
  "Prin2GuarantorCode",
  "Prin2OwnershipPercent",
  "Prin2DriverLicenseState",
  "Prin2DriverLicenseNumber",
  "Prin3Dob",
  "Prin3Ssn",
  "Prin3City",
  "Prin3Phone",
  "Prin3State",
  "Prin3Title",
  "Prin3Address",
  "Prin3LastName",
  "Prin3First5Zip",
  "Prin3FirstName",
  "Prin3EmailAddress",
  "Prin3GuarantorCode",
  "Prin3OwnershipPercent",
  "Prin3DriverLicenseState",
  "Prin3DriverLicenseNumber",
  "Prin4Dob",
  "Prin4Ssn",
  "Prin4City",
  "Prin4Phone",
  "Prin4State",
  "Prin4Title",
  "Prin4Address",
  "Prin4LastName",
  "Prin4First5Zip",
  "Prin4FirstName",
  "Prin4EmailAddress",
  "Prin4GuarantorCode",
  "Prin4OwnershipPercent",
  "Prin4DriverLicenseState",
  "Prin4DriverLicenseNumber",
  "Prin5Dob",
  "Prin5Ssn",
  "Prin5City",
  "Prin5Phone",
  "Prin5State",
  "Prin5Title",
  "Prin5Address",
  "Prin5LastName",
  "Prin5First5Zip",
  "Prin5FirstName",
  "Prin5EmailAddress",
  "Prin5GuarantorCode",
  "Prin5OwnershipPercent",
  "Prin5DriverLicenseState",
  "Prin5DriverLicenseNumber",
  "HasAdditionalOwner",
  "NumberOfAdditionalOwner",
];

//SETTLEMENT TRANSACT TAB
final List settlementControllerNames = [
  "AccountType",
  "DepositBankName",
  "TransitABANumber",
  "DepositAccountNumber"
];

final List transactionControllerNames = [
  "SeasonalTo",
  "CcPercentMo",
  "CcPercentTo",
  "CcPercentPos",
  "SeasonalFrom",
  "CcPercentInet",
  "HighestTicket",
  "AvgMcViDiTicket",
  "SeasonalMerchant",
  "AnnualDiSalesVolume",
  "AnnualMcViSalesVolume",
  "TotalAnnualSalesVolume",
  "AnnualAmexOnePointSalesVolume"
];

//PRICING TAB
// final List entitlementControllerNames = [
//   "AmexOption",
//   "AmexFeeClass",
//   "AmexDiscountQual",
//   "AmexInterchangeFeeFlag",
//   "AmexOtherItemRateNotESA"
// ];

final List otherFeesControllerNames = [
  "UserDefinedPricing_GridLevel",
  "UserDefinedPricing_GridValue"
//   "BatchFee",
//   "SaleTranFee",
//   "ACHRejectFee",
//   "RetrievalFee",
//   "ChargebackFee",
//   "ReturnTranFee",
//   "eIDSAccessFee",
//   "EarlyTerminationFee",
//   "MonthlyStatementFee",
//   "MonthlyMinimumProcessingFee"
];

// final List pricingControllerNames = [
//   "AffnRate",
//   "Cu24Rate",
//   "NyceRate",
//   "StarRate",
//   "AccelRate",
//   "PulseRate",
//   "JeanieRate",
//   "ShazamRate",
//   "Star18Rate",
//   "Star21Rate",
//   "GenericRate",
//   "MaestroRate",
//   "BundleOption",
//   "InterlinkRate",
//   "DiscountMethod",
//   "MCDebitFeeClass",
//   "AlaskaOptionRate",
//   // "DiscountCalcFlag" : {
//   //     "attributes": {
//   //         "xsi:nil"
//   //     }
//   // },
//   //TODO FIGURE OUT NESTED CONTROLLERS
//   "MCCreditFeeClass",
//   "AffnVolumePercent",
//   "Cu24VolumePercent",
//   "NyceVolumePercent",
//   "StarVolumePercent",
//   "VisaDebitFeeClass",
//   "AccelVolumePercent",
//   "BundledPricingType",
//   "EnablePinDebitCard",
//   "MCDebitPricingType",
//   "PulseVolumePercent",
//   "VisaCreditFeeClass",
//   "JeanieVolumePercent",
//   "MCCreditPricingType",
//   "ShazamVolumePercent",
//   "Star18VolumePercent",
//   "Star21VolumePercent",
//   "GenericVolumePercent",
//   "MaestroVolumePercent",
//   "VisaDebitPricingType",
//   "DiscoverDebitFeeClass",
//   "PassThruDebitNtwkFees",
//   "VisaCreditPricingType",
//   "DiscoverCreditFeeClass",
//   "InterlinkVolumePercent",
//   "DiscoverDebitPricingType",
//   "AlaskaOptionVolumePercent",
//   "DiscoverCreditPricingType",
//   "MCDebitQualDebit_Discount",
//   "MCCreditQualCredit_Discount",
//   "VisaDebitQualDebit_Discount",
//   "VisaCreditQualCredit_Discount",
//   "DiscoverDebitQualDebit_Discount",
//   "MCDebitRetailInterchangeFeeFlag",
//   "StatementInterchangePrintOption",
//   "MCCreditRetailInterchangeFeeFlag",
//   "DiscoverCreditQualCredit_Discount",
//   "VisaDebitRetailInterchangeFeeFlag",
//   "VisaCreditRetailInterchangeFeeFlag",
//   "DiscoverDebitRetailInterchangeFeeFlag",
//   "DiscoverCreditRetailInterchangeFeeFlag"
// ];
//ApplicationInformation
final List mpaInfoControllerNames = ["ClientDbaName", "NumberOfLocation"];

class AgreementBuilderState extends State<AgreementBuilder>
    with TickerProviderStateMixin {
  var agreementBuilderObj;
  var agreementDocument;

  Map files = {"file1": "", "file2": ""};

  var lead;
  var rateReview;
  var rateReviewSummary;
  var leadDocument;
  var isLoading = true;
  var currentTab = 0;
  var previousTab = 0;
  List owners;
  List<Widget> displayList;
  var validationErrors;
  Map isValidated = {};
  var agreementBuilderStatus;
  bool allStepsComplete = false;
  bool pricingDone = false;
  Map seasonalMerchant = {"seasonalMerchant": false};

  List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];
  ConfettiController _controllerTopCenter;

  void initState() {
    _controllerTopCenter =
        ConfettiController(duration: const Duration(seconds: 1));
    super.initState();
    loadAgreementData(this.widget.leadId);
    loadOwnersData(this.widget.leadId);
    loadRateReview(this.widget.leadId);
  }

  void dispose() {
    _controllerTopCenter.dispose();
    super.dispose();
  }

  Future<void> initDocumentObjects() async {
    setState(() {
      docsAttached = {
        "w9": false,
        "voidedCheck": false,
        "w9Added": false,
        "voidedCheckAdded": false
      };
    });
  }

  Future<void> initStatusObjects() async {
    setState(() {
      isDirtyStatus = {
        "businessInfoIsDirty": false,
        "ownersIsDirty": false,
        "settlementTransactIsDirty": false,
        "documentsIsDirty": false,
      };
    });
  }

  void submitResults(resultObj) async {
    var errorArr = [];
    if (resultObj["Errors"] != null) {
      errorArr = resultObj["Errors"]["MerchantError"];
    } else {
      _controllerTopCenter.play();
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return resultObj == null
            ? CenteredLoadingSpinner()
            : CustomCard(
                title: 'Submission: ${resultObj["Status"]}',
                child: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ConfettiWidget(
                        confettiController: _controllerTopCenter,
                        blastDirection: 0,
                        maxBlastForce: 20,
                        minBlastForce: 8,
                        emissionFrequency: 0.5,
                        numberOfParticles: 5,
                        gravity: .5,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ConfettiWidget(
                        confettiController: _controllerTopCenter,
                        blastDirection: 3.14,
                        maxBlastForce: 20,
                        minBlastForce: 8,
                        emissionFrequency: 0.5,
                        numberOfParticles: 5,
                        gravity: .5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        children: <Widget>[
                          errorArr.length == 0
                              ? Icon(Icons.done, color: Colors.green)
                              : Icon(Icons.error, color: Colors.red),
                          Text("Errors: ${errorArr.length}",
                              style: TextStyle(fontSize: 17))
                        ],
                      ),
                    ),
                    errorArr.length == 0
                        ? Icon(Icons.thumb_up, color: Colors.green, size: 100)
                        : SizedBox(
                            height: 500,
                            child: Scrollbar(
                              child: ListView(
                                // shrinkWrap: true,
                                children: errorArr.map<Widget>((error) {
                                  return Column(
                                    children: <Widget>[
                                      Text("${error["ErrorDescription"]}"),
                                      Divider()
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                    errorArr.length == 0
                        ? Text("Nice! Application submitted")
                        : Container(),
                    FlatButton(
                      child: Text('Close',
                          style: TextStyle(fontSize: 17, color: Colors.green)),
                      onPressed: () {
                        setState(() {
                          Navigator.pop(context);
                        });
                      },
                    ),
                    // FlatButton(
                    //   child: Text('Party',
                    //       style: TextStyle(fontSize: 17, color: Colors.green)),
                    //   onPressed: () {
                    //     _controllerTopCenter.play();
                    //   },
                    // ),
                  ],
                ),
              );
      },
    );
  }

  //Default mask is 30 of any character
  final Map<String, MaskedTextController> _generalControllers =
      Map.fromIterable(generalControllerNames,
          key: (i) => i,
          value: (i) =>
              MaskedTextController(mask: "******************************"));

  final Map<String, MaskedTextController> _businessInfoControllers =
      Map.fromIterable(businessInfoControllerNames,
          key: (i) => i,
          value: (i) =>
              MaskedTextController(mask: "******************************"));

  final Map<String, MaskedTextController> _siteInfoControllers =
      Map.fromIterable(siteInfoControllerNames,
          key: (i) => i,
          value: (i) =>
              MaskedTextController(mask: "******************************"));

  final Map<String, MaskedTextController> _motoBBInetControllers =
      Map.fromIterable(
          motoBBInetControllerNames,
          key: (i) => i,
          value: (i) =>
              MaskedTextController(mask: "******************************"));

  final Map<String, MaskedTextController> _corporateInfoControllers =
      Map.fromIterable(corporateInfoControllerNames,
          key: (i) => i,
          value: (i) =>
              MaskedTextController(mask: "******************************"));

  final Map<String, MaskedTextController> _ownershipControllers =
      Map.fromIterable(ownershipControllerNames,
          key: (i) => i,
          value: (i) =>
              MaskedTextController(mask: "******************************"));

  final Map<String, MaskedTextController> _transactionControllers =
      Map.fromIterable(transactionControllerNames,
          key: (i) => i,
          value: (i) =>
              MaskedTextController(mask: "******************************"));

  final Map<String, MaskedTextController> _settlementControllers =
      Map.fromIterable(
          settlementControllerNames,
          key: (i) => i,
          value: (i) =>
              MaskedTextController(mask: "******************************"));

  // final Map<String, MaskedTextController> _entitlementControllers =
  //     Map.fromIterable(entitlementControllerNames,
  //         key: (i) => i,
  //         value: (i) =>
  //             MaskedTextController(mask: "******************************"));

  final Map<String, MaskedTextController> _otherFeesControllers =
      Map.fromIterable(otherFeesControllerNames,
          key: (i) => i,
          value: (i) =>
              MaskedTextController(mask: "******************************"));

  // final Map<String, MaskedTextController> _pricingControllers =
  //     Map.fromIterable(pricingControllerNames,
  //         key: (i) => i,
  //         value: (i) =>
  //             MaskedTextController(mask: "******************************"));

  final Map<String, MaskedTextController> _mpaInfoControllers =
      Map.fromIterable(mpaInfoControllerNames,
          key: (i) => i,
          value: (i) =>
              MaskedTextController(mask: "******************************"));

  Future<void> loadLeadData(leadId) async {
    var resp = await this
        .widget
        .apiService
        .authGet(context, "/lead/" + this.widget.leadId);

    if (resp.statusCode == 200) {
      var body = resp.data;
      if (body != null) {
        var bodyDecoded = body;

        setState(() {
          lead = bodyDecoded;
          leadDocument = bodyDecoded["document"];
        });
      }
    }
  }

  Future<void> loadAgreementStatus(leadId) async {
    var resp = await this
        .widget
        .apiService
        .authGet(context, "/agreementstatus/lead/" + this.widget.leadId);

    if (resp.statusCode == 200) {
      if (resp.data['agreement_status'] == null) {
        var resp3 = await this.widget.apiService.authPost(
            context,
            "/agreementstatus/" +
                "/lead/" +
                this.widget.leadId +
                "/employee/" +
                UserService.employee.employee,
            null);
        if (resp3 != null) {
          if (resp3.statusCode == 200) {
            Fluttertoast.showToast(
                msg: "Agreement Status Created!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.grey[600],
                textColor: Colors.white,
                fontSize: 16.0);
          }
        } else {
          throw new Error();
        }
      } else {
        agreementBuilderStatus = resp.data;
        if (agreementBuilderStatus["pricing"] != null) {
          if (agreementBuilderStatus["pricing"] == true) {
            setState(() {
              pricingDone = true;
            });
          }
        }
        if (agreementBuilderStatus["w9"] != null &&
            agreementBuilderStatus["voided_check"] != null &&
            agreementBuilderStatus["valid_application"] != null &&
            agreementBuilderStatus["rate_review"] != null &&
            agreementBuilderStatus["pricing"] != null) {
          if (agreementBuilderStatus["w9"] &&
              agreementBuilderStatus["voided_check"] &&
              agreementBuilderStatus["valid_application"] &&
              agreementBuilderStatus["rate_review"] &&
              agreementBuilderStatus["pricing"]) {
            setState(() {
              allStepsComplete = true;
            });
          } else {
            setState(() {
              allStepsComplete = false;
            });
          }
        }
      }
    } else {
      Fluttertoast.showToast(
          msg: "Failed to Load Status!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> loadRateReview(leadId) async {
    var resp = await this
        .widget
        .apiService
        .authGet(context, "/ratereview/lead/" + this.widget.leadId);

    if (resp.statusCode == 200) {
      var body = resp.data;
      if (body != null && body["document"] != null) {
        var bodyDecoded = body;

        setState(() {
          rateReview = bodyDecoded;
          if (rateReview["document"]["summaryPayload"] != null) {
            rateReviewSummary = rateReview["document"]["summaryPayload"];
          } else {
            rateReviewSummary = null;
          }
        });
      }
    }
  }

  Map businessPageControllers = {};
  Map settlementTransactPageControllers = {};

  Future<void> loadControllers() async {
    _generalControllers.forEach((j, k) {
      if (agreementBuilderObj["document"]["$j"] != null) {
        _generalControllers["$j"].text =
            agreementBuilderObj["document"]["$j"].toString();
      }
    });
    //--BUSINESS INFO PAGE
    _businessInfoControllers.forEach((j, k) {
      if (agreementBuilderObj["document"]["ApplicationInformation"]
              ["MpaOutletInfo"]["Outlet"]["BusinessInfo"]["$j"] !=
          null) {
        _businessInfoControllers["$j"].text = agreementBuilderObj["document"]
                    ["ApplicationInformation"]["MpaOutletInfo"]["Outlet"]
                ["BusinessInfo"]["$j"]
            .toString();
      }
    });
    _siteInfoControllers.forEach((j, k) {
      if (agreementBuilderObj["document"]["ApplicationInformation"]
              ["MpaOutletInfo"]["Outlet"]["SiteInfo"]["$j"] !=
          null) {
        _siteInfoControllers["$j"].text = agreementBuilderObj["document"]
                    ["ApplicationInformation"]["MpaOutletInfo"]["Outlet"]
                ["SiteInfo"]["$j"]
            .toString();
      }
    });
    _motoBBInetControllers.forEach((j, k) {
      if (agreementBuilderObj["document"]["ApplicationInformation"]
              ["MpaOutletInfo"]["Outlet"]["MotoBBInet"]["$j"] !=
          null) {
        _motoBBInetControllers["$j"].text = agreementBuilderObj["document"]
                    ["ApplicationInformation"]["MpaOutletInfo"]["Outlet"]
                ["MotoBBInet"]["$j"]
            .toString();
      }
    });
    _mpaInfoControllers.forEach((j, k) {
      if (agreementBuilderObj["document"]["ApplicationInformation"]["MpaInfo"]
              ["$j"] !=
          null) {
        _mpaInfoControllers["$j"].text = agreementBuilderObj["document"]
                ["ApplicationInformation"]["MpaInfo"]["$j"]
            .toString();
      }
    });
    _corporateInfoControllers.forEach((j, k) {
      if (agreementBuilderObj["document"]["ApplicationInformation"]
              ["CorporateInfo"]["$j"] !=
          null) {
        _corporateInfoControllers["$j"].text = agreementBuilderObj["document"]
                ["ApplicationInformation"]["CorporateInfo"]["$j"]
            .toString();
      }
    });
    //--SETTLEMENT/TRANSACT PAGE
    _settlementControllers.forEach((j, k) {
      if (agreementBuilderObj["document"]["ApplicationInformation"]
              ["MpaOutletInfo"]["Outlet"]["Settlement"]["$j"] !=
          null) {
        _settlementControllers["$j"].text = agreementBuilderObj["document"]
                    ["ApplicationInformation"]["MpaOutletInfo"]["Outlet"]
                ["Settlement"]["$j"]
            .toString();
      }
    });
    _transactionControllers.forEach((j, k) {
      if (agreementBuilderObj["document"]["ApplicationInformation"]
              ["MpaOutletInfo"]["Outlet"]["Transaction"]["$j"] !=
          null) {
        _transactionControllers["$j"].text = agreementBuilderObj["document"]
                    ["ApplicationInformation"]["MpaOutletInfo"]["Outlet"]
                ["Transaction"]["$j"]
            .toString();
      }
    });
    //--OTHER FEES
    _otherFeesControllers.forEach((j, k) {
      _otherFeesControllers["$j"].text = agreementBuilderObj["document"]
                  ["ApplicationInformation"]["MpaOutletInfo"]["Outlet"]
              ["OtherFees"]["$j"]
          .toString();
    });

    setState(() {
      businessPageControllers = {
        "general": _generalControllers,
        "businessInfo": _businessInfoControllers,
        "siteInfo": _siteInfoControllers,
        "motoBBInet": _motoBBInetControllers,
        "mpaInfo": _mpaInfoControllers,
        "corporateInfo": _corporateInfoControllers
      };
      settlementTransactPageControllers = {
        "settlement": _settlementControllers,
        "transaction": _transactionControllers,
        "businessInfo": _businessInfoControllers,
        "otherFees": _otherFeesControllers
      };
    });

    // _ownershipControllers.forEach((j, k) {
    //   if (agreementBuilderObj["document"]["ApplicationInformation"]["Ownership"]
    //           ["$j"] !=
    //       null) {
    //     _ownershipControllers["$j"].text = agreementBuilderObj["document"]
    //         ["ApplicationInformation"]["Ownership"]["$j"];
    //   }
    // });
  }

  Future<void> loadOwnersData(leadId) async {
    try {
      var resp = await this
          .widget
          .apiService
          .authGet(context, "/lead/" + this.widget.leadId + "/businessowner");
      if (resp != null) {
        if (resp.statusCode == 200) {
          var ownersArrDecoded = resp.data;
          if (ownersArrDecoded != null) {
            var ownersArr = List.from(ownersArrDecoded);
            if (ownersArr.length > 0) {
              setState(() {
                owners = ownersArr;
              });
            } else {
              setState(() {
                ownersArr = [];
                owners = [];
              });
            }
          }
        }
      }
    } catch (err) {
      log(err);
    }
  }

  Future<void> loadAgreementData(leadId) async {
    initStatusObjects();
    await loadAgreementStatus(this.widget.leadId);

    var resp = await this
        .widget
        .apiService
        .authGet(context, "/lead/" + this.widget.leadId + "/agreementbuilder");

    if (resp.statusCode == 200) {
      var body = resp.data;
      if (body["agreement_builder"] != null) {
        var bodyDecoded = body;
        setState(() {
          agreementBuilderObj = bodyDecoded;
          agreementDocument = bodyDecoded["document"];
        });
        await loadControllers();
        await loadDocuments(agreementBuilderObj["agreement_builder"]);

        setState(() {
          isLoading = false;
        });
      } else {
        await generateAgreement();
      }
    }
  }

  Future<void> submitPayload() async {
    var data = agreementBuilderObj;
    var resp =
        await this.widget.apiService.authPost(context, "/merchant/app", data);

    if (resp.statusCode == 200) {
      Fluttertoast.showToast(
          msg: "SUBMIT!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Failed Submit!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> validatePayload(payload) async {
    var data = payload;
    var resp = await this
        .widget
        .apiService
        .authPost(context, "/merchant/validate", data);

    if (resp.statusCode == 200) {
      setState(() {
        validationErrors = resp.data;
      });
      overallValidate(resp.data);
    } else {
      Fluttertoast.showToast(
          msg: "Failed Validate!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> overallValidate(errorObj) async {
    if (_generalControllers["motoCheck"].text != "true" &&
        errorObj["MotoBBInet"] != null) {
      errorObj.remove('MotoBBInet');
    }
    if (errorObj["CorporateInfo"] != null) {
      if (errorObj["CorporateInfo"]["CurrentStmntProvided"] != null) {
        errorObj["CorporateInfo"].remove('CurrentStmntProvided');
      }
      var corporateErrorEmpty = errorObj["CorporateInfo"].isEmpty;
      if (corporateErrorEmpty == true) {
        errorObj.remove('CorporateInfo');
      }
    }
    if (_generalControllers["corpSame"].text == "true" &&
        errorObj["BusinessInfo"] != null) {
      if (errorObj["BusinessInfo"]["City"] != null) {
        errorObj["BusinessInfo"].remove('LocationAddress1');
        errorObj["BusinessInfo"].remove('City');
        errorObj["BusinessInfo"].remove('State');
        errorObj["BusinessInfo"].remove('First5Zip');
        var businessErrorEmpty = errorObj["BusinessInfo"].isEmpty;
        if (businessErrorEmpty == true) {
          errorObj.remove('BusinessInfo');
        }
      }
    }
    if (errorObj["Ownership"] != null) {
      if (errorObj["Ownership"]["Prin1Ssn"] == "Too Long") {
        errorObj["Ownership"].remove('Prin1Ssn');
      }
      if (errorObj["Ownership"]["Prin2Ssn"] == "Too Long") {
        errorObj["Ownership"].remove('Prin2Ssn');
      }
      if (errorObj["Ownership"]["Prin3Ssn"] == "Too Long") {
        errorObj["Ownership"].remove('Prin3Ssn');
      }
    }
    if (errorObj["Transaction"] != null) {
      if (seasonalMerchant["seasonalMerchant"] == false &&
          errorObj["Transaction"]["SeasonalFrom"] != null &&
          errorObj["Transaction"]["SeasonalTo"] != null) {
        errorObj["Transaction"].remove('SeasonalFrom');
        errorObj["Transaction"].remove('SeasonalTo');
      }
    }
    // if (page == 0) {
    if (errorObj["BusinessInfo"] == null &&
        errorObj["MpaInfo"] == null &&
        errorObj["CorporateInfo"] == null &&
        errorObj["SiteInfo"] == null &&
        errorObj["MotoBBInet"] == null &&
        _mpaInfoControllers["ClientDbaName"].text != "") {
      isValidated["BusinessInfo"] = true;
    } else {
      isValidated["BusinessInfo"] = false;
    }
    // } else if (page == 1) {
    if ((errorObj["Ownership"] == null || errorObj["Ownership"].length == 0)) {
      if (owners.length != 0) {
        if (owners[0]["document"]["PrinFirstName"] != "") {
          isValidated["Ownership"] = true;
        } else {
          isValidated["Ownership"] = false;
        }
      } else {
        isValidated["Ownership"] = false;
      }
    } else {
      isValidated["Ownership"] = false;
    }
    // } else if (page == 2) {
    if (errorObj["Settlement"] == null &&
        (errorObj["Transaction"] == null ||
            errorObj["Transaction"].length == 0) &&
        _settlementControllers["DepositBankName"].text != "") {
      isValidated["SettlementTransact"] = true;
    } else {
      isValidated["SettlementTransact"] = false;
    }

    // } else if (page == 3) {
    if (docsAttached["w9"] == true && docsAttached["voidedCheck"] == true) {
      isValidated["Documents"] = true;
    } else {
      isValidated["Documents"] = false;
    }
    // }
    if (isValidated["BusinessInfo"] == true &&
        isValidated["Ownership"] == true &&
        isValidated["SettlementTransact"] == true &&
        isValidated["Documents"] == true) {
      var resp = await this.widget.apiService.authPut(
          context,
          "/agreementstatus/lead/${this.widget.leadId}/employee/${UserService.employee.employee}",
          [
            {"valid_application": true}
          ]);

      if (resp.statusCode == 200) {
        // Fluttertoast.showToast(
        //     msg: "Valid Application!",
        //     toastLength: Toast.LENGTH_SHORT,
        //     gravity: ToastGravity.BOTTOM,
        //     backgroundColor: Colors.grey[600],
        //     textColor: Colors.white,
        //     fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Missing something!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      var resp = await this.widget.apiService.authPut(
          context,
          "/agreementstatus/lead/${this.widget.leadId}/employee/${UserService.employee.employee}",
          [
            {"valid_application": false}
          ]);

      if (resp.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "Incomplete Application!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Failed Validate!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
    loadAgreementStatus(this.widget.leadId);
  }

  Future<void> generateAgreement() async {
    await loadLeadData(this.widget.leadId);

    agreementBuilderObj = {
      "employee": lead["employee"],
      "lead": lead["lead"],
      "document": {
        "leadDocument": lead["document"],
        "ApplicationInformation": {
          "MpaInfo": {},
          "CorporateInfo": {},
          "MpaOutletInfo": {
            "Outlet": {
              "SiteInfo": {},
              "BusinessInfo": {},
              "MotoBBInet": {},
              "Settlement": {},
              "Transaction": {},
              "Entitlement": {},
              "OtherFees": {
                "MonthlyMinimumProcessingFee": "25.00",
                "MonthlyStatementFee": "5.00",
                "eIDSAccessFee": "10.00",
                "ChargebackFee": "35",
                "RetrievalFee": "25",
                "ReturnTranFee": "0.99",
                "BatchFee": "0.10",
                "EarlyTerminationFee": "0.0",
                "ACHRejectFee": "25.00"
              },
              "Pricing": {
                "BundledPricingType": "1",
                "DiscountMethod": "3",
                "StatementInterchangePrintOption": "1",
                "BundleOption": "0",
                "EnablePinDebitCard": "true",
                "PassThruDebitNtwkFees": "1",
                "GenericRate": "0.20",
                "GenericVolumePercent": "0.99",
                "StarRate": "0.20",
                "StarVolumePercent": "0.99",
                "Star18Rate": "0.20",
                "Star18VolumePercent": "0.99",
                "Star21Rate": "0.20",
                "Star21VolumePercent": "0.99",
                "MaestroRate": "0.20",
                "MaestroVolumePercent": "0.99",
                "InterlinkRate": "0.20",
                "InterlinkVolumePercent": "0.99",
                "NyceRate": "0.20",
                "NyceVolumePercent": "0.99",
                "ShazamRate": "0.20",
                "ShazamVolumePercent": "0.99",
                "PulseRate": "0.20",
                "PulseVolumePercent": "0.99",
                "AccelRate": "0.20",
                "AccelVolumePercent": "0.99",
                "Cu24Rate": "0.20",
                "Cu24VolumePercent": "0.99",
                "AffnRate": "0.20",
                "AffnVolumePercent": "0.99",
                "AlaskaOptionRate": "0.20",
                "AlaskaOptionVolumePercent": "0.99",
                "JeanieRate": "0.20",
                "JeanieVolumePercent": "0.99"
              }
            }
          }
        }
      }
    };
    var agreementId;
    var resp1 = await this
        .widget
        .apiService
        .authPost(context, "/agreementbuilder", agreementBuilderObj);
    if (resp1 != null) {
      if (resp1.statusCode == 200) {
        var body = resp1.data;
        agreementId = body["agreement_builder"];
        Fluttertoast.showToast(
            msg: "Agreement Builder Created!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      throw new Error();
    }

    var resp2 = await this.widget.apiService.authPost(
        context,
        "/agreementbuilder/" +
            agreementId +
            "/employee/" +
            UserService.employee.employee +
            "/document",
        {"null": null});
    if (resp2 != null) {
      if (resp2.statusCode == 200) {
        Fluttertoast.showToast(
            msg: "Agreement Attachment Created!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      throw new Error();
    }

    // var resp3 = await this.widget.apiService.authPost(
    //     context,
    //     "/agreementstatus/" +
    //         "/lead/" +
    //         this.widget.leadId +
    //         "/employee/" +
    //         UserService.employee.employee,
    //     null);
    // if (resp3 != null) {
    //   if (resp3.statusCode == 200) {
    //     Fluttertoast.showToast(
    //         msg: "Agreement Status Created!",
    //         toastLength: Toast.LENGTH_SHORT,
    //         gravity: ToastGravity.BOTTOM,
    //         backgroundColor: Colors.grey[600],
    //         textColor: Colors.white,
    //         fontSize: 16.0);
    //   }
    // } else {
    //   throw new Error();
    // }

    loadAgreementData(this.widget.leadId);
  }

  Future<void> updateAgreement(agreementBuilderId, {isSubmit}) async {
    if (agreementBuilderObj["document"]["agreement_builder"] == null) {
      agreementBuilderObj["document"]["agreement_builder"] = agreementBuilderId;
    }
    if (isDirtyStatus["businessInfoIsDirty"]) {
      await updateBusinessInfo();
    }
    if (isDirtyStatus["ownersIsDirty"]) {
      await updateOwners(isSubmit);
    }
    if (isDirtyStatus["settlementTransactIsDirty"]) {
      await updateSettlementTransact();
    }
    if (isDirtyStatus["documentsIsDirty"]) {
      await updateDocuments(agreementBuilderId);
    }
    if (owners.length > 1) {
      setState(() {
        agreementBuilderObj["document"]["ApplicationInformation"]["Ownership"]
            ["HasAdditionalOwner"] = "true";
        agreementBuilderObj["document"]["ApplicationInformation"]["Ownership"]
            ["NumberOfAdditionalOwner"] = (owners.length - 1).toString();
      });
    }
    var resp = await this.widget.apiService.authPut(
        context,
        "/agreementbuilder/" + agreementBuilderId,
        agreementBuilderObj["document"]);

    if (resp.statusCode == 200) {
      await loadAgreementData(this.widget.leadId);

      Fluttertoast.showToast(
          msg: "Agreement Builder Saved!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: "Failed to Save!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
    await validatePayload(agreementBuilderObj["document"]);

    print("validate errors:");
    print(validationErrors);
  }

  Future<void> updateBusinessInfo() async {
    if (_generalControllers["corpSame"].text == "true") {
      _corporateInfoControllers["SendMonthlyStmntTo"].text = "1";
      _corporateInfoControllers["SendRetRequestTo"].text = "1";
      _corporateInfoControllers["SendCBTo"].text = "1";
      _businessInfoControllers["LocationAddress1"].clear();
      _businessInfoControllers["City"].clear();
      _businessInfoControllers["State"].clear();
      _businessInfoControllers["First5Zip"].clear();
    }

    if (_generalControllers["corpSame"].text == "false") {
      _generalControllers["corpSame"].clear();
      agreementBuilderObj["document"]['corpSame'] = false;
    }
    if (_generalControllers["motoCheck"].text == "false") {
      _generalControllers["motoCheck"].clear();
      agreementBuilderObj["document"]["motoCheck"] = false;
    }
    _generalControllers.forEach((j, k) {
      if (_generalControllers["$j"].text != null &&
          _generalControllers["$j"].text != "") {
        if (j.contains("Phone")) {
          if (agreementBuilderObj["document"]["$j"] != null) {
            agreementBuilderObj["document"]["$j"] = _generalControllers["$j"]
                .text
                .toString()
                .replaceAll(new RegExp('[^0-9]'), '');
          }
        } else {
          agreementBuilderObj["document"]["$j"] =
              _generalControllers["$j"].text.toString();
        }
      }
    });

    _businessInfoControllers.forEach((j, k) {
      if (_businessInfoControllers["$j"].text != null &&
          _businessInfoControllers["$j"].text != "") {
        if (j.contains("Phone")) {
          agreementBuilderObj["document"]["ApplicationInformation"]
                  ["MpaOutletInfo"]["Outlet"]["BusinessInfo"]["$j"] =
              _businessInfoControllers["$j"]
                  .text
                  .toString()
                  .replaceAll(new RegExp('[^0-9]'), '');
        } else {
          agreementBuilderObj["document"]["ApplicationInformation"]
                  ["MpaOutletInfo"]["Outlet"]["BusinessInfo"]["$j"] =
              _businessInfoControllers["$j"].text.toString();
        }
      }
    });

    _siteInfoControllers.forEach((j, k) {
      if (_siteInfoControllers["$j"].text != null) {
        agreementBuilderObj["document"]["ApplicationInformation"]
                ["MpaOutletInfo"]["Outlet"]["SiteInfo"]["$j"] =
            _siteInfoControllers["$j"].text.toString();
      }
    });

    _motoBBInetControllers.forEach((j, k) {
      if (_motoBBInetControllers["$j"].text != null) {
        agreementBuilderObj["document"]["ApplicationInformation"]
                ["MpaOutletInfo"]["Outlet"]["MotoBBInet"]["$j"] =
            _motoBBInetControllers["$j"].text.toString();
      }
    });

    _mpaInfoControllers.forEach((j, k) {
      if (_mpaInfoControllers["$j"].text != null) {
        agreementBuilderObj["document"]["ApplicationInformation"]["MpaInfo"]
            ["$j"] = _mpaInfoControllers["$j"].text.toString();
      }
    });

    _corporateInfoControllers.forEach((j, k) {
      if (_corporateInfoControllers["$j"].text != null) {
        agreementBuilderObj["document"]["ApplicationInformation"]
                ["CorporateInfo"]["$j"] =
            _corporateInfoControllers["$j"].text.toString();
      }
    });

    isDirtyStatus["businessInfoIsDirty"] = false;
  }

  Future<void> updateOwners(isSubmit) async {
    Map ownershipItems = {};
    var i;
    var unorderedOwners = owners;
    var orderedOwners = owners;
    orderedOwners.sort((a, b) => b["document"]["PrinOwnershipPercent"]
        .compareTo(a["document"]["PrinOwnershipPercent"]));
    var ownersInput;

    if (isSubmit == true) {
      ownersInput = orderedOwners;
      i = 2;
    } else {
      ownersInput = unorderedOwners;
      i = 1;
    }

    for (var owner in ownersInput) {
      var k = i;
      if (owner["document"]["PrinGuarantorCode"] == "1") {
        if (isSubmit == true) {
          k = 1;
          i--;
        }
        ownershipItems["Prin${k}GuarantorCode"] =
            owner["document"]["PrinGuarantorCode"];
      }
      ownershipItems["Prin${k}Dob"] = owner["document"]["PrinDob"];
      ownershipItems["Prin${k}City"] = owner["document"]["PrinCity"];
      if (owner["document"]["PrinPhone"] != null) {
        ownershipItems["Prin${k}Phone"] =
            owner["document"]["PrinPhone"].replaceAll(new RegExp('[^0-9]'), '');
        owner["document"]["PrinPhone"] =
            owner["document"]["PrinPhone"].replaceAll(new RegExp('[^0-9]'), '');
      }
      ownershipItems["Prin${k}State"] = owner["document"]["PrinState"];
      ownershipItems["Prin${k}Title"] = owner["document"]["PrinTitle"];
      ownershipItems["Prin${k}Address"] = owner["document"]["PrinAddress"];
      ownershipItems["Prin${k}LastName"] = owner["document"]["PrinLastName"];
      ownershipItems["Prin${k}First5Zip"] = owner["document"]["PrinFirst5Zip"];
      ownershipItems["Prin${k}FirstName"] = owner["document"]["PrinFirstName"];
      ownershipItems["Prin${k}OwnershipPercent"] =
          owner["document"]["PrinOwnershipPercent"];
      ownershipItems["Prin${k}Ssn"] = owner["document"]["PrinSsn"];
      if (k < 3) {
        ownershipItems["Prin${k}EmailAddress"] =
            owner["document"]["PrinEmailAddress"];
        ownershipItems["Prin${k}DriverLicenseState"] =
            owner["document"]["PrinDriverLicenseState"];
        ownershipItems["Prin${k}DriverLicenseNumber"] =
            owner["document"]["PrinDriverLicenseNumber"];
      }
      i++;
    }
    agreementBuilderObj["document"]["ApplicationInformation"]["Ownership"] =
        ownershipItems;

    isDirtyStatus["ownersIsDirty"] = false;

    var resp = await this
        .widget
        .apiService
        .authPost(context, "/businessowner", unorderedOwners);

    if (resp.statusCode == 200) {
      loadOwnersData(this.widget.leadId);
    } else {
      Fluttertoast.showToast(
          msg: "Failed to Save Owners!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> loadDocuments(agreementBuilderId) async {
    var resp = await this.widget.apiService.authGet(
        context, "/agreementbuilder/" + agreementBuilderId + "/document");

    if (resp.statusCode == 200) {
      initDocumentObjects();

      if (resp.data["payload1"] != null && resp.data["payload1"] != "") {
        setState(() {
          docsAttached["w9"] = true;
        });
      }
      if (resp.data["payload2"] != null && resp.data["payload2"] != "") {
        setState(() {
          docsAttached["voidedCheck"] = true;
        });
      }
    } else {
      Fluttertoast.showToast(
          msg: "Failed to Load Documents!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> updateSettlementTransact() async {
    _settlementControllers.forEach((j, k) {
      if (_settlementControllers["$j"].text != null) {
        agreementBuilderObj["document"]["ApplicationInformation"]
                ["MpaOutletInfo"]["Outlet"]["Settlement"]["$j"] =
            _settlementControllers["$j"].text.toString();
      }
    });

    _transactionControllers.forEach((j, k) {
      if (_transactionControllers["$j"].text != null) {
        agreementBuilderObj["document"]["ApplicationInformation"]
                ["MpaOutletInfo"]["Outlet"]["Transaction"]["$j"] =
            _transactionControllers["$j"].text.toString();
      }
    });
    _otherFeesControllers.forEach((j, k) {
      if (_otherFeesControllers["$j"].text != null &&
          _otherFeesControllers["$j"].text != "null") {
        agreementBuilderObj["document"]["ApplicationInformation"]
                ["MpaOutletInfo"]["Outlet"]["OtherFees"]["$j"] =
            _otherFeesControllers["$j"].text.toString();
      } else if (j == "UserDefinedPricing_GridValue") {
        agreementBuilderObj["document"]["ApplicationInformation"]
            ["MpaOutletInfo"]["Outlet"]["OtherFees"]["$j"] = "null";
      } else {
        agreementBuilderObj["document"]["ApplicationInformation"]
            ["MpaOutletInfo"]["Outlet"]["OtherFees"]["$j"] = null;
      }
    });

    isDirtyStatus["settlementTransactIsDirty"] = false;

    Fluttertoast.showToast(
        msg: "Settlement Transact!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<void> updateDocuments(agreementBuilderId) async {
    var data = [files["file1"], files["file2"]];
    var resp = await this.widget.apiService.authFilesPut(
        context,
        "/agreementbuilder/" +
            agreementBuilderId +
            "/employee/" +
            UserService.employee.employee +
            "/document",
        data);
    if (resp.statusCode != 200) {
      Fluttertoast.showToast(
          msg: "Failed to Save Documents!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> leaveCheck() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Really Leave?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Any unsaved changes will be lost.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Leave',
                  style: TextStyle(fontSize: 17, color: Colors.red)),
              onPressed: () {
                Navigator.pushNamed(context, '/leads');
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final _tabController =
        TabController(vsync: this, length: 5, initialIndex: currentTab);
    _tabController.addListener(() {
      currentTab = _tabController.index;
      previousTab = _tabController.previousIndex;

      if (isDirtyStatus["businessInfoIsDirty"] ||
          isDirtyStatus["ownersIsDirty"] ||
          isDirtyStatus["settlementTransactIsDirty"] ||
          isDirtyStatus["documentsIsDirty"] ||
          currentTab == 4) {
        updateAgreement(agreementBuilderObj["agreement_builder"]);
      }
    });

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: WillPopScope(
        onWillPop: () {
          leaveCheck();
          return Future.value(false);
        },
        child: DefaultTabController(
          length: 5,
          child: Scaffold(
            backgroundColor: Color.fromARGB(255, 242, 242, 242),
            appBar: AppBar(
                key: Key("agreementBuilderAppBar"),
                title: Text(isLoading ? "Loading..." : "Agreement Builder"),
                backgroundColor: Color.fromARGB(255, 21, 27, 38),
                bottom: TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(
                        text: "Business Info",
                        icon: isValidated["BusinessInfo"] != null
                            ? isValidated["BusinessInfo"] == true
                                ? Icon(Icons.done, color: Colors.green)
                                : Icon(Icons.error_outline, color: Colors.red)
                            : null),
                    Tab(
                        text: "Owner Info",
                        icon: isValidated["Ownership"] != null
                            ? isValidated["Ownership"] == true
                                ? Icon(Icons.done, color: Colors.green)
                                : Icon(Icons.error_outline, color: Colors.red)
                            : null),
                    Tab(
                        text: "Settlement/Transaction",
                        icon: isValidated["SettlementTransact"] != null
                            ? isValidated["SettlementTransact"] == true
                                ? Icon(Icons.done, color: Colors.green)
                                : Icon(Icons.error_outline, color: Colors.red)
                            : null),
                    Tab(
                        text: "Documents",
                        icon: isValidated["Documents"] != null
                            ? isValidated["Documents"] == true
                                ? Icon(Icons.done, color: Colors.green)
                                : Icon(Icons.error_outline, color: Colors.red)
                            : null),
                    Tab(
                        text: "Pricing",
                        icon: pricingDone == true
                            ? Icon(Icons.done, color: Colors.green)
                            : Icon(Icons.timer, color: Colors.amber))
                  ],
                  controller: _tabController,
                )),
            body: isLoading
                ? CenteredClearLoadingScreen()
                : TabBarView(controller: _tabController, children: [
                    BusinessInfo(
                        isDirtyStatus: isDirtyStatus,
                        controllers: businessPageControllers,
                        agreementDoc: agreementDocument,
                        formKey: _formKeys[0],
                        validationErrors: validationErrors),
                    OwnerInfo(
                        isDirtyStatus: isDirtyStatus,
                        owners: owners,
                        controllers: _ownershipControllers,
                        lead: this.widget.leadId,
                        formKey: _formKeys[1],
                        validationErrors: validationErrors,
                        callback: () async {
                          updateAgreement(
                              agreementBuilderObj["agreement_builder"]);
                        }),
                    SettlementTransact(
                      isDirtyStatus: isDirtyStatus,
                      controllers: settlementTransactPageControllers,
                      agreementDoc: agreementDocument,
                      formKey: _formKeys[2],
                      validationErrors: validationErrors,
                      seasonalMerchant: seasonalMerchant,
                    ),
                    Documents(
                        files: files,
                        isDirtyStatus: isDirtyStatus,
                        fileStatus: docsAttached),
                    Pricing(
                        finalValidation: allStepsComplete,
                        rateReview: rateReview,
                        pricingDone: pricingDone,
                        callback: () async {
                          isDirtyStatus["ownersIsDirty"] = true;
                          await updateAgreement(
                              agreementBuilderObj["agreement_builder"],
                              isSubmit: true);
                          setState(() {
                            isLoading = true;
                          });
                          var data = agreementBuilderObj["document"];
                          var resp = await this
                              .widget
                              .apiService
                              .authPost(context, "/merchant/app", data);
                          if (resp.statusCode == 200) {
                            setState(() {
                              isLoading = false;
                            });
                            print(resp);
                            submitResults(resp.data);
                            Fluttertoast.showToast(
                                msg: "SUBMIT!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.grey[600],
                                textColor: Colors.white,
                                fontSize: 16.0);
                          } else {
                            setState(() {
                              isLoading = false;
                            });
                            Fluttertoast.showToast(
                                msg: "Failed Submit!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.grey[600],
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }
                        })
                  ]),
            floatingActionButton: isLoading
                ? null
                : FloatingActionButton(
                    onPressed: () async {
                      updateAgreement(agreementBuilderObj["agreement_builder"]);
                    },
                    backgroundColor: Color.fromARGB(500, 1, 224, 143),
                    child: Icon(Icons.save),
                  ),
          ),
        ),
      ),
    );
  }

  Widget showInfoRow(label, value) {
    if (value == null) {
      value = "";
    }
    return Container(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Text(
                '$label: ',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Expanded(flex: 8, child: Text(value)),
          ],
        ),
      ),
    );
  }

  Widget getInfoRow(label, value, controller) {
    if (value != null) {
      controller.text = value;
    }

    var valueFmt = value ?? "N/A";

    if (valueFmt == "") {
      valueFmt = "N/A";
    }

    return Container(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Text(
                '$label: ',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Expanded(
              flex: 8,
              child: TextField(controller: controller),
            ),
          ],
        ),
      ),
    );
  }
}
