import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:atlascrm/services/UserService.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';
import 'package:atlascrm/components/agreement/Documents.dart';
import 'package:atlascrm/components/agreement/OwnerInfo.dart';
import 'package:atlascrm/components/shared/CustomCard.dart';
import 'package:atlascrm/components/shared/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/services/ApiService.dart';
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

Map isDirtyStatus = {
  "businessInfoIsDirty": false,
  "ownersIsDirty": false,
  "settlementTransactIsDirty": false,
  "documentsIsDirty": false,
};

//MpaOutletInfo.Outlet
//--BUSINESS INFO TAB --
final List generalControllerNames = ["corpSame", "motoCheck"];

final List businessInfoControllerNames = [
  "Sic",
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
  "ForeignEntityOrNonResidentAlien"
];

final List siteInfoControllerNames = [
  "Zone",
  "Location",
  "RefundType",
  "NoOfRegister",
  "RefundPolicy",
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
  "CurrentStmntProvided",
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
final List entitlementControllerNames = [
  "AmexOption",
  "AmexFeeClass",
  "AmexDiscountQual",
  "AmexInterchangeFeeFlag",
  "AmexOtherItemRateNotESA"
];

final List otherFeesControllerNames = [
  "BatchFee",
  "SaleTranFee",
  "ACHRejectFee",
  "RetrievalFee",
  "ChargebackFee",
  "ReturnTranFee",
  "eIDSAccessFee",
  "EarlyTerminationFee",
  "MonthlyStatementFee",
  "MonthlyMinimumProcessingFee"
];

final List pricingControllerNames = [
  "AffnRate",
  "Cu24Rate",
  "NyceRate",
  "StarRate",
  "AccelRate",
  "PulseRate",
  "JeanieRate",
  "ShazamRate",
  "Star18Rate",
  "Star21Rate",
  "GenericRate",
  "MaestroRate",
  "BundleOption",
  "InterlinkRate",
  "DiscountMethod",
  "MCDebitFeeClass",
  "AlaskaOptionRate",
  // "DiscountCalcFlag" : {
  //     "attributes": {
  //         "xsi:nil"
  //     }
  // },
  //TODO FIGURE OUT NESTED CONTROLLER SHIT
  "MCCreditFeeClass",
  "AffnVolumePercent",
  "Cu24VolumePercent",
  "NyceVolumePercent",
  "StarVolumePercent",
  "VisaDebitFeeClass",
  "AccelVolumePercent",
  "BundledPricingType",
  "EnablePinDebitCard",
  "MCDebitPricingType",
  "PulseVolumePercent",
  "VisaCreditFeeClass",
  "JeanieVolumePercent",
  "MCCreditPricingType",
  "ShazamVolumePercent",
  "Star18VolumePercent",
  "Star21VolumePercent",
  "GenericVolumePercent",
  "MaestroVolumePercent",
  "VisaDebitPricingType",
  "DiscoverDebitFeeClass",
  "PassThruDebitNtwkFees",
  "VisaCreditPricingType",
  "DiscoverCreditFeeClass",
  "InterlinkVolumePercent",
  "DiscoverDebitPricingType",
  "AlaskaOptionVolumePercent",
  "DiscoverCreditPricingType",
  "MCDebitQualDebit_Discount",
  "MCCreditQualCredit_Discount",
  "VisaDebitQualDebit_Discount",
  "VisaCreditQualCredit_Discount",
  "DiscoverDebitQualDebit_Discount",
  "MCDebitRetailInterchangeFeeFlag",
  "StatementInterchangePrintOption",
  "MCCreditRetailInterchangeFeeFlag",
  "DiscoverCreditQualCredit_Discount",
  "VisaDebitRetailInterchangeFeeFlag",
  "VisaCreditRetailInterchangeFeeFlag",
  "DiscoverDebitRetailInterchangeFeeFlag",
  "DiscoverCreditRetailInterchangeFeeFlag"
];
//ApplicationInformation
final List mpaInfoControllerNames = ["ClientDbaName", "NumberOfLocation"];

class AgreementBuilderState extends State<AgreementBuilder>
    with TickerProviderStateMixin {
  var agreementBuilderObj;
  var agreementDocument;

  Map files = {"file1": "", "file2": ""};

  var lead;
  var leadDocument;
  var isLoading = true;
  List owners;
  List<Widget> displayList;

  List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];

  void initState() {
    super.initState();
    loadAgreementData(this.widget.leadId);
    loadOwnersData(this.widget.leadId);
  }

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

  final Map<String, MaskedTextController> _entitlementControllers =
      Map.fromIterable(entitlementControllerNames,
          key: (i) => i,
          value: (i) =>
              MaskedTextController(mask: "******************************"));

  final Map<String, MaskedTextController> _settlementControllers =
      Map.fromIterable(
          settlementControllerNames,
          key: (i) => i,
          value: (i) =>
              MaskedTextController(mask: "******************************"));

  final Map<String, MaskedTextController> _otherFeesControllers =
      Map.fromIterable(otherFeesControllerNames,
          key: (i) => i,
          value: (i) =>
              MaskedTextController(mask: "******************************"));

  final Map<String, MaskedTextController> _pricingControllers =
      Map.fromIterable(pricingControllerNames,
          key: (i) => i,
          value: (i) =>
              MaskedTextController(mask: "******************************"));

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
        "transaction": _transactionControllers
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
      print(resp);
      if (resp != null) {
        if (resp.statusCode == 200) {
          var ownersArrDecoded = resp.data;
          if (ownersArrDecoded != null) {
            var ownersArr = List.from(ownersArrDecoded);
            if (ownersArr.length > 0) {
              setState(() {
                owners = ownersArr;
                // testOwner = ownersArr[0];
                // emptyOwner["lead"] = lead["leadId"];
              });
              // var inc = 1;
              // for (var owner in owners) {
              //   _ownershipControllers["Prin${inc.toString()}Dob"].text =
              //       owner["document"]["PrinDob"];
              //   _ownershipControllers["Prin${inc.toString()}Ssn"].text =
              //       owner["document"]["PrinSsn"];
              //   _ownershipControllers["Prin${inc.toString()}City"].text =
              //       owner["document"]["PrinCity"];
              //   _ownershipControllers["Prin${inc.toString()}Phone"].text =
              //       owner["document"]["PrinPhone"];
              //   _ownershipControllers["Prin${inc.toString()}State"].text =
              //       owner["document"]["PrinState"];
              //   _ownershipControllers["Prin${inc.toString()}Title"].text =
              //       owner["document"]["PrinTitle"];
              //   _ownershipControllers["Prin${inc.toString()}Address"].text =
              //       owner["document"]["PrinAddress"];
              //   _ownershipControllers["Prin${inc.toString()}LastName"].text =
              //       owner["document"]["PrinLastName"];
              //   _ownershipControllers["Prin${inc.toString()}First5Zip"].text =
              //       owner["document"]["First5Zip"];
              //   _ownershipControllers["Prin${inc.toString()}FirstName"].text =
              //       owner["document"]["PrinFirstName"];
              //   _ownershipControllers["Prin${inc.toString()}EmailAddress"]
              //       .text = owner["document"]["PrinEmailAddress"];
              //   _ownershipControllers["Prin${inc.toString()}GuarantorCode"]
              //       .text = owner["document"]["PrinGuarantorCode"];
              //   _ownershipControllers["Prin${inc.toString()}OwnershipPercent"]
              //       .text = owner["document"]["PrinOwnershipPercent"];
              //   _ownershipControllers["Prin${inc.toString()}DriverLicenseState"]
              //       .text = owner["document"]["PrinDriverLicenseState"];
              //   _ownershipControllers[
              //           "Prin${inc.toString()}DriverLicenseNumber"]
              //       .text = owner["document"]["PrinDriverLicenseNumber"];
              //   inc++;
              // }
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
        setState(() {
          isLoading = false;
        });
      } else {
        generateAgreement();
        // setState(() {
        //   isLoading = false;
        // });
      }
    }
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
        null);
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

    loadAgreementData(this.widget.leadId);

    // setState(() {
    //   agreementDocument = agreementBuilderObj["document"];
    //   print(agreementDocument);
    //   isLoading = false;
    // });
    // print("GENERATE");
  }

  Future<void> updateAgreement(agreementBuilderId) async {
    if (isDirtyStatus["businessInfoIsDirty"]) {
      updateBusinessInfo();
    }
    if (isDirtyStatus["ownersIsDirty"]) {
      updateOwners();
    }
    if (isDirtyStatus["settlementTransactIsDirty"]) {
      updateSettlementTransact();
    }
    if (isDirtyStatus["documentsIsDirty"]) {
      updateDocuments(agreementBuilderId);
    }
    print(agreementBuilderObj);
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
  }

  Future<void> updateBusinessInfo() async {
    _businessInfoControllers.forEach((j, k) {
      if (_businessInfoControllers["$j"].text != null) {
        agreementBuilderObj["document"]["ApplicationInformation"]
                ["MpaOutletInfo"]["Outlet"]["BusinessInfo"]["$j"] =
            _businessInfoControllers["$j"].text.toString();
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
    Fluttertoast.showToast(
        msg: "Business Info!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[600],
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<void> updateOwners() async {
    var ownershipItems = [];
    var i = 2;
    for (var owner in owners) {
      var k = i;
      if (owner["document"]["PrinGuarantorCode"] == "1") {
        k = 1;
      }
      ownershipItems.add({"Prin${k}Dob": owner["document"]["PrinDob"]});
      ownershipItems.add({"Prin${k}Ssn": owner["document"]["PrinSsn"]});
      ownershipItems.add({"Prin${k}City": owner["document"]["PrinCity"]});
      ownershipItems.add({"Prin${k}Phone": owner["document"]["PrinPhone"]});
      ownershipItems.add({"Prin${k}State": owner["document"]["PrinState"]});
      ownershipItems.add({"Prin${k}Title": owner["document"]["PrinTitle"]});
      ownershipItems.add({"Prin${k}Address": owner["document"]["PrinAddress"]});
      ownershipItems
          .add({"Prin${k}LastName": owner["document"]["PrinLastName"]});
      ownershipItems
          .add({"Prin${k}First5Zip": owner["document"]["PrinFirst5Zip"]});
      ownershipItems
          .add({"Prin${k}FirstName": owner["document"]["PrinFirstName"]});
      ownershipItems
          .add({"Prin${k}EmailAddress": owner["document"]["PrinEmailAddress"]});
      ownershipItems.add(
          {"Prin${k}GuarantorCode": owner["document"]["PrinGuarantorCode"]});
      ownershipItems.add({
        "Prin${k}OwnershipPercent": owner["document"]["PrinOwnershipPercent"]
      });
      ownershipItems.add({
        "Prin${k}DriverLicenseState": owner["document"]
            ["PrinDriverLicenseState"]
      });
      ownershipItems.add({
        "Prin${k}DriverLicenseNumber": owner["document"]
            ["PrinDriverLicenseNumber"]
      });
      k++;
    }
    agreementBuilderObj["document"]["ownership"] = ownershipItems;
    isDirtyStatus["ownersIsDirty"] = false;

    var resp = await this
        .widget
        .apiService
        .authPost(context, "/businessowner", owners);

    if (resp.statusCode == 200) {
      Fluttertoast.showToast(
          msg: "Owners Saved!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
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

    print(resp);
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
    final _tabController = TabController(vsync: this, length: 5);
    _tabController.addListener(() {
      // print(_tabController.index);
      Fluttertoast.showToast(
          msg: "Scrolled to index: ${_tabController.index}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    });

    return WillPopScope(
      onWillPop: () {
        leaveCheck();
        return Future.value(false);
      },
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 242, 242, 242),
          appBar: AppBar(
              // key: Key("contactInfoPageAppBar"),
              title: Text(isLoading ? "Loading..." : "Agreement Builder"),
              backgroundColor: Color.fromARGB(255, 21, 27, 38),
              bottom: TabBar(
                isScrollable: false,
                tabs: [
                  Tab(text: "Business Info"),
                  Tab(text: "Owner Info"),
                  Tab(text: "Settlement/Transaction"),
                  Tab(text: "Documents"),
                  Tab(text: "Pricing")
                ],
                controller: _tabController,
              )),
          body: isLoading
              ? CenteredClearLoadingScreen()
              : TabBarView(controller: _tabController, children: [
                  BusinessInfo(
                      isDirtyStatus: isDirtyStatus,
                      controllers: businessPageControllers,
                      agreementDoc: agreementDocument),
                  OwnerInfo(
                      isDirtyStatus: isDirtyStatus,
                      owners: owners,
                      controllers: _ownershipControllers,
                      lead: this.widget.leadId),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SettlementTransact(
                              isDirtyStatus: isDirtyStatus,
                              controllers: settlementTransactPageControllers,
                              agreementDoc: agreementDocument)
                        ],
                      ),
                    ),
                  ),
                  Documents(
                    files: files,
                    isDirtyStatus: isDirtyStatus,
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          CustomCard(
                            key: Key("rates1"),
                            icon: Icons.attach_money,
                            title: "Rate Review",
                            child: Column(
                              children: <Widget>[
                                //PUT GET INFO ROWS HERE
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              updateAgreement(agreementBuilderObj["agreement_builder"]);
            },
            backgroundColor: Color.fromARGB(500, 1, 224, 143),
            child: Icon(Icons.save),
          ),
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
        padding: EdgeInsets.all(15),
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
