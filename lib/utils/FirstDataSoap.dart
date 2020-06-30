// import 'package:xml/xml.dart';

// final document = XmlDocument.parse('''
// <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
//   <xs:element name="ApplicationInformation">
//     <xs:complexType>
//       <xs:sequence>
//         <xs:element name="MpaInfo">
//           <xs:complexType>
//             <xs:sequence>
//               <xs:element minOccurs="1" maxOccurs="1" name="MpaMerchantType">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:enumeration value="S" />
//                     <xs:enumeration value="C" />
//                     <xs:enumeration value="E" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="ClientType">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:enumeration value="FSP" />
//                     <xs:enumeration value="RETAIL" />
//                     <xs:enumeration value="WHOLESALE" />
//                     <xs:enumeration value="HYBRID_WHOLESALE" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="MerchantAccountType">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:int">
//                     <xs:enumeration value="1" />
//                     <xs:enumeration value="2" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="SystemNumber" type="xs:string" />
//               <xs:element minOccurs="1" maxOccurs="1" name="PrinNumber" type="xs:string" />
//               <xs:element minOccurs="0" maxOccurs="1" name="Agent" nillable="true" type="xs:string" />
//               <xs:element minOccurs="0" maxOccurs="1" name="SalesID" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="4" />
//                     <xs:pattern value="^[a-zA-Z0-9]+$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="ClientDbaName">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="30" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="NumberOfLocation">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:int">
//                     <xs:minInclusive value="1" />
//                     <xs:maxInclusive value="99" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//             </xs:sequence>
//           </xs:complexType>
//         </xs:element>
//         <xs:element name="CorporateInfo">
//           <xs:complexType>
//             <xs:sequence>
//               <xs:element minOccurs="1" maxOccurs="1" name="LegalName">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="30" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Address1" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="24" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Suite" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="24" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="City">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="18" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="State">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:enumeration value="AK" />
//                     <xs:enumeration value="AL" />
//                     <xs:enumeration value="AR" />
//                     <xs:enumeration value="AZ" />
//                     <xs:enumeration value="CA" />
//                     <xs:enumeration value="CO" />
//                     <xs:enumeration value="CT" />
//                     <xs:enumeration value="DC" />
//                     <xs:enumeration value="DE" />
//                     <xs:enumeration value="FL" />
//                     <xs:enumeration value="GA" />
//                     <xs:enumeration value="HI" />
//                     <xs:enumeration value="IA" />
//                     <xs:enumeration value="ID" />
//                     <xs:enumeration value="IL" />
//                     <xs:enumeration value="IN" />
//                     <xs:enumeration value="KS" />
//                     <xs:enumeration value="KY" />
//                     <xs:enumeration value="LA" />
//                     <xs:enumeration value="MA" />
//                     <xs:enumeration value="MD" />
//                     <xs:enumeration value="ME" />
//                     <xs:enumeration value="MI" />
//                     <xs:enumeration value="MN" />
//                     <xs:enumeration value="MO" />
//                     <xs:enumeration value="MS" />
//                     <xs:enumeration value="MT" />
//                     <xs:enumeration value="NC" />
//                     <xs:enumeration value="ND" />
//                     <xs:enumeration value="NE" />
//                     <xs:enumeration value="NH" />
//                     <xs:enumeration value="NJ" />
//                     <xs:enumeration value="NM" />
//                     <xs:enumeration value="NV" />
//                     <xs:enumeration value="NY" />
//                     <xs:enumeration value="OH" />
//                     <xs:enumeration value="OK" />
//                     <xs:enumeration value="OR" />
//                     <xs:enumeration value="PA" />
//                     <xs:enumeration value="PR" />
//                     <xs:enumeration value="RI" />
//                     <xs:enumeration value="SC" />
//                     <xs:enumeration value="SD" />
//                     <xs:enumeration value="TN" />
//                     <xs:enumeration value="TX" />
//                     <xs:enumeration value="UT" />
//                     <xs:enumeration value="VA" />
//                     <xs:enumeration value="VI" />
//                     <xs:enumeration value="VT" />
//                     <xs:enumeration value="WA" />
//                     <xs:enumeration value="WI" />
//                     <xs:enumeration value="WV" />
//                     <xs:enumeration value="WY" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="First5Zip">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="5" />
//                     <xs:maxLength value="5" />
//                     <xs:pattern value="[0-9]+" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Last4Zip" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="4" />
//                     <xs:maxLength value="4" />
//                     <xs:pattern value="[0-9]*" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="CorporateContact">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:maxLength value="24" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="SendRetRequestTo" type="xs:int" />
//               <xs:element minOccurs="1" maxOccurs="1" name="SendCBTo" type="xs:int" />
//               <xs:element minOccurs="1" maxOccurs="1" name="SendMonthlyStmntTo" type="xs:int" />
//               <xs:element minOccurs="0" maxOccurs="1" name="BusinessStartDate" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:pattern value="^$|^((((0[13578])|(1[02]))[/]((0[1-9])|([1-2][0-9])|(3[01])))|(((0[469])|(11))[/]((0[1-9])|([1-2][0-9])|(30)))|((02)[/]((0[1-9])|([1-2][0-9]))))[/]\d{4}$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//                 <xs:element minOccurs="0" maxOccurs="1" name="BusinessType" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:enumeration value="1" />
//                     <xs:enumeration value="2" />
//                     <xs:enumeration value="3" />
//                     <xs:enumeration value="4" />
//                     <xs:enumeration value="5" />
//                     <xs:enumeration value="6" />
//                     <xs:enumeration value="7" />
//                     <xs:enumeration value="8" />
//                     <xs:enumeration value="9" />
//                     <xs:enumeration value="10" />
//                     <xs:enumeration value="11" />
//                     <xs:enumeration value="" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="StateIncorporated"  nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:enumeration value="AK" />
//                     <xs:enumeration value="AL" />
//                     <xs:enumeration value="AR" />
//                     <xs:enumeration value="AZ" />
//                     <xs:enumeration value="CA" />
//                     <xs:enumeration value="CO" />
//                     <xs:enumeration value="CT" />
//                     <xs:enumeration value="DC" />
//                     <xs:enumeration value="DE" />
//                     <xs:enumeration value="FL" />
//                     <xs:enumeration value="GA" />
//                     <xs:enumeration value="HI" />
//                     <xs:enumeration value="IA" />
//                     <xs:enumeration value="ID" />
//                     <xs:enumeration value="IL" />
//                     <xs:enumeration value="IN" />
//                     <xs:enumeration value="KS" />
//                     <xs:enumeration value="KY" />
//                     <xs:enumeration value="LA" />
//                     <xs:enumeration value="MA" />
//                     <xs:enumeration value="MD" />
//                     <xs:enumeration value="ME" />
//                     <xs:enumeration value="MI" />
//                     <xs:enumeration value="MN" />
//                     <xs:enumeration value="MO" />
//                     <xs:enumeration value="MS" />
//                     <xs:enumeration value="MT" />
//                     <xs:enumeration value="NC" />
//                     <xs:enumeration value="ND" />
//                     <xs:enumeration value="NE" />
//                     <xs:enumeration value="NH" />
//                     <xs:enumeration value="NJ" />
//                     <xs:enumeration value="NM" />
//                     <xs:enumeration value="NV" />
//                     <xs:enumeration value="NY" />
//                     <xs:enumeration value="OH" />
//                     <xs:enumeration value="OK" />
//                     <xs:enumeration value="OR" />
//                     <xs:enumeration value="PA" />
//                     <xs:enumeration value="PR" />
//                     <xs:enumeration value="RI" />
//                     <xs:enumeration value="SC" />
//                     <xs:enumeration value="SD" />
//                     <xs:enumeration value="TN" />
//                     <xs:enumeration value="TX" />
//                     <xs:enumeration value="UT" />
//                     <xs:enumeration value="VA" />
//                     <xs:enumeration value="VI" />
//                     <xs:enumeration value="VT" />
//                     <xs:enumeration value="WA" />
//                     <xs:enumeration value="WI" />
//                     <xs:enumeration value="WV" />
//                     <xs:enumeration value="WY" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="ChainCode" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="5" />
//                     <xs:maxLength value="5" />
//                     <xs:pattern value="[0-9]*" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="AddLocationToExistingMid" type="xs:boolean" />
//               <xs:element minOccurs="0" maxOccurs="1" name="ExistingMid" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                      <xs:maxLength value="16" />
//                     <xs:pattern value="^[0-9]+$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="IsAdvertisingMethodCatalog" nillable="true" type="xs:boolean" />
//               <xs:element minOccurs="0" maxOccurs="1" name="IsAdvertisingMethodBrochure" nillable="true" type="xs:boolean" />
//               <xs:element minOccurs="0" maxOccurs="1" name="IsAdvertisingMethodDirectMall" nillable="true" type="xs:boolean" />
//               <xs:element minOccurs="0" maxOccurs="1" name="IsAdvertisingMethodTvRadio" nillable="true" type="xs:boolean" />
//               <xs:element minOccurs="0" maxOccurs="1" name="IsAdvertisingMethodInternet" nillable="true" type="xs:boolean" />
//               <xs:element minOccurs="0" maxOccurs="1" name="IsAdvertisingMethodPhone" nillable="true" type="xs:boolean" />
//               <xs:element minOccurs="0" maxOccurs="1" name="IsAdvertisingMethodNewspaperJournals" nillable="true" type="xs:boolean" />
//               <xs:element minOccurs="0" maxOccurs="1" name="IsAdvertisingMethodOther" nillable="true" type="xs:boolean" />
//               <xs:element minOccurs="0" maxOccurs="1" name="PreviousProcessor" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="24" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="ReasonForLeaving" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:enumeration value="1" />
//                     <xs:enumeration value="2" />
//                     <xs:enumeration value="3" />
//                     <xs:enumeration value="4" />
//                     <xs:enumeration value="" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="CurrentStmntProvided" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:enumeration value="0" />
//                     <xs:enumeration value="1" />
//                     <xs:enumeration value="" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="CorporateAddress1" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="24" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="CorporateAddress2" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="24" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="CorporateAddress3" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="38" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="CorporateAddress4" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="38" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="StatementHoldRefValue" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="50" />
//                     <xs:enumeration value="1" />
//                     <xs:enumeration value="2" />
//                     <xs:enumeration value="3" />
//                     <xs:enumeration value="" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="StatementAdditionalPageRefValue" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="70" />
//                     <xs:enumeration value="" />
//                     <xs:enumeration value="1" />
//                     <xs:enumeration value="2" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="RetrievalFaxRptCodeRefValue" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="70" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="_12BLetterType" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="70" />
//                     <xs:enumeration value="1" />
//                     <xs:enumeration value="2" />
//                     <xs:enumeration value="3" />
//                     <xs:enumeration value="4" />
//                     <xs:enumeration value="5" />
//                     <xs:enumeration value="6" />
//                     <xs:enumeration value="7" />
//                     <xs:enumeration value="" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="ExcludeAdjOrChargebacksRefValue" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="70" />
//                     <xs:enumeration value="" />
//                     <xs:enumeration value="1" />
//                     <xs:enumeration value="2" />
//                     <xs:enumeration value="3" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="AutoPMFlagRefValue" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="70" />
//                     <xs:enumeration value="1" />
//                     <xs:enumeration value="2" />
//                     <xs:enumeration value="3" />
//                     <xs:enumeration value="" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="ChainHeadquarterPercent" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:decimal">
//                     <xs:maxInclusive value="100" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//             </xs:sequence>
//           </xs:complexType>
//         </xs:element>
//         <xs:element name="Ownership" minOccurs="0" maxOccurs="1" nillable="true">
//           <xs:complexType>
//             <xs:sequence>

//             <xs:element minOccurs="1" maxOccurs="1" name="PrinPhone">
//             <xs:simpleType>
//               <xs:restriction base="xs:string">
//                   <xs:pattern value="^\(?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\)?\D?[2-9][0-9]{2}\D?[0-9]{4}$" />
//               </xs:restriction>
//             </xs:simpleType>
//           </xs:element>
//           <xs:element minOccurs="0" maxOccurs="1" name="PrinEmailAddress" nillable="true">
//             <xs:simpleType>
//               <xs:restriction base="xs:string">
//                 <xs:maxLength value="40" />
//                 <xs:pattern value="^[a-zA-Z0-9]+([.'_-]\w*)*@([\-|\w|_])+([-.]\w+)*\.\w+([-.]\w+)*$" />
//               </xs:restriction>
//             </xs:simpleType>
//           </xs:element>
//           <xs:element minOccurs="0" maxOccurs="1" name="PrinSsn" nillable="true">
//             <xs:simpleType>
//               <xs:restriction base="xs:string">
//                 <xs:minLength value="9" />
//                 <xs:maxLength value="9" />
//                 <xs:pattern value="^[0-9]+$" />
//               </xs:restriction>
//             </xs:simpleType>
//           </xs:element>
//           <xs:element minOccurs="1" maxOccurs="1" name="PrinDob" nillable="true">
//             <xs:simpleType>
//               <xs:restriction base="xs:string">
//                 <xs:pattern value="^$|^((((0[13578])|(1[02]))[/]((0[1-9])|([1-2][0-9])|(3[01])))|(((0[469])|(11))[/]((0[1-9])|([1-2][0-9])|(30)))|((02)[/]((0[1-9])|([1-2][0-9]))))[/]\d{4}$" />
//               </xs:restriction>
//             </xs:simpleType>
//           </xs:element>
//           <xs:element minOccurs="0" maxOccurs="1" name="PrinDriverLicenseNumber" nillable="true">
//             <xs:simpleType>
//               <xs:restriction base="xs:string">
//                 <xs:pattern value="\w{0,15}$" />
//               </xs:restriction>
//             </xs:simpleType>
//           </xs:element>

//               <xs:element minOccurs="1" maxOccurs="1" name="Prin1FirstName">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="10" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="Prin1LastName">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="11" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin1MiddleInitial" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="1" />
//                     <xs:maxLength value="1" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="Prin1OwnershipPercent">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:int">
//                     <xs:pattern value="\d{1,3}$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="Prin1GuarantorCode">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:enumeration value="0" />
//                     <xs:enumeration value="1" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="Prin1Title">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:enumeration value="1" />
//                     <xs:enumeration value="2" />
//                     <xs:enumeration value="3" />
//                     <xs:enumeration value="4" />
//                     <xs:enumeration value="5" />
//                     <xs:enumeration value="6" />
//                     <xs:enumeration value="7" />
//                     <xs:enumeration value="8" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="Prin1Address">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="24" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="Prin1City">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="18" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="Prin1State">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:enumeration value="AK" />
//                     <xs:enumeration value="AL" />
//                     <xs:enumeration value="AR" />
//                     <xs:enumeration value="AZ" />
//                     <xs:enumeration value="CA" />
//                     <xs:enumeration value="CO" />
//                     <xs:enumeration value="CT" />
//                     <xs:enumeration value="DC" />
//                     <xs:enumeration value="DE" />
//                     <xs:enumeration value="FL" />
//                     <xs:enumeration value="GA" />
//                     <xs:enumeration value="HI" />
//                     <xs:enumeration value="IA" />
//                     <xs:enumeration value="ID" />
//                     <xs:enumeration value="IL" />
//                     <xs:enumeration value="IN" />
//                     <xs:enumeration value="KS" />
//                     <xs:enumeration value="KY" />
//                     <xs:enumeration value="LA" />
//                     <xs:enumeration value="MA" />
//                     <xs:enumeration value="MD" />
//                     <xs:enumeration value="ME" />
//                     <xs:enumeration value="MI" />
//                     <xs:enumeration value="MN" />
//                     <xs:enumeration value="MO" />
//                     <xs:enumeration value="MS" />
//                     <xs:enumeration value="MT" />
//                     <xs:enumeration value="NC" />
//                     <xs:enumeration value="ND" />
//                     <xs:enumeration value="NE" />
//                     <xs:enumeration value="NH" />
//                     <xs:enumeration value="NJ" />
//                     <xs:enumeration value="NM" />
//                     <xs:enumeration value="NV" />
//                     <xs:enumeration value="NY" />
//                     <xs:enumeration value="OH" />
//                     <xs:enumeration value="OK" />
//                     <xs:enumeration value="OR" />
//                     <xs:enumeration value="PA" />
//                     <xs:enumeration value="PR" />
//                     <xs:enumeration value="RI" />
//                     <xs:enumeration value="SC" />
//                     <xs:enumeration value="SD" />
//                     <xs:enumeration value="TN" />
//                     <xs:enumeration value="TX" />
//                     <xs:enumeration value="UT" />
//                     <xs:enumeration value="VA" />
//                     <xs:enumeration value="VI" />
//                     <xs:enumeration value="VT" />
//                     <xs:enumeration value="WA" />
//                     <xs:enumeration value="WI" />
//                     <xs:enumeration value="WV" />
//                     <xs:enumeration value="WY" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="Prin1First5Zip">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="5" />
//                     <xs:maxLength value="5" />
//                     <xs:pattern value="[0-9]+" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin1Last4Zip" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="4" />
//                     <xs:maxLength value="4" />
//                     <xs:pattern value="[0-9]*" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="Prin1Phone">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                       <xs:pattern value="^\(?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\)?\D?[2-9][0-9]{2}\D?[0-9]{4}$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin1EmailAddress" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:maxLength value="40" />
//                     <xs:pattern value="^[a-zA-Z0-9]+([.'_-]\w*)*@([\-|\w|_])+([-.]\w+)*\.\w+([-.]\w+)*$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin1Ssn" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="9" />
//                     <xs:maxLength value="9" />
//                     <xs:pattern value="^[0-9]+$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="Prin1Dob" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:pattern value="^$|^((((0[13578])|(1[02]))[/]((0[1-9])|([1-2][0-9])|(3[01])))|(((0[469])|(11))[/]((0[1-9])|([1-2][0-9])|(30)))|((02)[/]((0[1-9])|([1-2][0-9]))))[/]\d{4}$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin1DriverLicenseNumber" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:pattern value="\w{0,15}$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin1DriverLicenseState" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:enumeration value="AK" />
//                     <xs:enumeration value="AL" />
//                     <xs:enumeration value="AR" />
//                     <xs:enumeration value="AZ" />
//                     <xs:enumeration value="CA" />
//                     <xs:enumeration value="CO" />
//                     <xs:enumeration value="CT" />
//                     <xs:enumeration value="DC" />
//                     <xs:enumeration value="DE" />
//                     <xs:enumeration value="FL" />
//                     <xs:enumeration value="GA" />
//                     <xs:enumeration value="HI" />
//                     <xs:enumeration value="IA" />
//                     <xs:enumeration value="ID" />
//                     <xs:enumeration value="IL" />
//                     <xs:enumeration value="IN" />
//                     <xs:enumeration value="KS" />
//                     <xs:enumeration value="KY" />
//                     <xs:enumeration value="LA" />
//                     <xs:enumeration value="MA" />
//                     <xs:enumeration value="MD" />
//                     <xs:enumeration value="ME" />
//                     <xs:enumeration value="MI" />
//                     <xs:enumeration value="MN" />
//                     <xs:enumeration value="MO" />
//                     <xs:enumeration value="MS" />
//                     <xs:enumeration value="MT" />
//                     <xs:enumeration value="NC" />
//                     <xs:enumeration value="ND" />
//                     <xs:enumeration value="NE" />
//                     <xs:enumeration value="NH" />
//                     <xs:enumeration value="NJ" />
//                     <xs:enumeration value="NM" />
//                     <xs:enumeration value="NV" />
//                     <xs:enumeration value="NY" />
//                     <xs:enumeration value="OH" />
//                     <xs:enumeration value="OK" />
//                     <xs:enumeration value="OR" />
//                     <xs:enumeration value="PA" />
//                     <xs:enumeration value="PR" />
//                     <xs:enumeration value="RI" />
//                     <xs:enumeration value="SC" />
//                     <xs:enumeration value="SD" />
//                     <xs:enumeration value="TN" />
//                     <xs:enumeration value="TX" />
//                     <xs:enumeration value="UT" />
//                     <xs:enumeration value="VA" />
//                     <xs:enumeration value="VI" />
//                     <xs:enumeration value="VT" />
//                     <xs:enumeration value="WA" />
//                     <xs:enumeration value="WI" />
//                     <xs:enumeration value="WV" />
//                     <xs:enumeration value="WY" />
//                     <xs:enumeration value="" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="HasAdditionalOwner" type="xs:boolean" />
//               <xs:element minOccurs="0" maxOccurs="1" name="NumberOfAdditionalOwner" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:int">
//                     <xs:enumeration value="1" />
//                     <xs:enumeration value="2" />
//                     <xs:enumeration value="3" />
//                     <xs:enumeration value="4" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin2FirstName" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="10" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin2LastName" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="11" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin2MiddleInitial" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="1" />
//                     <xs:maxLength value="1" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin2OwnershipPercent" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:int">
//                     <xs:pattern value="\d{1,3}$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin2GuarantorCode" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:enumeration value="" />
//                     <xs:enumeration value="0" />
//                     <xs:enumeration value="1" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin2Title" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:enumeration value="1" />
//                     <xs:enumeration value="2" />
//                     <xs:enumeration value="3" />
//                     <xs:enumeration value="4" />
//                     <xs:enumeration value="5" />
//                     <xs:enumeration value="6" />
//                     <xs:enumeration value="7" />
//                     <xs:enumeration value="8" />
//                     <xs:enumeration value="" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin2Address" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="24" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin2City" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="18" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin2State" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:enumeration value="AK" />
//                     <xs:enumeration value="AL" />
//                     <xs:enumeration value="AR" />
//                     <xs:enumeration value="AZ" />
//                     <xs:enumeration value="CA" />
//                     <xs:enumeration value="CO" />
//                     <xs:enumeration value="CT" />
//                     <xs:enumeration value="DC" />
//                     <xs:enumeration value="DE" />
//                     <xs:enumeration value="FL" />
//                     <xs:enumeration value="GA" />
//                     <xs:enumeration value="HI" />
//                     <xs:enumeration value="IA" />
//                     <xs:enumeration value="ID" />
//                     <xs:enumeration value="IL" />
//                     <xs:enumeration value="IN" />
//                     <xs:enumeration value="KS" />
//                     <xs:enumeration value="KY" />
//                     <xs:enumeration value="LA" />
//                     <xs:enumeration value="MA" />
//                     <xs:enumeration value="MD" />
//                     <xs:enumeration value="ME" />
//                     <xs:enumeration value="MI" />
//                     <xs:enumeration value="MN" />
//                     <xs:enumeration value="MO" />
//                     <xs:enumeration value="MS" />
//                     <xs:enumeration value="MT" />
//                     <xs:enumeration value="NC" />
//                     <xs:enumeration value="ND" />
//                     <xs:enumeration value="NE" />
//                     <xs:enumeration value="NH" />
//                     <xs:enumeration value="NJ" />
//                     <xs:enumeration value="NM" />
//                     <xs:enumeration value="NV" />
//                     <xs:enumeration value="NY" />
//                     <xs:enumeration value="OH" />
//                     <xs:enumeration value="OK" />
//                     <xs:enumeration value="OR" />
//                     <xs:enumeration value="PA" />
//                     <xs:enumeration value="PR" />
//                     <xs:enumeration value="RI" />
//                     <xs:enumeration value="SC" />
//                     <xs:enumeration value="SD" />
//                     <xs:enumeration value="TN" />
//                     <xs:enumeration value="TX" />
//                     <xs:enumeration value="UT" />
//                     <xs:enumeration value="VA" />
//                     <xs:enumeration value="VI" />
//                     <xs:enumeration value="VT" />
//                     <xs:enumeration value="WA" />
//                     <xs:enumeration value="WI" />
//                     <xs:enumeration value="WV" />
//                     <xs:enumeration value="WY" />
//                     <xs:enumeration value="" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin2First5Zip" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="5" />
//                     <xs:maxLength value="5" />
//                     <xs:pattern value="[0-9]+" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin2Last4Zip" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="4" />
//                     <xs:maxLength value="4" />
//                     <xs:pattern value="[0-9]*" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin2Phone" nillable="true">
//                 <xs:simpleType>
//                  <xs:restriction base="xs:string">
//                       <xs:pattern value="^\(?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\)?\D?[2-9][0-9]{2}\D?[0-9]{4}$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin2EmailAddress" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:maxLength value="40" />
//                     <xs:pattern value="^[a-zA-Z0-9]+([.'_-]\w*)*@([\-|\w|_])+([-.]\w+)*\.\w+([-.]\w+)*$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin2Ssn" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="9" />
//                     <xs:maxLength value="9" />
//                     <xs:pattern value="^[0-9]+$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin2Dob" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:pattern value="^$|^((((0[13578])|(1[02]))[/]((0[1-9])|([1-2][0-9])|(3[01])))|(((0[469])|(11))[/]((0[1-9])|([1-2][0-9])|(30)))|((02)[/]((0[1-9])|([1-2][0-9]))))[/]\d{4}$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin2DriverLicenseNumber" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="15" />
//                     <xs:pattern value="\w{0,15}$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin2DriverLicenseState" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:enumeration value="AK" />
//                     <xs:enumeration value="AL" />
//                     <xs:enumeration value="AR" />
//                     <xs:enumeration value="AZ" />
//                     <xs:enumeration value="CA" />
//                     <xs:enumeration value="CO" />
//                     <xs:enumeration value="CT" />
//                     <xs:enumeration value="DC" />
//                     <xs:enumeration value="DE" />
//                     <xs:enumeration value="FL" />
//                     <xs:enumeration value="GA" />
//                     <xs:enumeration value="HI" />
//                     <xs:enumeration value="IA" />
//                     <xs:enumeration value="ID" />
//                     <xs:enumeration value="IL" />
//                     <xs:enumeration value="IN" />
//                     <xs:enumeration value="KS" />
//                     <xs:enumeration value="KY" />
//                     <xs:enumeration value="LA" />
//                     <xs:enumeration value="MA" />
//                     <xs:enumeration value="MD" />
//                     <xs:enumeration value="ME" />
//                     <xs:enumeration value="MI" />
//                     <xs:enumeration value="MN" />
//                     <xs:enumeration value="MO" />
//                     <xs:enumeration value="MS" />
//                     <xs:enumeration value="MT" />
//                     <xs:enumeration value="NC" />
//                     <xs:enumeration value="ND" />
//                     <xs:enumeration value="NE" />
//                     <xs:enumeration value="NH" />
//                     <xs:enumeration value="NJ" />
//                     <xs:enumeration value="NM" />
//                     <xs:enumeration value="NV" />
//                     <xs:enumeration value="NY" />
//                     <xs:enumeration value="OH" />
//                     <xs:enumeration value="OK" />
//                     <xs:enumeration value="OR" />
//                     <xs:enumeration value="PA" />
//                     <xs:enumeration value="PR" />
//                     <xs:enumeration value="RI" />
//                     <xs:enumeration value="SC" />
//                     <xs:enumeration value="SD" />
//                     <xs:enumeration value="TN" />
//                     <xs:enumeration value="TX" />
//                     <xs:enumeration value="UT" />
//                     <xs:enumeration value="VA" />
//                     <xs:enumeration value="VI" />
//                     <xs:enumeration value="VT" />
//                     <xs:enumeration value="WA" />
//                     <xs:enumeration value="WI" />
//                     <xs:enumeration value="WV" />
//                     <xs:enumeration value="WY" />
//                     <xs:enumeration value="" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin3FirstName" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="10" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin3LastName" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="11" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin3MiddleInitial" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="1" />
//                     <xs:maxLength value="1" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin3OwnershipPercent" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:int">
//                     <xs:pattern value="\d{1,3}$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin3Title" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:enumeration value="1" />
//                     <xs:enumeration value="2" />
//                     <xs:enumeration value="3" />
//                     <xs:enumeration value="4" />
//                     <xs:enumeration value="5" />
//                     <xs:enumeration value="6" />
//                     <xs:enumeration value="7" />
//                     <xs:enumeration value="8" />
//                     <xs:enumeration value="" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin3Address" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="24" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin3City" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="18" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin3State" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:enumeration value="AK" />
//                     <xs:enumeration value="AL" />
//                     <xs:enumeration value="AR" />
//                     <xs:enumeration value="AZ" />
//                     <xs:enumeration value="CA" />
//                     <xs:enumeration value="CO" />
//                     <xs:enumeration value="CT" />
//                     <xs:enumeration value="DC" />
//                     <xs:enumeration value="DE" />
//                     <xs:enumeration value="FL" />
//                     <xs:enumeration value="GA" />
//                     <xs:enumeration value="HI" />
//                     <xs:enumeration value="IA" />
//                     <xs:enumeration value="ID" />
//                     <xs:enumeration value="IL" />
//                     <xs:enumeration value="IN" />
//                     <xs:enumeration value="KS" />
//                     <xs:enumeration value="KY" />
//                     <xs:enumeration value="LA" />
//                     <xs:enumeration value="MA" />
//                     <xs:enumeration value="MD" />
//                     <xs:enumeration value="ME" />
//                     <xs:enumeration value="MI" />
//                     <xs:enumeration value="MN" />
//                     <xs:enumeration value="MO" />
//                     <xs:enumeration value="MS" />
//                     <xs:enumeration value="MT" />
//                     <xs:enumeration value="NC" />
//                     <xs:enumeration value="ND" />
//                     <xs:enumeration value="NE" />
//                     <xs:enumeration value="NH" />
//                     <xs:enumeration value="NJ" />
//                     <xs:enumeration value="NM" />
//                     <xs:enumeration value="NV" />
//                     <xs:enumeration value="NY" />
//                     <xs:enumeration value="OH" />
//                     <xs:enumeration value="OK" />
//                     <xs:enumeration value="OR" />
//                     <xs:enumeration value="PA" />
//                     <xs:enumeration value="PR" />
//                     <xs:enumeration value="RI" />
//                     <xs:enumeration value="SC" />
//                     <xs:enumeration value="SD" />
//                     <xs:enumeration value="TN" />
//                     <xs:enumeration value="TX" />
//                     <xs:enumeration value="UT" />
//                     <xs:enumeration value="VA" />
//                     <xs:enumeration value="VI" />
//                     <xs:enumeration value="VT" />
//                     <xs:enumeration value="WA" />
//                     <xs:enumeration value="WI" />
//                     <xs:enumeration value="WV" />
//                     <xs:enumeration value="WY" />
//                     <xs:enumeration value="" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin3First5Zip" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="5" />
//                     <xs:maxLength value="5" />
//                     <xs:pattern value="[0-9]+" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin3Last4Zip" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="4" />
//                     <xs:maxLength value="4" />
//                     <xs:pattern value="[0-9]*" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin3Phone" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:maxLength value="15" />
//                      <xs:pattern value="^\(?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\)?\D?[2-9][0-9]{2}\D?[0-9]{4}$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin3Ssn" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="9" />
//                     <xs:maxLength value="9" />
//                     <xs:pattern value="^[0-9]+$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin3Dob" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:pattern value="^$|^((((0[13578])|(1[02]))[/]((0[1-9])|([1-2][0-9])|(3[01])))|(((0[469])|(11))[/]((0[1-9])|([1-2][0-9])|(30)))|((02)[/]((0[1-9])|([1-2][0-9]))))[/]\d{4}$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin4FirstName" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="10" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin4LastName" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="11" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin4MiddleInitial" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="1" />
//                     <xs:maxLength value="1" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin4OwnershipPercent" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:int">
//                     <xs:pattern value="\d{1,3}$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin4Title" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:enumeration value="1" />
//                     <xs:enumeration value="2" />
//                     <xs:enumeration value="3" />
//                     <xs:enumeration value="4" />
//                     <xs:enumeration value="5" />
//                     <xs:enumeration value="6" />
//                     <xs:enumeration value="7" />
//                     <xs:enumeration value="8" />
//                     <xs:enumeration value="" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin4Address" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="24" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin4City" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="18" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin4State" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:enumeration value="AK" />
//                     <xs:enumeration value="AL" />
//                     <xs:enumeration value="AR" />
//                     <xs:enumeration value="AZ" />
//                     <xs:enumeration value="CA" />
//                     <xs:enumeration value="CO" />
//                     <xs:enumeration value="CT" />
//                     <xs:enumeration value="DC" />
//                     <xs:enumeration value="DE" />
//                     <xs:enumeration value="FL" />
//                     <xs:enumeration value="GA" />
//                     <xs:enumeration value="HI" />
//                     <xs:enumeration value="IA" />
//                     <xs:enumeration value="ID" />
//                     <xs:enumeration value="IL" />
//                     <xs:enumeration value="IN" />
//                     <xs:enumeration value="KS" />
//                     <xs:enumeration value="KY" />
//                     <xs:enumeration value="LA" />
//                     <xs:enumeration value="MA" />
//                     <xs:enumeration value="MD" />
//                     <xs:enumeration value="ME" />
//                     <xs:enumeration value="MI" />
//                     <xs:enumeration value="MN" />
//                     <xs:enumeration value="MO" />
//                     <xs:enumeration value="MS" />
//                     <xs:enumeration value="MT" />
//                     <xs:enumeration value="NC" />
//                     <xs:enumeration value="ND" />
//                     <xs:enumeration value="NE" />
//                     <xs:enumeration value="NH" />
//                     <xs:enumeration value="NJ" />
//                     <xs:enumeration value="NM" />
//                     <xs:enumeration value="NV" />
//                     <xs:enumeration value="NY" />
//                     <xs:enumeration value="OH" />
//                     <xs:enumeration value="OK" />
//                     <xs:enumeration value="OR" />
//                     <xs:enumeration value="PA" />
//                     <xs:enumeration value="PR" />
//                     <xs:enumeration value="RI" />
//                     <xs:enumeration value="SC" />
//                     <xs:enumeration value="SD" />
//                     <xs:enumeration value="TN" />
//                     <xs:enumeration value="TX" />
//                     <xs:enumeration value="UT" />
//                     <xs:enumeration value="VA" />
//                     <xs:enumeration value="VI" />
//                     <xs:enumeration value="VT" />
//                     <xs:enumeration value="WA" />
//                     <xs:enumeration value="WI" />
//                     <xs:enumeration value="WV" />
//                     <xs:enumeration value="WY" />
//                     <xs:enumeration value="" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin4First5Zip" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="5" />
//                     <xs:maxLength value="5" />
//                     <xs:pattern value="[0-9]+" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin4Last4Zip" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="4" />
//                     <xs:maxLength value="4" />
//                     <xs:pattern value="[0-9]*" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin4Phone" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:maxLength value="15" />
//                      <xs:pattern value="^\(?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\)?\D?[2-9][0-9]{2}\D?[0-9]{4}$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin4Ssn" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="9" />
//                     <xs:maxLength value="9" />
//                     <xs:pattern value="^[0-9]+$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin4Dob" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:pattern value="^$|^((((0[13578])|(1[02]))[/]((0[1-9])|([1-2][0-9])|(3[01])))|(((0[469])|(11))[/]((0[1-9])|([1-2][0-9])|(30)))|((02)[/]((0[1-9])|([1-2][0-9]))))[/]\d{4}$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin5FirstName" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="10" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin5LastName" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="11" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin5MiddleInitial" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="1" />
//                     <xs:maxLength value="1" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin5OwnershipPercent" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:int">
//                     <xs:pattern value="\d{1,3}$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin5Title" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:enumeration value="1" />
//                     <xs:enumeration value="2" />
//                     <xs:enumeration value="3" />
//                     <xs:enumeration value="4" />
//                     <xs:enumeration value="5" />
//                     <xs:enumeration value="6" />
//                     <xs:enumeration value="7" />
//                     <xs:enumeration value="8" />
//                     <xs:enumeration value="" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin5Address" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="24" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin5City" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="0" />
//                     <xs:maxLength value="18" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin5State" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:enumeration value="AK" />
//                     <xs:enumeration value="AL" />
//                     <xs:enumeration value="AR" />
//                     <xs:enumeration value="AZ" />
//                     <xs:enumeration value="CA" />
//                     <xs:enumeration value="CO" />
//                     <xs:enumeration value="CT" />
//                     <xs:enumeration value="DC" />
//                     <xs:enumeration value="DE" />
//                     <xs:enumeration value="FL" />
//                     <xs:enumeration value="GA" />
//                     <xs:enumeration value="HI" />
//                     <xs:enumeration value="IA" />
//                     <xs:enumeration value="ID" />
//                     <xs:enumeration value="IL" />
//                     <xs:enumeration value="IN" />
//                     <xs:enumeration value="KS" />
//                     <xs:enumeration value="KY" />
//                     <xs:enumeration value="LA" />
//                     <xs:enumeration value="MA" />
//                     <xs:enumeration value="MD" />
//                     <xs:enumeration value="ME" />
//                     <xs:enumeration value="MI" />
//                     <xs:enumeration value="MN" />
//                     <xs:enumeration value="MO" />
//                     <xs:enumeration value="MS" />
//                     <xs:enumeration value="MT" />
//                     <xs:enumeration value="NC" />
//                     <xs:enumeration value="ND" />
//                     <xs:enumeration value="NE" />
//                     <xs:enumeration value="NH" />
//                     <xs:enumeration value="NJ" />
//                     <xs:enumeration value="NM" />
//                     <xs:enumeration value="NV" />
//                     <xs:enumeration value="NY" />
//                     <xs:enumeration value="OH" />
//                     <xs:enumeration value="OK" />
//                     <xs:enumeration value="OR" />
//                     <xs:enumeration value="PA" />
//                     <xs:enumeration value="PR" />
//                     <xs:enumeration value="RI" />
//                     <xs:enumeration value="SC" />
//                     <xs:enumeration value="SD" />
//                     <xs:enumeration value="TN" />
//                     <xs:enumeration value="TX" />
//                     <xs:enumeration value="UT" />
//                     <xs:enumeration value="VA" />
//                     <xs:enumeration value="VI" />
//                     <xs:enumeration value="VT" />
//                     <xs:enumeration value="WA" />
//                     <xs:enumeration value="WI" />
//                     <xs:enumeration value="WV" />
//                     <xs:enumeration value="WY" />
//                     <xs:enumeration value="" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin5First5Zip" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="5" />
//                     <xs:maxLength value="5" />
//                     <xs:pattern value="[0-9]+" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin5Last4Zip" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="4" />
//                     <xs:maxLength value="4" />
//                     <xs:pattern value="[0-9]*" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin5Phone" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:maxLength value="15" />
//                      <xs:pattern value="^\(?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\)?\D?[2-9][0-9]{2}\D?[0-9]{4}$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin5Ssn" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:minLength value="9" />
//                     <xs:maxLength value="9" />
//                     <xs:pattern value="^[0-9]+$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="Prin5Dob" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:pattern value="^$|^((((0[13578])|(1[02]))[/]((0[1-9])|([1-2][0-9])|(3[01])))|(((0[469])|(11))[/]((0[1-9])|([1-2][0-9])|(30)))|((02)[/]((0[1-9])|([1-2][0-9]))))[/]\d{4}$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//             </xs:sequence>
//           </xs:complexType>
//         </xs:element>
//         <xs:element name="Signature" minOccurs="0" maxOccurs="1" nillable="true">
//           <xs:complexType>
//             <xs:sequence>
//               <xs:element minOccurs="1" maxOccurs="1" name="ClientMpaSignerName1" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:maxLength value="24" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="ClientMpaSignerTitle1" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:enumeration value="1" />
//                     <xs:enumeration value="2" />
//                     <xs:enumeration value="3" />
//                     <xs:enumeration value="4" />
//                     <xs:enumeration value="5" />
//                     <xs:enumeration value="6" />
//                     <xs:enumeration value="7" />
//                     <xs:enumeration value="8" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="ClientMpaDateSigned1" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:pattern value="^$|^((((0[13578])|(1[02]))[/]((0[1-9])|([1-2][0-9])|(3[01])))|(((0[469])|(11))[/]((0[1-9])|([1-2][0-9])|(30)))|((02)[/]((0[1-9])|([1-2][0-9]))))[/]\d{4}$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="ClientMpaSignerName2" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:maxLength value="24" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="ClientMpaSignerTitle2" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:enumeration value="1" />
//                     <xs:enumeration value="2" />
//                     <xs:enumeration value="3" />
//                     <xs:enumeration value="4" />
//                     <xs:enumeration value="5" />
//                     <xs:enumeration value="6" />
//                     <xs:enumeration value="7" />
//                     <xs:enumeration value="8" />
//                     <xs:enumeration value="" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="ClientMpaDateSigned2" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:pattern value="^$|^((((0[13578])|(1[02]))[/]((0[1-9])|([1-2][0-9])|(3[01])))|(((0[469])|(11))[/]((0[1-9])|([1-2][0-9])|(30)))|((02)[/]((0[1-9])|([1-2][0-9]))))[/]\d{4}$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="TelecheckSignerName" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:maxLength value="24" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="TelecheckSignerTitle" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:enumeration value="1" />
//                     <xs:enumeration value="2" />
//                     <xs:enumeration value="3" />
//                     <xs:enumeration value="4" />
//                     <xs:enumeration value="5" />
//                     <xs:enumeration value="6" />
//                     <xs:enumeration value="7" />
//                     <xs:enumeration value="8" />
//                     <xs:enumeration value="" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="TelecheckDateSigned" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:pattern value="^$|^((((0[13578])|(1[02]))[/]((0[1-9])|([1-2][0-9])|(3[01])))|(((0[469])|(11))[/]((0[1-9])|([1-2][0-9])|(30)))|((02)[/]((0[1-9])|([1-2][0-9]))))[/]\d{4}$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="0" maxOccurs="1" name="TelecheckSignatureID" nillable="true" type="xs:long" />
//               <xs:element minOccurs="1" maxOccurs="1" name="GuaranteeSignerName1" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:maxLength value="24" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="GuaranteeSignerTitle1" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:enumeration value="1" />
//                     <xs:enumeration value="2" />
//                     <xs:enumeration value="3" />
//                     <xs:enumeration value="4" />
//                     <xs:enumeration value="5" />
//                     <xs:enumeration value="6" />
//                     <xs:enumeration value="7" />
//                     <xs:enumeration value="8" />
//                     <xs:enumeration value="" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="GuaranteeDateSigned1" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:pattern value="^$|^((((0[13578])|(1[02]))[/]((0[1-9])|([1-2][0-9])|(3[01])))|(((0[469])|(11))[/]((0[1-9])|([1-2][0-9])|(30)))|((02)[/]((0[1-9])|([1-2][0-9]))))[/]\d{4}$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="GuaranteeSignerName2" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:maxLength value="24" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="GuaranteeSignerTitle2" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:enumeration value="1" />
//                     <xs:enumeration value="2" />
//                     <xs:enumeration value="3" />
//                     <xs:enumeration value="4" />
//                     <xs:enumeration value="5" />
//                     <xs:enumeration value="6" />
//                     <xs:enumeration value="7" />
//                     <xs:enumeration value="8" />
//                     <xs:enumeration value="" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//               <xs:element minOccurs="1" maxOccurs="1" name="GuaranteeDateSigned2" nillable="true">
//                 <xs:simpleType>
//                   <xs:restriction base="xs:string">
//                     <xs:pattern value="^$|^((((0[13578])|(1[02]))[/]((0[1-9])|([1-2][0-9])|(3[01])))|(((0[469])|(11))[/]((0[1-9])|([1-2][0-9])|(30)))|((02)[/]((0[1-9])|([1-2][0-9]))))[/]\d{4}$" />
//                   </xs:restriction>
//                 </xs:simpleType>
//               </xs:element>
//             </xs:sequence>
//           </xs:complexType>
//         </xs:element>
//         <xs:element minOccurs="1" maxOccurs="1" name="MpaOutletInfo">
//           <xs:complexType>
//             <xs:sequence>
//               <xs:element minOccurs="1" maxOccurs="99" name="Outlet">
//                 <xs:complexType>
//                   <xs:sequence>
//                     <xs:element name="BusinessInfo">
//                       <xs:complexType>
//                         <xs:sequence>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MerchantNumber" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="13" />
//                                 <xs:maxLength value="16" />
//                                 <xs:pattern value="^[0-9]{13}$|[0-9]{15}$|[0-9]{16}$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AssessmentCode" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="CashAdvanceDescription" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="LocationName">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="30" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="LocationAddress1">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="24" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="LocationAddress2" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="24" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="LocationAddress3" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="38" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="LocationAddress4" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="38" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="Suite" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="24" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="City">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="18" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="State">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="AK" />
//                                 <xs:enumeration value="AL" />
//                                 <xs:enumeration value="AR" />
//                                 <xs:enumeration value="AZ" />
//                                 <xs:enumeration value="CA" />
//                                 <xs:enumeration value="CO" />
//                                 <xs:enumeration value="CT" />
//                                 <xs:enumeration value="DC" />
//                                 <xs:enumeration value="DE" />
//                                 <xs:enumeration value="FL" />
//                                 <xs:enumeration value="GA" />
//                                 <xs:enumeration value="HI" />
//                                 <xs:enumeration value="IA" />
//                                 <xs:enumeration value="ID" />
//                                 <xs:enumeration value="IL" />
//                                 <xs:enumeration value="IN" />
//                                 <xs:enumeration value="KS" />
//                                 <xs:enumeration value="KY" />
//                                 <xs:enumeration value="LA" />
//                                 <xs:enumeration value="MA" />
//                                 <xs:enumeration value="MD" />
//                                 <xs:enumeration value="ME" />
//                                 <xs:enumeration value="MI" />
//                                 <xs:enumeration value="MN" />
//                                 <xs:enumeration value="MO" />
//                                 <xs:enumeration value="MS" />
//                                 <xs:enumeration value="MT" />
//                                 <xs:enumeration value="NC" />
//                                 <xs:enumeration value="ND" />
//                                 <xs:enumeration value="NE" />
//                                 <xs:enumeration value="NH" />
//                                 <xs:enumeration value="NJ" />
//                                 <xs:enumeration value="NM" />
//                                 <xs:enumeration value="NV" />
//                                 <xs:enumeration value="NY" />
//                                 <xs:enumeration value="OH" />
//                                 <xs:enumeration value="OK" />
//                                 <xs:enumeration value="OR" />
//                                 <xs:enumeration value="PA" />
//                                 <xs:enumeration value="PR" />
//                                 <xs:enumeration value="RI" />
//                                 <xs:enumeration value="SC" />
//                                 <xs:enumeration value="SD" />
//                                 <xs:enumeration value="TN" />
//                                 <xs:enumeration value="TX" />
//                                 <xs:enumeration value="UT" />
//                                 <xs:enumeration value="VA" />
//                                 <xs:enumeration value="VI" />
//                                 <xs:enumeration value="VT" />
//                                 <xs:enumeration value="WA" />
//                                 <xs:enumeration value="WI" />
//                                 <xs:enumeration value="WV" />
//                                 <xs:enumeration value="WY" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="First5Zip">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="5" />
//                                 <xs:maxLength value="5" />
//                                 <xs:pattern value="[0-9]+" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="Last4Zip" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="4" />
//                                 <xs:maxLength value="4" />
//                                 <xs:pattern value="[0-9]*" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="LocationPhone">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:pattern value="^\(?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\)?\D?[2-9][0-9]{2}\D?[0-9]{4}$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="LocationFax" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:pattern value="(^\D?(\d{3})\D?\D?(\d{3})\D?(\d{4})$)*" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="BusinessEmailAddress">
//                           <xs:simpleType>
//                             <xs:restriction base="xs:string">
//                               <xs:maxLength value="40" />
//                              <xs:pattern value="^[a-zA-Z0-9]+([.'_-]\w*)*@([\-|\w|_])+([-.]\w+)*\.\w+([-.]\w+)*$" />
//                             </xs:restriction>
//                           </xs:simpleType>
//                          </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="BusinessWebsiteAddress" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="40" />
//                                 <xs:pattern value="^((http|https|ftp|www)://)?([a-zA-Z0-9]+(\.[a-zA-Z0-9]+)+.*)$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="CustomerServicePhone">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:pattern value="^\(?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\)?\D?[2-9][0-9]{2}\D?[0-9]{4}$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="CustomerServiceEmail" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="40" />
//                                 <xs:pattern value="^\w+([.'_-]\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="Sic" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="4" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="BusinessCategory" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                                 <xs:enumeration value="6" />
//                                 <xs:enumeration value="7" />
//                                 <xs:enumeration value="8" />
//                                 <xs:enumeration value="9" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="NextReviewDate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:pattern value="((^0[1-9])|(^1[0-2]))\/[0-9]{2}$" />
//                                 <xs:pattern value="((^0[1-9])|(^1[0-2]))\/[0-9]{2}$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DoingBusinessAsBankcardName" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="25" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DoingBusinessAsBankcardCity" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="13" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DoingBusinessAsBankcardState" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="AK" />
//                                 <xs:enumeration value="AL" />
//                                 <xs:enumeration value="AR" />
//                                 <xs:enumeration value="AZ" />
//                                 <xs:enumeration value="CA" />
//                                 <xs:enumeration value="CO" />
//                                 <xs:enumeration value="CT" />
//                                 <xs:enumeration value="DC" />
//                                 <xs:enumeration value="DE" />
//                                 <xs:enumeration value="FL" />
//                                 <xs:enumeration value="GA" />
//                                 <xs:enumeration value="HI" />
//                                 <xs:enumeration value="IA" />
//                                 <xs:enumeration value="ID" />
//                                 <xs:enumeration value="IL" />
//                                 <xs:enumeration value="IN" />
//                                 <xs:enumeration value="KS" />
//                                 <xs:enumeration value="KY" />
//                                 <xs:enumeration value="LA" />
//                                 <xs:enumeration value="MA" />
//                                 <xs:enumeration value="MD" />
//                                 <xs:enumeration value="ME" />
//                                 <xs:enumeration value="MI" />
//                                 <xs:enumeration value="MN" />
//                                 <xs:enumeration value="MO" />
//                                 <xs:enumeration value="MS" />
//                                 <xs:enumeration value="MT" />
//                                 <xs:enumeration value="NC" />
//                                 <xs:enumeration value="ND" />
//                                 <xs:enumeration value="NE" />
//                                 <xs:enumeration value="NH" />
//                                 <xs:enumeration value="NJ" />
//                                 <xs:enumeration value="NM" />
//                                 <xs:enumeration value="NV" />
//                                 <xs:enumeration value="NY" />
//                                 <xs:enumeration value="OH" />
//                                 <xs:enumeration value="OK" />
//                                 <xs:enumeration value="OR" />
//                                 <xs:enumeration value="PA" />
//                                 <xs:enumeration value="PR" />
//                                 <xs:enumeration value="RI" />
//                                 <xs:enumeration value="SC" />
//                                 <xs:enumeration value="SD" />
//                                 <xs:enumeration value="TN" />
//                                 <xs:enumeration value="TX" />
//                                 <xs:enumeration value="UT" />
//                                 <xs:enumeration value="VA" />
//                                 <xs:enumeration value="VI" />
//                                 <xs:enumeration value="VT" />
//                                 <xs:enumeration value="WA" />
//                                 <xs:enumeration value="WI" />
//                                 <xs:enumeration value="WV" />
//                                 <xs:enumeration value="WY" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="Retail" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="40" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="ProductsSold" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="24" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="FederalTaxIdType">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="1" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="FederalTaxId">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="9" />
//                                 <xs:maxLength value="9" />
//                                 <xs:pattern value="[0-9]+" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="IrsName">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="40" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="ForeignEntityOrNonResidentAlien" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="FinancialsFor2YearsProvided" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="IrsW9Provided" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="Attention">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="15" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="TechnicalContact" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="80" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="TechnicalContactPhone" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:pattern value="(^\D?(\d{3})\D?\D?(\d{3})\D?(\d{4})$)*" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="TechnicalContactEmail" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="40" />
//                                 <xs:pattern value="^[a-zA-Z0-9]+([.'_-]\w*)*@([\-|\w|_])+([-.]\w+)*\.\w+([-.]\w+)*$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                         </xs:sequence>
//                       </xs:complexType>
//                     </xs:element>
//                     <xs:element name="SiteInfo" minOccurs="0" maxOccurs="1" nillable="true">
//                       <xs:complexType>
//                         <xs:sequence>
//                           <xs:element minOccurs="0" maxOccurs="1" name="SiteVisitation" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="" />
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="Zone" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="Location" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                                 <xs:enumeration value="6" />
//                                 <xs:enumeration value="7" />
//                                 <xs:enumeration value="8" />
//                                 <xs:enumeration value="9" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="LocationOther" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="30" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="NoOfEmployees"  nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:int">
//                                 <xs:minInclusive value="1" />
//                                 <xs:maxInclusive value="999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="NoOfRegister" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:int">
//                                 <xs:minInclusive value="1" />
//                                 <xs:maxInclusive value="999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisableLicense" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="" />
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="NotVisableLicReason" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="40" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MerchantNameSiteDisplay" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="StoreLocatedOn" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="FloorNumber" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:int">
//                                 <xs:pattern value="[0-9]*" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="NumberOfLevels" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="OtherOccupiedBy" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="SquareFootage" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DepositRequired" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="" />
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DepositPercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:double">
//                                 <xs:pattern value="^100$|^\d{0,2}$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="ReturnPolicy">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="RefundPolicy">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="RefundType" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="RefPolicyRefDays">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                         </xs:sequence>
//                       </xs:complexType>
//                     </xs:element>
//                     <xs:element name="MotoBBInet" minOccurs="0" maxOccurs="1" nillable="true">
//                       <xs:complexType>
//                         <xs:sequence>
//                           <xs:element minOccurs="1" maxOccurs="1" name="MOTO">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="TransDeliveredIn07" type="xs:double" />
//                           <xs:element minOccurs="1" maxOccurs="1" name="TransDeliveredIn814" type="xs:double" />
//                           <xs:element minOccurs="1" maxOccurs="1" name="TransDeliveredIn1530" type="xs:double" />
//                           <xs:element minOccurs="1" maxOccurs="1" name="TransDeliveredOver30" type="xs:double" />
//                           <xs:element minOccurs="1" maxOccurs="1" name="CCSalesProcessedAt">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="OtherInfo" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="50" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="CardholderBilling" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                         </xs:sequence>
//                       </xs:complexType>
//                     </xs:element>
//                     <xs:element name="Settlement">
//                       <xs:complexType>
//                         <xs:sequence>
//                           <xs:element minOccurs="1" maxOccurs="1" name="DepositBankName">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="30" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="AccountType">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="TransitABANumber">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="9" />
//                                 <xs:maxLength value="9" />
//                                 <xs:pattern value="[0-9]+" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="DepositAccountNumber">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="1" />
//                                 <xs:maxLength value="17" />
//                                 <xs:pattern value="[0-9]+" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="AchDetailFlag">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AllowNegativeIncomeRefValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="50" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DaysHoldACH" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:int">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="FloatFlagRefValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="50" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DepositFloatDays" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:int">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="9" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AlternateAccountTypeRefValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="70" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AlternateTransitABANumber" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="9" />
//                                 <xs:maxLength value="9" />
//                                 <xs:pattern value="[0-9]+" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AlternateDepositAccountNumber" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="17" />
//                                 <xs:pattern value="[0-9]+" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AlternateDepositMedia" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DisbursementDaily_DepositRefValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="70" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DisbursementDaily_AdjustmentRefValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="70" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DisbursementDaily_DiscountRefValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="70" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DisbursementDaily_DebitRefValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="70" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VoidedCheckProvided" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                         </xs:sequence>
//                       </xs:complexType>
//                     </xs:element>
//                     <xs:element name="Processing">
//                       <xs:complexType>
//                         <xs:sequence>
//                           <xs:element minOccurs="1" maxOccurs="1" name="DepositType">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="Type">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                                 <xs:enumeration value="6" />
//                                 <xs:enumeration value="7" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="EtcCutoff">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="EtcBypassIndicator">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="PosFlags" type="xs:string" />
//                           <xs:element minOccurs="1" maxOccurs="1" name="VisaAggregator">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                                 <xs:enumeration value="6" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="GGe4Indicator">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="GGe4EffectiveDate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:pattern value="^$|^((((0[13578])|(1[02]))[/]((0[1-9])|([1-2][0-9])|(3[01])))|(((0[469])|(11))[/]((0[1-9])|([1-2][0-9])|(30)))|((02)[/]((0[1-9])|([1-2][0-9]))))[/]\d{4}$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="TransArmorServiceCode">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                          <xs:element minOccurs="1" maxOccurs="1" name="EncryptionType">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                                 <xs:enumeration value="6" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="TokenIndicator">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="HelpCenter">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                                 <xs:enumeration value="6" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="MastercardCatIndicator">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="VisaCatIndicator">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="5" />
//                                 <xs:enumeration value="6" />
//                                 <xs:enumeration value="7" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="DiscoverIndustryIndicator">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="FinalAuthIndicator">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="EidsIndicator" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="CommercialCardInterchangeService" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="" />
//                                 <xs:enumeration value="N" />
//                                 <xs:enumeration value="Y" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MiscField" nillable="true" type="xs:string" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="MiscField1" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="3" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="ThirdPartyProcessor">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="00" />
//                                 <xs:enumeration value="01" />
//                                 <xs:enumeration value="02" />
//                                 <xs:enumeration value="03" />
//                                 <xs:enumeration value="04" />
//                                 <xs:enumeration value="05" />
//                                 <xs:enumeration value="06" />
//                                 <xs:enumeration value="07" />
//                                 <xs:enumeration value="08" />
//                                 <xs:enumeration value="09" />
//                                 <xs:enumeration value="10" />
//                                 <xs:enumeration value="99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="ThirdPartyProcessorName" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="25" />
//                                 <xs:pattern value="^$|^[0-9a-zA-Z ]+$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DataAnalyticsIndicator" nillable="true" type="xs:string" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="DataAnalyticsProductType" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="TapeReferenceFlag" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="80" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="SpecialFlag1" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="1" />
//                                 <xs:pattern value="^[A-Z0-9]$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="SpecialFlag2" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="1" />
//                                 <xs:pattern value="^[A-Z0-9]$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="SpecialFlag3" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="1" />
//                                 <xs:pattern value="^[A-Z0-9]$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="SpecialFlag4" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="1" />
//                                 <xs:pattern value="^[A-Z0-9]$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="SpecialFlag5" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="1" />
//                                 <xs:pattern value="^[A-Z0-9]$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="SpecialFlag6" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="1" />
//                                 <xs:pattern value="^[A-Z0-9]$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="SpecialFlag7" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="1" />
//                                 <xs:pattern value="^[A-Z0-9]$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="SpecialFlag8" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="1" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MerchantVerificationValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="10" />
//                                 <xs:maxLength value="10" />
//                                 <xs:pattern value="^[A-F0-9]+$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCAssignedID" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="6" />
//                                 <xs:maxLength value="6" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VISABusinessID" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="8" />
//                                 <xs:maxLength value="8" />
//                                 <xs:pattern value="^\d+$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="MCSecurityProtocolID" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="CloverSecurityIndicator" type="xs:string" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccessOneAutoOptIn" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="EmailThatThePasswordSentTo" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="100" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MaximumNumberOfSecondaryUsers" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:int">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="1000" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                         </xs:sequence>
//                       </xs:complexType>
//                     </xs:element>
//                     <xs:element name="Transaction" nillable="true" minOccurs="0" maxOccurs="1">
//                       <xs:complexType>
//                         <xs:sequence>
//                           <xs:element minOccurs="1" maxOccurs="1" name="TotalAnnualSalesVolume" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="1000" />
//                                 <xs:maxInclusive value="999999999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="AnnualMcViSalesVolume" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="1000" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AnnualDiSalesVolume" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="1000" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AnnualAmexOnePointSalesVolume" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="1000" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AvgMcViDiTicket" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="1" />
//                                 <xs:maxInclusive value="99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="HighestTicket" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="SeasonalMerchant">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="SeasonalFrom" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:int">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="10" />
//                                 <xs:enumeration value="11" />
//                                 <xs:enumeration value="12" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                                 <xs:enumeration value="6" />
//                                 <xs:enumeration value="7" />
//                                 <xs:enumeration value="8" />
//                                 <xs:enumeration value="9" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="SeasonalTo" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:int">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="10" />
//                                 <xs:enumeration value="11" />
//                                 <xs:enumeration value="12" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                                 <xs:enumeration value="6" />
//                                 <xs:enumeration value="7" />
//                                 <xs:enumeration value="8" />
//                                 <xs:enumeration value="9" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="CcPercentPos" type="xs:int" />
//                           <xs:element minOccurs="1" maxOccurs="1" name="CcPercentInet" type="xs:int" />
//                           <xs:element minOccurs="1" maxOccurs="1" name="CcPercentMo" type="xs:int" />
//                           <xs:element minOccurs="1" maxOccurs="1" name="CcPercentTo" type="xs:int" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="UnderwritingComments" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="66" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                         </xs:sequence>
//                       </xs:complexType>
//                     </xs:element>
//                     <xs:element name="Pricing" nillable="true" minOccurs="0" maxOccurs="1">
//                       <xs:complexType>
//                         <xs:sequence>
//                           <xs:element minOccurs="0" maxOccurs="1" name="EnableMCCredit" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="EnableMCDebit" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="EnableVisaCredit" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="EnableVisaDebit" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="EnableDiscoverCredit" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="EnableDiscoverDebit" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="EnablePayPal" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCCreditMerchantPricing_GridLevel" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCCreditMerchantPricing_GridValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCCreditTieredDiscount_GridLevel" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCCreditTieredDiscount_GridValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCDebitMerchantPricing_GridLevel" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCDebitMerchantPricing_GridValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCDebitTieredDiscount_GridLevel" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCDebitTieredDiscount_GridValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaCreditMerchantPricing_GridLevel" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaCreditMerchantPricing_GridValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaCreditTieredDiscount_GridLevel" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaCreditTieredDiscount_GridValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaDebitMerchantPricing_GridLevel" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaDebitMerchantPricing_GridValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaDebitTieredDiscount_GridLevel" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaDebitTieredDiscount_GridValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverCreditMerchantPricing_GridLevel" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverCreditMerchantPricing_GridValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverCreditTieredDiscount_GridLevel" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverCreditTieredDiscount_GridValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverDebitMerchantPricing_GridLevel" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverDebitMerchantPricing_GridValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverDebitTieredDiscount_GridLevel" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverDebitTieredDiscount_GridValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="BundledPricingType" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                                 <xs:enumeration value="6" />
//                                 <xs:enumeration value="7" />
//                                 <xs:enumeration value="8" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscountMethod" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="10" />
//                                 <xs:enumeration value="11" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                                 <xs:enumeration value="6" />
//                                 <xs:enumeration value="7" />
//                                 <xs:enumeration value="8" />
//                                 <xs:enumeration value="9" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="StatementInterchangePrintOption" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscountCalcFlag" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="70" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="10" />
//                                 <xs:enumeration value="11" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                                 <xs:enumeration value="6" />
//                                 <xs:enumeration value="7" />
//                                 <xs:enumeration value="8" />
//                                 <xs:enumeration value="9" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="BundleOption">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="EnablePinDebitCard" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="PassThruDebitNtwkFees" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="StmntOnlDebitPrintOpt" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="GenericRate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="GenericVolumePercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:double">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="StarRate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="StarVolumePercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:double">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="Star18Rate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="Star18VolumePercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:double">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="Star21Rate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="Star21VolumePercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:double">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MaestroRate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MaestroVolumePercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:double">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="InterlinkRate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="InterlinkVolumePercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:double">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="NyceRate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="NyceVolumePercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:double">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="ShazamRate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="ShazamVolumePercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:double">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="PulseRate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="PulseVolumePercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:double">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccelRate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccelVolumePercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:double">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="Cu24Rate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="Cu24VolumePercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:double">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AffnRate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AffnVolumePercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:double">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AlaskaOptionRate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AlaskaOptionVolumePercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:double">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="JeanieRate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="JeanieVolumePercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:double">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="BundleMCCreditFeeClass" nillable="true" type="xs:string" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="BundleMCDebitFeeClass" nillable="true" type="xs:string" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="BundleVisaCreditFeeClass" nillable="true" type="xs:string" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="BundleVisaDebitFeeClass" nillable="true" type="xs:string" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="BundleDiscoverCreditFeeClass" nillable="true" type="xs:string" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="BundleDiscoverDebitFeeClass" nillable="true" type="xs:string" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="BundlePercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:double">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="BundleRate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="BundleERRNonQual" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="9.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="RegulatedERRNonQual" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="9.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="RegulatedPercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:double">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="RegulatedRate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="UnregulatedPercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:double">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="UnregulatedRate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCCreditPricingType" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="3" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCCreditFeeClass" nillable="true" type="xs:string" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCCreditWholesaleInterchangeFeeFlag" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="70" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCCreditRetailInterchangeFeeFlag" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="70" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCCreditQualCredit_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCCreditMidQualCredit_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCCreditNonQualCredit_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCCreditNonQualFeesERR_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="9.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCCreditOtherItemRate_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCCreditOtherVolumePercent_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCDebitPricingType" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="3" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCDebitFeeClass" nillable="true" type="xs:string" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCDebitWholesaleInterchangeFeeFlag" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="70" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCDebitRetailInterchangeFeeFlag" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="10" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCDebitQualDebit_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCDebitMidQualDebit_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCDebitNonQualDebit_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCDebitNonQualFeesERR_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="9.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCDebitOtherItemRate_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCDebitOtherVolumePercent_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCDebitRegulatedERRFlag" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaCreditPricingType" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="3" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaCreditFeeClass" nillable="true" type="xs:string" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaCreditWholesaleInterchangeFeeFlag" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="70" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaCreditRetailInterchangeFeeFlag" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="10" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaCreditQualCredit_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaCreditMidQualCredit_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaCreditNonQualCredit_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaCreditNonQualFeesERR_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="9.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaCreditOtherItemRate_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaCreditOtherVolumePercent_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaDebitPricingType" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="3" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaDebitFeeClass" nillable="true" type="xs:string" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaDebitWholesaleInterchangeFeeFlag" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="70" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaDebitRetailInterchangeFeeFlag" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="70" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaDebitQualDebit_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaDebitMidQualDebit_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaDebitNonQualDebit_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaDebitNonQualFeesERR_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="9.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaDebitOtherItemRate_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaDebitOtherVolumePercent_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaDebitRegulatedERRFlag" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VisaTaxExempt501C" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="" />
//                                 <xs:enumeration value="N" />
//                                 <xs:enumeration value="Y" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverCreditPricingType" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="3" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverCreditFeeClass" nillable="true" type="xs:string" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverCreditWholesaleInterchangeFeeFlag" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="70" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverCreditRetailInterchangeFeeFlag" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="10" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverCreditQualCredit_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverCreditMidQualCredit_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverCreditNonQualCredit_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverCreditNonQualFeesERR_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="9.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverCreditOtherItemRate_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverCreditOtherVolumePercent_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverDebitPricingType" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="3" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverDebitFeeClass" nillable="true" type="xs:string" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverDebitWholesaleInterchangeFeeFlag" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="70" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverDebitRetailInterchangeFeeFlag" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="10" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverDebitQualDebit_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverDebitMidQualDebit_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverDebitNonQualDebit_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverDebitNonQualFeesERR_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="9.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverDebitOtherItemRate_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverDebitOtherVolumePercent_Discount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverDebitRegulatedERRFlag" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                            <xs:element minOccurs="0" maxOccurs="1" name="DebtRepaymentIndicator" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="" />
//                                 <xs:enumeration value="N" />
//                                 <xs:enumeration value="Y" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="PaypalOptOutReason" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="02" />
//                                 <xs:enumeration value="03" />
//                                 <xs:enumeration value="04" />
//                                 <xs:enumeration value="05" />
//                                 <xs:enumeration value="99" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                         </xs:sequence>
//                       </xs:complexType>
//                     </xs:element>
//                     <xs:element name="Entitlement" nillable="true" minOccurs="0" maxOccurs="1">
//                       <xs:complexType>
//                         <xs:sequence>
//                           <xs:element minOccurs="1" maxOccurs="1" name="AmexEntitlement" type="xs:boolean" />
//                           <xs:element minOccurs="1" maxOccurs="1" name="AmexOption" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="AmexSeNumber" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="10" />
//                                 <xs:maxLength value="10" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="AmexVolumeAmericaExpress" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="1000" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="AmexOtherItemRate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="AmexOtherVolumePercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:double">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="AmexIATANumber" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="8" />
//                                 <xs:maxLength value="8" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="AmexIATANumberAmericaExpress" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="8" />
//                                 <xs:maxLength value="8" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AmexInterchangeFeeFlag" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="3" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="AmexFeeClass" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="500" />
//                                 <xs:enumeration value="501" />
//                                 <xs:enumeration value="502" />
//                                 <xs:enumeration value="518" />
//                                 <xs:enumeration value="519" />
//                                 <xs:enumeration value="520" />
//                                 <xs:enumeration value="524" />
//                                 <xs:enumeration value="525" />
//                                 <xs:enumeration value="526" />
//                                 <xs:enumeration value="530" />
//                                 <xs:enumeration value="531" />
//                                 <xs:enumeration value="532" />
//                                 <xs:enumeration value="536" />
//                                 <xs:enumeration value="537" />
//                                 <xs:enumeration value="538" />
//                                 <xs:enumeration value="542" />
//                                 <xs:enumeration value="543" />
//                                 <xs:enumeration value="544" />
//                                 <xs:enumeration value="548" />
//                                 <xs:enumeration value="549" />
//                                 <xs:enumeration value="550" />
//                                 <xs:enumeration value="554" />
//                                 <xs:enumeration value="555" />
//                                 <xs:enumeration value="556" />
//                                 <xs:enumeration value="560" />
//                                 <xs:enumeration value="561" />
//                                 <xs:enumeration value="562" />
//                                 <xs:enumeration value="569" />
//                                 <xs:enumeration value="570" />
//                                 <xs:enumeration value="571" />
//                                 <xs:enumeration value="646" />
//                                 <xs:enumeration value="647" />
//                                 <xs:enumeration value="648" />
//                                 <xs:enumeration value="658" />
//                                 <xs:enumeration value="659" />
//                                 <xs:enumeration value="660" />
//                                 <xs:enumeration value="670" />
//                                 <xs:enumeration value="671" />
//                                 <xs:enumeration value="672" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="WholeSaleInterchangeFeeFlag" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="70" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="AmexMerchantPricingGrid" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="AmexMerchantPricingCode" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="AmexTieredDiscountGrid" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="AmexTieredDiscountGridCode" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="AmexDiscountQual" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="AmexDiscountMidQual" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="AmexDiscountNonQual" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="AmexERRDiscountNonQual" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="9.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="AmexOtherItemRateNotESA" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="AmexOtherVolumePercentNotESA" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="HasDiscoverPassThru" type="xs:boolean" />
//                           <xs:element minOccurs="1" maxOccurs="1" name="DiscoverPassThruSENumber" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="15" />
//                                 <xs:maxLength value="15" />
//                                 <xs:pattern value="^6011?\d+$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="DiscoverPassThruOtherItemRate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="DiscoverPassThruOtherVolume" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="EbtEntitlement" type="xs:boolean" />
//                           <xs:element minOccurs="1" maxOccurs="1" name="EbtStateFnsNumber" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="7" />
//                                 <xs:maxLength value="7" />
//                                 <xs:pattern value="^[0-9]+$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="EbtFoodStampOtherItemRate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="EbtCashBenefitOtherItemRate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="EbtTapeOtherItemRate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="EbtFoodStamps" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="1" maxOccurs="1" name="EbtCashBenefits" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="1" maxOccurs="1" name="EbtTape3rdParty" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="1" maxOccurs="1" name="VoyagerEntitlement" type="xs:boolean" />
//                           <xs:element minOccurs="1" maxOccurs="1" name="VoyagerQualDiscountPercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:double">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="VoyagerOtherItemRate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="WrightExEntitlement" type="xs:boolean" />
//                           <xs:element minOccurs="1" maxOccurs="1" name="WrightExOtherItemRate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:double">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="TeleCheckEntitlement" type="xs:boolean" />
//                           <xs:element minOccurs="1" maxOccurs="1" name="TeleCheckServiceType" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="TeleCheckInquiryRate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="TeleCheckPerTxnFee" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="TeleCheckMonthlyMinimum" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AmexOptBlueAuthorizedSignerSameAsFirstOwner" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="AmexOptBlueAuthorizedSignerFirstName" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="20" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AmexOptBlueAuthorizedSignerLastName" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="20" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AmexOptBlueAuthorizedSignerTitle" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="10" />
//                                 <xs:enumeration value="11" />
//                                 <xs:enumeration value="12" />
//                                 <xs:enumeration value="13" />
//                                 <xs:enumeration value="14" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                                 <xs:enumeration value="6" />
//                                 <xs:enumeration value="7" />
//                                 <xs:enumeration value="8" />
//                                 <xs:enumeration value="9" />
//                                 <xs:enumeration value="99" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AmexOptBlueAuthorizedSignerOtherTitle" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="20" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                            <xs:element minOccurs="0" maxOccurs="1" name="AmexOptBlueAuthorizedSignerDOB" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:pattern value="^$|^((((0[13578])|(1[02]))[/]((0[1-9])|([1-2][0-9])|(3[01])))|(((0[469])|(11))[/]((0[1-9])|([1-2][0-9])|(30)))|((02)[/]((0[1-9])|([1-2][0-9]))))[/]\d{4}$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AmexOptBlueAuthorizedSignerCountryCode" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="50" />
//                                 <xs:enumeration value="" />
//                                 <xs:enumeration value="AD" />
//                                 <xs:enumeration value="AE" />
//                                 <xs:enumeration value="AF" />
//                                 <xs:enumeration value="AG" />
//                                 <xs:enumeration value="AI" />
//                                 <xs:enumeration value="AL" />
//                                 <xs:enumeration value="AM" />
//                                 <xs:enumeration value="AN" />
//                                 <xs:enumeration value="AO" />
//                                 <xs:enumeration value="AQ" />
//                                 <xs:enumeration value="AR" />
//                                 <xs:enumeration value="AS" />
//                                 <xs:enumeration value="AT" />
//                                 <xs:enumeration value="AU" />
//                                 <xs:enumeration value="AW" />
//                                 <xs:enumeration value="AX" />
//                                 <xs:enumeration value="AZ" />
//                                 <xs:enumeration value="BA" />
//                                 <xs:enumeration value="BB" />
//                                 <xs:enumeration value="BD" />
//                                 <xs:enumeration value="BE" />
//                                 <xs:enumeration value="BF" />
//                                 <xs:enumeration value="BG" />
//                                 <xs:enumeration value="BH" />
//                                 <xs:enumeration value="BI" />
//                                 <xs:enumeration value="BJ" />
//                                 <xs:enumeration value="BL" />
//                                 <xs:enumeration value="BM" />
//                                 <xs:enumeration value="BN" />
//                                 <xs:enumeration value="BO" />
//                                 <xs:enumeration value="BQ" />
//                                 <xs:enumeration value="BR" />
//                                 <xs:enumeration value="BS" />
//                                 <xs:enumeration value="BT" />
//                                 <xs:enumeration value="BV" />
//                                 <xs:enumeration value="BW" />
//                                 <xs:enumeration value="BY" />
//                                 <xs:enumeration value="BZ" />
//                                 <xs:enumeration value="CA" />
//                                 <xs:enumeration value="CC" />
//                                 <xs:enumeration value="CD" />
//                                 <xs:enumeration value="CF" />
//                                 <xs:enumeration value="CG" />
//                                 <xs:enumeration value="CH" />
//                                 <xs:enumeration value="CI" />
//                                 <xs:enumeration value="CK" />
//                                 <xs:enumeration value="CL" />
//                                 <xs:enumeration value="CM" />
//                                 <xs:enumeration value="CN" />
//                                 <xs:enumeration value="CO" />
//                                 <xs:enumeration value="CR" />
//                                 <xs:enumeration value="CV" />
//                                 <xs:enumeration value="CW" />
//                                 <xs:enumeration value="CX" />
//                                 <xs:enumeration value="CY" />
//                                 <xs:enumeration value="CZ" />
//                                 <xs:enumeration value="DE" />
//                                 <xs:enumeration value="DJ" />
//                                 <xs:enumeration value="DK" />
//                                 <xs:enumeration value="DM" />
//                                 <xs:enumeration value="DO" />
//                                 <xs:enumeration value="DZ" />
//                                 <xs:enumeration value="EC" />
//                                 <xs:enumeration value="EE" />
//                                 <xs:enumeration value="EG" />
//                                 <xs:enumeration value="EH" />
//                                 <xs:enumeration value="ER" />
//                                 <xs:enumeration value="ES" />
//                                 <xs:enumeration value="ET" />
//                                 <xs:enumeration value="FI" />
//                                 <xs:enumeration value="FJ" />
//                                 <xs:enumeration value="FK" />
//                                 <xs:enumeration value="FM" />
//                                 <xs:enumeration value="FO" />
//                                 <xs:enumeration value="FR" />
//                                 <xs:enumeration value="GA" />
//                                 <xs:enumeration value="GB" />
//                                 <xs:enumeration value="GD" />
//                                 <xs:enumeration value="GE" />
//                                 <xs:enumeration value="GF" />
//                                 <xs:enumeration value="GG" />
//                                 <xs:enumeration value="GH" />
//                                 <xs:enumeration value="GI" />
//                                 <xs:enumeration value="GL" />
//                                 <xs:enumeration value="GM" />
//                                 <xs:enumeration value="GN" />
//                                 <xs:enumeration value="GP" />
//                                 <xs:enumeration value="GQ" />
//                                 <xs:enumeration value="GR" />
//                                 <xs:enumeration value="GS" />
//                                 <xs:enumeration value="GT" />
//                                 <xs:enumeration value="GU" />
//                                 <xs:enumeration value="GW" />
//                                 <xs:enumeration value="GY" />
//                                 <xs:enumeration value="HK" />
//                                 <xs:enumeration value="HM" />
//                                 <xs:enumeration value="HN" />
//                                 <xs:enumeration value="HR" />
//                                 <xs:enumeration value="HT" />
//                                 <xs:enumeration value="HU" />
//                                 <xs:enumeration value="ID" />
//                                 <xs:enumeration value="IE" />
//                                 <xs:enumeration value="IL" />
//                                 <xs:enumeration value="IM" />
//                                 <xs:enumeration value="IN" />
//                                 <xs:enumeration value="IO" />
//                                 <xs:enumeration value="IQ" />
//                                 <xs:enumeration value="IS" />
//                                 <xs:enumeration value="IT" />
//                                 <xs:enumeration value="JE" />
//                                 <xs:enumeration value="JM" />
//                                 <xs:enumeration value="JO" />
//                                 <xs:enumeration value="JP" />
//                                 <xs:enumeration value="KE" />
//                                 <xs:enumeration value="KG" />
//                                 <xs:enumeration value="KH" />
//                                 <xs:enumeration value="KI" />
//                                 <xs:enumeration value="KM" />
//                                 <xs:enumeration value="KN" />
//                                 <xs:enumeration value="KR" />
//                                 <xs:enumeration value="KW" />
//                                 <xs:enumeration value="KY" />
//                                 <xs:enumeration value="KZ" />
//                                 <xs:enumeration value="LA" />
//                                 <xs:enumeration value="LB" />
//                                 <xs:enumeration value="LC" />
//                                 <xs:enumeration value="LI" />
//                                 <xs:enumeration value="LK" />
//                                 <xs:enumeration value="LR" />
//                                 <xs:enumeration value="LS" />
//                                 <xs:enumeration value="LT" />
//                                 <xs:enumeration value="LU" />
//                                 <xs:enumeration value="LV" />
//                                 <xs:enumeration value="LY" />
//                                 <xs:enumeration value="MA" />
//                                 <xs:enumeration value="MC" />
//                                 <xs:enumeration value="MD" />
//                                 <xs:enumeration value="ME" />
//                                 <xs:enumeration value="MF" />
//                                 <xs:enumeration value="MG" />
//                                 <xs:enumeration value="MH" />
//                                 <xs:enumeration value="MK" />
//                                 <xs:enumeration value="ML" />
//                                 <xs:enumeration value="MM" />
//                                 <xs:enumeration value="MN" />
//                                 <xs:enumeration value="MO" />
//                                 <xs:enumeration value="MP" />
//                                 <xs:enumeration value="MQ" />
//                                 <xs:enumeration value="MR" />
//                                 <xs:enumeration value="MS" />
//                                 <xs:enumeration value="MT" />
//                                 <xs:enumeration value="MU" />
//                                 <xs:enumeration value="MV" />
//                                 <xs:enumeration value="MW" />
//                                 <xs:enumeration value="MX" />
//                                 <xs:enumeration value="MY" />
//                                 <xs:enumeration value="MZ" />
//                                 <xs:enumeration value="NA" />
//                                 <xs:enumeration value="NC" />
//                                 <xs:enumeration value="NE" />
//                                 <xs:enumeration value="NF" />
//                                 <xs:enumeration value="NG" />
//                                 <xs:enumeration value="NI" />
//                                 <xs:enumeration value="NL" />
//                                 <xs:enumeration value="NO" />
//                                 <xs:enumeration value="NP" />
//                                 <xs:enumeration value="NR" />
//                                 <xs:enumeration value="NU" />
//                                 <xs:enumeration value="NZ" />
//                                 <xs:enumeration value="OM" />
//                                 <xs:enumeration value="PA" />
//                                 <xs:enumeration value="PE" />
//                                 <xs:enumeration value="PF" />
//                                 <xs:enumeration value="PG" />
//                                 <xs:enumeration value="PH" />
//                                 <xs:enumeration value="PK" />
//                                 <xs:enumeration value="PL" />
//                                 <xs:enumeration value="PM" />
//                                 <xs:enumeration value="PN" />
//                                 <xs:enumeration value="PR" />
//                                 <xs:enumeration value="PS" />
//                                 <xs:enumeration value="PT" />
//                                 <xs:enumeration value="PW" />
//                                 <xs:enumeration value="PY" />
//                                 <xs:enumeration value="QA" />
//                                 <xs:enumeration value="RE" />
//                                 <xs:enumeration value="RO" />
//                                 <xs:enumeration value="RS" />
//                                 <xs:enumeration value="RU" />
//                                 <xs:enumeration value="RW" />
//                                 <xs:enumeration value="SA" />
//                                 <xs:enumeration value="SB" />
//                                 <xs:enumeration value="SC" />
//                                 <xs:enumeration value="SE" />
//                                 <xs:enumeration value="SG" />
//                                 <xs:enumeration value="SH" />
//                                 <xs:enumeration value="SI" />
//                                 <xs:enumeration value="SJ" />
//                                 <xs:enumeration value="SK" />
//                                 <xs:enumeration value="SL" />
//                                 <xs:enumeration value="SM" />
//                                 <xs:enumeration value="SN" />
//                                 <xs:enumeration value="SO" />
//                                 <xs:enumeration value="SR" />
//                                 <xs:enumeration value="SS" />
//                                 <xs:enumeration value="ST" />
//                                 <xs:enumeration value="SV" />
//                                 <xs:enumeration value="SX" />
//                                 <xs:enumeration value="SZ" />
//                                 <xs:enumeration value="TC" />
//                                 <xs:enumeration value="TD" />
//                                 <xs:enumeration value="TF" />
//                                 <xs:enumeration value="TG" />
//                                 <xs:enumeration value="TH" />
//                                 <xs:enumeration value="TJ" />
//                                 <xs:enumeration value="TK" />
//                                 <xs:enumeration value="TL" />
//                                 <xs:enumeration value="TM" />
//                                 <xs:enumeration value="TN" />
//                                 <xs:enumeration value="TO" />
//                                 <xs:enumeration value="TR" />
//                                 <xs:enumeration value="TT" />
//                                 <xs:enumeration value="TV" />
//                                 <xs:enumeration value="TW" />
//                                 <xs:enumeration value="TZ" />
//                                 <xs:enumeration value="UA" />
//                                 <xs:enumeration value="UG" />
//                                 <xs:enumeration value="UM" />
//                                 <xs:enumeration value="US" />
//                                 <xs:enumeration value="UY" />
//                                 <xs:enumeration value="UZ" />
//                                 <xs:enumeration value="VA" />
//                                 <xs:enumeration value="VC" />
//                                 <xs:enumeration value="VE" />
//                                 <xs:enumeration value="VG" />
//                                 <xs:enumeration value="VI" />
//                                 <xs:enumeration value="VN" />
//                                 <xs:enumeration value="VU" />
//                                 <xs:enumeration value="WF" />
//                                 <xs:enumeration value="WS" />
//                                 <xs:enumeration value="YE" />
//                                 <xs:enumeration value="YT" />
//                                 <xs:enumeration value="ZA" />
//                                 <xs:enumeration value="ZM" />
//                                 <xs:enumeration value="ZW" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                        </xs:sequence>
//                     </xs:complexType>
//                    </xs:element>
//                     <xs:element name="EquipmentFE" minOccurs="0" maxOccurs="1" nillable="true">
//                       <xs:complexType>
//                         <xs:sequence>
//                           <xs:element minOccurs="0" maxOccurs="1" name="Equipments" nillable="true">
//                             <xs:complexType>
//                               <xs:sequence>
//                                 <xs:element minOccurs="0" maxOccurs="999" name="Equipment" nillable="true">
//                                   <xs:complexType>
//                                     <xs:sequence>
//                                       <xs:element name="EquipmentTemplate" nillable="true">
//                                         <xs:complexType>
//                                           <xs:sequence>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="EquipmentTemplateFeature_TerminalClass" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="1" />
//                                                   <xs:enumeration value="2" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="EquipmentTemplateFeature_AutoClose" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="0" />
//                                                   <xs:enumeration value="1" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="EquipmentTemplateFeature_ConfirmBatchAmountOnSettlement" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="0" />
//                                                   <xs:enumeration value="1" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="EquipmentTemplateFeature_ManuallyKeyInvoiceNumber" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="0" />
//                                                   <xs:enumeration value="1" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="EquipmentTemplateFeature_PromptForOrderNumberOnManualEntry" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="0" />
//                                                   <xs:enumeration value="1" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="EquipmentTemplateFeature_EnableTransArmor" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="0" />
//                                                   <xs:enumeration value="1" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="EquipmentTemplateFeature_EnableIP" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="0" />
//                                                   <xs:enumeration value="1" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="EquipmentTemplateFeature_SettleWithUnadjustedTips" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="0" />
//                                                   <xs:enumeration value="1" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="EquipmentTemplateFeature_PrintReceiptWhenClosingTabs" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="0" />
//                                                   <xs:enumeration value="1" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="EquipmentTemplateFeature_BypassTipPromptOnSale" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="0" />
//                                                   <xs:enumeration value="1" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="EquipmentTemplateFeature_PromptForTipOnPINPad" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="0" />
//                                                   <xs:enumeration value="1" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="EquipmentTemplateFeature_GratuityGuide" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="0" />
//                                                   <xs:enumeration value="1" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="EquipmentTemplateFeature_ServerPrompt" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="0" />
//                                                   <xs:enumeration value="1" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="EquipmentTemplateFeature_PrintDetailReportOnSettlement" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="0" />
//                                                   <xs:enumeration value="1" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="EquipmentTemplateFeature_PromptForTipAfterSale" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="0" />
//                                                   <xs:enumeration value="1" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="EquipmentTemplateFeature_PromptForClerkNumber" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="0" />
//                                                   <xs:enumeration value="1" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="EquipmentTemplateFeature_TipOption" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="1" />
//                                                   <xs:enumeration value="2" />
//                                                   <xs:enumeration value="3" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="EquipmentTemplateFeature_SettlementReport" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="1" />
//                                                   <xs:enumeration value="2" />
//                                                   <xs:enumeration value="3" />
//                                                   <xs:enumeration value="4" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="EquipmentTemplateFeature_ServerMode" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="1" />
//                                                   <xs:enumeration value="2" />
//                                                   <xs:enumeration value="3" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="EquipmentTemplateFeature_CommunicationType" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="1" />
//                                                   <xs:enumeration value="2" />
//                                                   <xs:enumeration value="3" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="EquipmentTemplateFeature_InvoiceWording" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="1" />
//                                                   <xs:enumeration value="2" />
//                                                   <xs:enumeration value="3" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="EquipmentTemplateFeature_CarrierType" nillable="true" type="xs:string" />
//                                             <xs:element minOccurs="0" maxOccurs="1" name="EquipmentTemplateFeature_RadioESN" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:minLength value="8" />
//                                                   <xs:maxLength value="8" />
//                                                   <xs:pattern value="[0-9]+" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="EquipmentTemplateFeature_SimCardNumber" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:minLength value="20" />
//                                                   <xs:maxLength value="20" />
//                                                   <xs:pattern value="[0-9]+" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="EquipmentTemplateId" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:int">
//                                                   <xs:enumeration value="1" />
//                                                   <xs:enumeration value="2" />
//                                                   <xs:enumeration value="3" />
//                                                   <xs:enumeration value="4" />
//                                                   <xs:enumeration value="5" />
//                                                   <xs:enumeration value="6" />
//                                                   <xs:enumeration value="7" />
//                                                   <xs:enumeration value="8" />
//                                                   <xs:enumeration value="9" />
//                                                   <xs:enumeration value="10" />
//                                                   <xs:enumeration value="11" />
//                                                   <xs:enumeration value="12" />
//                                                   <xs:enumeration value="13" />
//                                                   <xs:enumeration value="100" />
//                                                   <xs:enumeration value="101" />
//                                                   <xs:enumeration value="102" />
//                                                   <xs:enumeration value="110" />
//                                                   <xs:enumeration value="111" />
//                                                   <xs:enumeration value="112" />
//                                                   <xs:enumeration value="120" />
//                                                   <xs:enumeration value="121" />
//                                                   <xs:enumeration value="150" />
//                                                   <xs:enumeration value="151" />
//                                                   <xs:enumeration value="152" />
//                                                   <xs:enumeration value="160" />
//                                                   <xs:enumeration value="161" />
//                                                   <xs:enumeration value="162" />
//                                                   <xs:enumeration value="163" />
//                                                   <xs:enumeration value="164" />
//                                                   <xs:enumeration value="165" />
//                                                   <xs:enumeration value="170" />
//                                                   <xs:enumeration value="171" />
//                                                   <xs:enumeration value="174" />
//                                                   <xs:enumeration value="175" />
//                                                   <xs:enumeration value="176" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="AutoCloseTimeInMilitary" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:minLength value="4" />
//                                                   <xs:maxLength value="4" />
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="0000" />
//                                                   <xs:enumeration value="0100" />
//                                                   <xs:enumeration value="0200" />
//                                                   <xs:enumeration value="0300" />
//                                                   <xs:enumeration value="0400" />
//                                                   <xs:enumeration value="0500" />
//                                                   <xs:enumeration value="0600" />
//                                                   <xs:enumeration value="0700" />
//                                                   <xs:enumeration value="0800" />
//                                                   <xs:enumeration value="0900" />
//                                                   <xs:enumeration value="1000" />
//                                                   <xs:enumeration value="1100" />
//                                                   <xs:enumeration value="1200" />
//                                                   <xs:enumeration value="1300" />
//                                                   <xs:enumeration value="1400" />
//                                                   <xs:enumeration value="1500" />
//                                                   <xs:enumeration value="1600" />
//                                                   <xs:enumeration value="1700" />
//                                                   <xs:enumeration value="1800" />
//                                                   <xs:enumeration value="1900" />
//                                                   <xs:enumeration value="2000" />
//                                                   <xs:enumeration value="2100" />
//                                                   <xs:enumeration value="2200" />
//                                                   <xs:enumeration value="2300" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="FPSCustomerReceiptOption" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="1" />
//                                                   <xs:enumeration value="2" />
//                                                   <xs:enumeration value="3" />
//                                                   <xs:enumeration value="4" />
//                                                   <xs:enumeration value="5" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="DialingPrefixPABX" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:minLength value="4" />
//                                                   <xs:maxLength value="4" />
//                                                   <xs:pattern value="^[a-zA-Z0-9]+$" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="AutoSettleTime" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:minLength value="4" />
//                                                   <xs:maxLength value="4" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="PrintSettleReports" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="1" />
//                                                   <xs:enumeration value="2" />
//                                                   <xs:enumeration value="3" />
//                                                   <xs:enumeration value="4" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="PasswordRequiredOnManualEntry" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="1" />
//                                                   <xs:enumeration value="2" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="PrimaryCommMethod" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="1" />
//                                                   <xs:enumeration value="2" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="BUYPASSVCSCommIndex" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="1" />
//                                                   <xs:enumeration value="2" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="HostCommLinkType" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="1" />
//                                                   <xs:enumeration value="2" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="HostSettleType" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="1" />
//                                                   <xs:enumeration value="2" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="HostBackupSupport" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="1" />
//                                                   <xs:enumeration value="2" />
//                                                   <xs:enumeration value="3" />
//                                                   <xs:enumeration value="4" />
//                                                   <xs:enumeration value="5" />
//                                                   <xs:enumeration value="6" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="IPConnection" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="1" />
//                                                   <xs:enumeration value="2" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                             <xs:element minOccurs="0" maxOccurs="1" name="CloseShiftWithSettle" nillable="true">
//                                               <xs:simpleType>
//                                                 <xs:restriction base="xs:string">
//                                                   <xs:enumeration value="" />
//                                                   <xs:enumeration value="1" />
//                                                   <xs:enumeration value="2" />
//                                                 </xs:restriction>
//                                               </xs:simpleType>
//                                             </xs:element>
//                                           </xs:sequence>
//                                         </xs:complexType>
//                                       </xs:element>
//                                       <xs:element minOccurs="1" maxOccurs="1" name="FrontEndFE">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:enumeration value="1" />
//                                             <xs:enumeration value="2" />
//                                             <xs:enumeration value="3" />
//                                             <xs:enumeration value="4" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="Model" nillable="true" type="xs:string" />
//                                       <xs:element minOccurs="0" maxOccurs="1" name="PinPad" nillable="true" type="xs:string" />
//                                       <xs:element minOccurs="0" maxOccurs="1" name="Printer" nillable="true" type="xs:string" />
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CheckReader" nillable="true" type="xs:string" />
//                                       <xs:element minOccurs="0" maxOccurs="1" name="ContactlessReader" nillable="true" type="xs:string"/>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverOption" nillable="true" type="xs:string" />
//                                       <xs:element minOccurs="1" maxOccurs="1" name="EquipmentType">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:enumeration value="1" />
//                                             <xs:enumeration value="2" />
//                                             <xs:enumeration value="5" />
//                                             <xs:enumeration value="6" />
//                                             <xs:enumeration value="8" />
//                                             <xs:enumeration value="10" />
//                                             <xs:enumeration value="11" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="PinpadCommPort" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:enumeration value="" />
//                                             <xs:enumeration value="1" />
//                                             <xs:enumeration value="2" />
//                                             <xs:enumeration value="3" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="SerialNumber" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:minLength value="0" />
//                                             <xs:maxLength value="40" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="WeightScale" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="WeightScaleQuantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                        <xs:element minOccurs="0" maxOccurs="1" name="CloverMini2LTEandWiFi" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverMini2LTEandWiFiQuantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                        <xs:element minOccurs="0" maxOccurs="1" name="CloverMini2TetherCable" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverMini2TetherCableQuantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="Clover2DHandheldBCScanner" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="Clover2DHandheldBCScannerQuantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="HandsFreeBCScanner2" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="HandsFreeBCScanner2Quantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="StarThermalKitPrinter" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="StarThermalKitPrinterQuantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="EpsonLabelPrinter" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="EpsonLabelPrinterQuantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverEmployeeLoginCards" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverEmployeeLoginCardsQuantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="KitchenPrinter" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                             <xs:enumeration value="2" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="KitchenPrinterQuantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverMiniSwivelStand" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverMiniSwivelStandQuantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverP500Printer" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverP500PrinterQuantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverP501Printer" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverP501PrinterQuantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverP550PrinterNFCDisplay" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverP550PrinterNFCDisplayQuantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverStation2018Kit" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="1" maxOccurs="1" name="BillingMethod">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:enumeration value="1" />
//                                             <xs:enumeration value="1" />
//                                             <xs:enumeration value="2" />
//                                             <xs:enumeration value="3" />
//                                             <xs:enumeration value="4" />
//                                             <xs:enumeration value="5" />
//                                             <xs:enumeration value="6" />
//                                             <xs:enumeration value="7" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="TrainingIndicator" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                             <xs:enumeration value="2" />
//                                             <xs:enumeration value="" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverMenuNeeded" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="1" maxOccurs="1" name="Quantity">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="UnitPrice" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:double">
//                                             <xs:maxInclusive value="99999.99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="ReceiptFooterLine1" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:minLength value="0" />
//                                             <xs:maxLength value="40" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="ReceiptFooterLine2" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:minLength value="0" />
//                                             <xs:maxLength value="40" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="BankFIID" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:minLength value="4" />
//                                             <xs:maxLength value="4" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="WeekdayHoursFrom" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:minLength value="4" />
//                                             <xs:maxLength value="4" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="WeekdayHoursTo" nillable="true" type="xs:string" />
//                                       <xs:element minOccurs="0" maxOccurs="1" name="WeekendHoursFrom" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:minLength value="4" />
//                                             <xs:maxLength value="4" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="WeekendHoursTo" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:minLength value="4" />
//                                             <xs:maxLength value="4" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="DaylightSavings" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:minLength value="1" />
//                                             <xs:maxLength value="1" />
//                                             <xs:enumeration value="" />
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="DuplicationFeature" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:minLength value="1" />
//                                             <xs:maxLength value="1" />
//                                             <xs:enumeration value="" />
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="VariableCut" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:minLength value="1" />
//                                             <xs:maxLength value="1" />
//                                             <xs:enumeration value="" />
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="PayeeType" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:minLength value="1" />
//                                             <xs:maxLength value="1" />
//                                             <xs:enumeration value="" />
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                             <xs:enumeration value="2" />
//                                             <xs:enumeration value="3" />
//                                             <xs:enumeration value="4" />
//                                             <xs:enumeration value="5" />
//                                             <xs:enumeration value="6" />
//                                             <xs:enumeration value="7" />
//                                             <xs:enumeration value="8" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="DebitEncryptionType" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:minLength value="1" />
//                                             <xs:maxLength value="1" />
//                                             <xs:enumeration value="" />
//                                             <xs:enumeration value="1" />
//                                             <xs:enumeration value="2" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="MastercardMVVID" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:minLength value="10" />
//                                             <xs:maxLength value="10" />
//                                             <xs:pattern value="[0-9]*" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="VisaMVVID" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:minLength value="10" />
//                                             <xs:maxLength value="10" />
//                                             <xs:pattern value="[0-9]*" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                          <xs:element minOccurs="0" maxOccurs="1" name="CloverFlex2GStarterKit" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                             <xs:enumeration value="" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                        <xs:element minOccurs="0" maxOccurs="1" name="CloverFlex2GStarterKitQuantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                        <xs:element minOccurs="0" maxOccurs="1" name="CloverProTerminal" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                             <xs:enumeration value="" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                        <xs:element minOccurs="0" maxOccurs="1" name="CloverProTerminalQuantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverProDisplay" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                             <xs:enumeration value="" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                        <xs:element minOccurs="0" maxOccurs="1" name="CloverProDisplayQuantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverProStarterKit" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                             <xs:enumeration value="" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                        <xs:element minOccurs="0" maxOccurs="1" name="CloverProStarterKitQuantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="FDClovrGoEmvNfcRdrV2" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:maxLength value="1" />
//                                             <xs:enumeration value="N" />
//                                             <xs:enumeration value="Y" />
//                                             <xs:enumeration value="" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="FDClovrGoEmvNfcRdrV2Quantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverAutoClose" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:enumeration value="" />
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverAutoCloseTimeInMilitary" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:minLength value="4" />
//                                             <xs:maxLength value="4" />
//                                             <xs:pattern value="^[0-9]+$" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverCashDrawer" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:enumeration value="" />
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverCashDrawerQuantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                        <xs:element minOccurs="0" maxOccurs="1" name="CloverFlexTravelKit" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:enumeration value="" />
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                        <xs:element minOccurs="0" maxOccurs="1" name="CloverFlexTravelKitQuantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                        <xs:element minOccurs="0" maxOccurs="1" name="UpservePOS" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                        <xs:element minOccurs="0" maxOccurs="1" name="UpservePOSQuantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="MerakiMR33AccessPoint" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                           <xs:element minOccurs="0" maxOccurs="1" name="MerakiMR33AccessPointQuantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="MerakiMX64Router" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="MerakiMX64RouterQuantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="DLinkDGS1008PSwitch" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="DLinkDGS1008PSwitchQuantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                        <xs:element minOccurs="0" maxOccurs="1" name="CloverMini2StarterKit" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverMini2PINShield" nillable="true">
//                                           <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                        </xs:element>
//                                        <xs:element minOccurs="0" maxOccurs="1" name="CloverMini2PINShieldQuantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverCare" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                             <xs:enumeration value="" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverCareQuantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="MerchantSoldISVSolution" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="SemiIntegratedISV" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:string">
//                                             <xs:enumeration value="" />
//                                             <xs:enumeration value="1" />
//                                             <xs:enumeration value="2" />
//                                             <xs:enumeration value="3" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                        <xs:element minOccurs="0" maxOccurs="1" name="CloverGoDockV2" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverGoDockV2Quantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverGoUniClip" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:enumeration value="0" />
//                                             <xs:enumeration value="1" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                       <xs:element minOccurs="0" maxOccurs="1" name="CloverGoUniClipQuantity" nillable="true">
//                                         <xs:simpleType>
//                                           <xs:restriction base="xs:int">
//                                             <xs:minInclusive value="1" />
//                                             <xs:maxInclusive value="99" />
//                                           </xs:restriction>
//                                         </xs:simpleType>
//                                       </xs:element>
//                                     </xs:sequence>
//                                   </xs:complexType>
//                                 </xs:element>
//                               </xs:sequence>
//                             </xs:complexType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="PurchaseOrder" nillable="true">
//                             <xs:complexType>
//                               <xs:sequence>
//                                 <xs:element minOccurs="0" maxOccurs="1" name="CustomerPONumber" nillable="true">
//                                   <xs:simpleType>
//                                     <xs:restriction base="xs:string">
//                                       <xs:maxLength value="30" />
//                                     </xs:restriction>
//                                   </xs:simpleType>
//                                 </xs:element>
//                               </xs:sequence>
//                             </xs:complexType>
//                           </xs:element>
//                            <xs:element maxOccurs="1" name="CloverSoftwarePlan" nillable="true">
//                             <xs:complexType>
//                               <xs:sequence>
//                                 <xs:element minOccurs="0" maxOccurs="1" name="CloverSoftwarePlanID" nillable="true" type="xs:string" />
//                               </xs:sequence>
//                             </xs:complexType>
//                           </xs:element>
//                           <xs:element name="ShippingInfo" nillable="true">
//                             <xs:complexType>
//                               <xs:sequence>
//                                 <xs:element minOccurs="1" maxOccurs="1" name="ShippingMethod" nillable="true">
//                                   <xs:simpleType>
//                                     <xs:restriction base="xs:string">
//                                       <xs:minLength value="0" />
//                                       <xs:maxLength value="21" />
//                                       <xs:enumeration value="1" />
//                                       <xs:enumeration value="2" />
//                                       <xs:enumeration value="3" />
//                                       <xs:enumeration value="4" />
//                                       <xs:enumeration value="5" />
//                                       <xs:enumeration value="6" />
//                                     </xs:restriction>
//                                   </xs:simpleType>
//                                 </xs:element>
//                                 <xs:element minOccurs="0" maxOccurs="1" name="Attention" nillable="true">
//                                   <xs:simpleType>
//                                     <xs:restriction base="xs:string">
//                                       <xs:minLength value="0" />
//                                       <xs:maxLength value="25" />
//                                     </xs:restriction>
//                                   </xs:simpleType>
//                                 </xs:element>
//                                 <xs:element minOccurs="0" maxOccurs="1" name="Name" nillable="true">
//                                   <xs:simpleType>
//                                     <xs:restriction base="xs:string">
//                                       <xs:minLength value="0" />
//                                       <xs:maxLength value="25" />
//                                     </xs:restriction>
//                                   </xs:simpleType>
//                                 </xs:element>
//                                 <xs:element minOccurs="0" maxOccurs="1" name="Street" nillable="true">
//                                   <xs:simpleType>
//                                     <xs:restriction base="xs:string">
//                                       <xs:minLength value="0" />
//                                       <xs:maxLength value="25" />
//                                     </xs:restriction>
//                                   </xs:simpleType>
//                                 </xs:element>
//                                 <xs:element minOccurs="0" maxOccurs="1" name="City" nillable="true">
//                                   <xs:simpleType>
//                                     <xs:restriction base="xs:string">
//                                       <xs:minLength value="0" />
//                                       <xs:maxLength value="25" />
//                                     </xs:restriction>
//                                   </xs:simpleType>
//                                 </xs:element>
//                                 <xs:element minOccurs="0" maxOccurs="1" name="State" nillable="true">
//                                   <xs:simpleType>
//                                     <xs:restriction base="xs:string">
//                                       <xs:minLength value="0" />
//                                       <xs:maxLength value="3" />
//                                       <xs:enumeration value="AK" />
//                                       <xs:enumeration value="AL" />
//                                       <xs:enumeration value="AR" />
//                                       <xs:enumeration value="AZ" />
//                                       <xs:enumeration value="CA" />
//                                       <xs:enumeration value="CO" />
//                                       <xs:enumeration value="CT" />
//                                       <xs:enumeration value="DC" />
//                                       <xs:enumeration value="DE" />
//                                       <xs:enumeration value="FL" />
//                                       <xs:enumeration value="GA" />
//                                       <xs:enumeration value="HI" />
//                                       <xs:enumeration value="IA" />
//                                       <xs:enumeration value="ID" />
//                                       <xs:enumeration value="IL" />
//                                       <xs:enumeration value="IN" />
//                                       <xs:enumeration value="KS" />
//                                       <xs:enumeration value="KY" />
//                                       <xs:enumeration value="LA" />
//                                       <xs:enumeration value="MA" />
//                                       <xs:enumeration value="MD" />
//                                       <xs:enumeration value="ME" />
//                                       <xs:enumeration value="MI" />
//                                       <xs:enumeration value="MN" />
//                                       <xs:enumeration value="MO" />
//                                       <xs:enumeration value="MS" />
//                                       <xs:enumeration value="MT" />
//                                       <xs:enumeration value="NC" />
//                                       <xs:enumeration value="ND" />
//                                       <xs:enumeration value="NE" />
//                                       <xs:enumeration value="NH" />
//                                       <xs:enumeration value="NJ" />
//                                       <xs:enumeration value="NM" />
//                                       <xs:enumeration value="NV" />
//                                       <xs:enumeration value="NY" />
//                                       <xs:enumeration value="OH" />
//                                       <xs:enumeration value="OK" />
//                                       <xs:enumeration value="OR" />
//                                       <xs:enumeration value="PA" />
//                                       <xs:enumeration value="PR" />
//                                       <xs:enumeration value="RI" />
//                                       <xs:enumeration value="SC" />
//                                       <xs:enumeration value="SD" />
//                                       <xs:enumeration value="TN" />
//                                       <xs:enumeration value="TX" />
//                                       <xs:enumeration value="UT" />
//                                       <xs:enumeration value="VA" />
//                                       <xs:enumeration value="VI" />
//                                       <xs:enumeration value="VT" />
//                                       <xs:enumeration value="WA" />
//                                       <xs:enumeration value="WI" />
//                                       <xs:enumeration value="WV" />
//                                       <xs:enumeration value="WY" />
//                                       <xs:enumeration value="" />
//                                     </xs:restriction>
//                                   </xs:simpleType>
//                                 </xs:element>
//                                 <xs:element minOccurs="0" maxOccurs="1" name="First5Zip" nillable="true">
//                                   <xs:simpleType>
//                                     <xs:restriction base="xs:string">
//                                       <xs:minLength value="5" />
//                                       <xs:maxLength value="5" />
//                                       <xs:pattern value="[0-9]+" />
//                                     </xs:restriction>
//                                   </xs:simpleType>
//                                 </xs:element>
//                                 <xs:element minOccurs="0" maxOccurs="1" name="Last4Zip" nillable="true">
//                                   <xs:simpleType>
//                                     <xs:restriction base="xs:string">
//                                       <xs:minLength value="4" />
//                                       <xs:maxLength value="4" />
//                                       <xs:pattern value="[0-9]*" />
//                                     </xs:restriction>
//                                   </xs:simpleType>
//                                 </xs:element>
//                               </xs:sequence>
//                             </xs:complexType>
//                           </xs:element>
//                         </xs:sequence>
//                       </xs:complexType>
//                     </xs:element>
//                     <xs:element name="OtherFees" minOccurs="0" maxOccurs="1" nillable="true">
//                       <xs:complexType>
//                         <xs:sequence>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AuthorizationPricing_GridLevel" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AuthorizationPricing_GridValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="3" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="UserDefinedPricing_GridLevel" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="UserDefinedPricing_GridValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="3" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MerchantFeeControl_GridLevel" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MerchantFeeControl_GridValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="8" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="GGE4MonthlyFee" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="GGE4SetupFee" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasPayPal" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="PayPalAuthFee" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="PayPalSaleFee" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="PayPalReturnFee" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasTeleCheckGGE4" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="PayCheckByPhone" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="InternetCheckAccepted" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="RemotePay" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="TelecheckMonthlyMinimum" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="TelecheckInquiryRate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="TelecheckChargePerCall" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="TinTfnInvalid" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="9999999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="WebsiteUsage" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="9999999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="IVRUsage" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="9999999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasMCCredit" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasMCDebit" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasVisaCredit" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasVisaDebit" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasDiscoverDebit" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasDiscoverCredit" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasDiscoverPassThru" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasPassDuesPayPal" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasMCAcqSupportFee" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasMCCrossBorder" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasMCNABU" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasMCKilobyteFee" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasMCCVC2Fee" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasVisaTransIntegrityFee" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasVisaFANF" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasVisaAPF" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasVisaMisuseAuth" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasVisaIntAcquirerFee" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasVisaAcqISAFee" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasVisaZeroFloorLimitFee" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasVisaKilobyteFee" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasDiscoverIntProcFee" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasDiscoverIntServiceFee" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasDiscoverDataUsage" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="HasDiscoverNetworkAuthFee" nillable="true" type="xs:boolean" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCKilobyteFeeSurcharge" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCICAFee" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="9.999999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCLicenseFee_PerItem" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="9.999999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCLicenseFee_VolPercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCLicenseFee_FlatRate" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCLicenseFee_PerPeriod" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCCVC2FeeSurcharge" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MCProcFee" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="9.999999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VISAFANFCardPresentSurcharge" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999.999999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VISAFANFCardNotPresentSurcharge" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999.999999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VISABinFee" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="9.999999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VISAKilobyteFeeSurcharge" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="VISAProcFee" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="9.999999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DiscoverNetworkAuthFeeSurcharge" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MonthlyMinimumProcessingFee" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MonthlyStatementFee" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="RegulatoryProductBundleFee" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="eIDSAccessFee" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="ChargebackFee" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="RetrievalFee" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999999999999.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="ReturnTranFee" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="9.9999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="SaleTranFee" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="9.9999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="BatchFee" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="9.9999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="EarlyTerminationFee" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="ACHRejectFee" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="OneTimeIncomeFlagRefValue" nillable="true" type="xs:string" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="TerminalNumber" nillable="true" type="xs:int" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="TerminalIncomeBillScheduleRefValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:minLength value="0" />
//                                 <xs:maxLength value="70" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                                 <xs:enumeration value="6" />
//                                 <xs:enumeration value="7" />
//                                 <xs:enumeration value="8" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="PrinterNumber" nillable="true" type="xs:int" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="PrinterIncomeBillScheduleRefValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="70" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                                 <xs:enumeration value="6" />
//                                 <xs:enumeration value="7" />
//                                 <xs:enumeration value="8" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="TerminalCharge" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="TerminalStart" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="5" />
//                                 <xs:pattern value="((^0[1-9])|(^1[0-2]))\/[0-9]{2}$" />
//                                 <xs:pattern value="((^0[1-9])|(^1[0-2]))\/[0-9]{2}$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="TerminalStop" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="5" />
//                                 <xs:pattern value="((^0[1-9])|(^1[0-2]))\/[0-9]{2}$" />
//                                 <xs:pattern value="((^0[1-9])|(^1[0-2]))\/[0-9]{2}$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="PrinterCharge" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999999999999.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="OneTimeCharge" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999999999999.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="SetupFeeCodeRefValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="70" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="SetupCharge" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="RcCharge" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999999999999.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="EtcConfirmationLetterCharge" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999999999999.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="HelpDeskCharge" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999999999999.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AsstServiceCharge" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999999999999.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="RecurringFeeFlagRefValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="70" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="RecurringIndicatorRefValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="70" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="10" />
//                                 <xs:enumeration value="11" />
//                                 <xs:enumeration value="12" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                                 <xs:enumeration value="6" />
//                                 <xs:enumeration value="7" />
//                                 <xs:enumeration value="8" />
//                                 <xs:enumeration value="9" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="RecurringFeeAmount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="RecurringDescription" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="18" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="NonReceiptPciValidationFee" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccountFee1FlagRefValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="70" />
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="10" />
//                                 <xs:enumeration value="11" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                                 <xs:enumeration value="6" />
//                                 <xs:enumeration value="7" />
//                                 <xs:enumeration value="8" />
//                                 <xs:enumeration value="9" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccountFee1Charge" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccountFee1Start" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="5" />
//                                 <xs:pattern value="((^0[1-9])|(^1[0-2]))\/[0-9]{2}$" />
//                                 <xs:pattern value="((^0[1-9])|(^1[0-2]))\/[0-9]{2}$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccountFee1Stop" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="5" />
//                                 <xs:pattern value="((^0[1-9])|(^1[0-2]))\/[0-9]{2}$" />
//                                 <xs:pattern value="((^0[1-9])|(^1[0-2]))\/[0-9]{2}$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccountFee1Description" nillable="true" type="xs:string" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccountFee2FlagRefValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="70" />
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                                 <xs:enumeration value="6" />
//                                 <xs:enumeration value="7" />
//                                 <xs:enumeration value="8" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccountFee2Charge" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccountFee2Start" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="5" />
//                                 <xs:pattern value="((^0[1-9])|(^1[0-2]))\/[0-9]{2}$" />
//                                 <xs:pattern value="((^0[1-9])|(^1[0-2]))\/[0-9]{2}$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccountFee2Stop" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="5" />
//                                 <xs:pattern value="((^0[1-9])|(^1[0-2]))\/[0-9]{2}$" />
//                                 <xs:pattern value="((^0[1-9])|(^1[0-2]))\/[0-9]{2}$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccountFee2Description" nillable="true" type="xs:string" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccountFee3FlagRefValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="70" />
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                                 <xs:enumeration value="6" />
//                                 <xs:enumeration value="7" />
//                                 <xs:enumeration value="8" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccountFee3Charge" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccountFee3Start" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="5" />
//                                 <xs:pattern value="((^0[1-9])|(^1[0-2]))\/[0-9]{2}$" />
//                                 <xs:pattern value="((^0[1-9])|(^1[0-2]))\/[0-9]{2}$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccountFee3Stop" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="5" />
//                                 <xs:pattern value="((^0[1-9])|(^1[0-2]))\/[0-9]{2}$" />
//                                 <xs:pattern value="((^0[1-9])|(^1[0-2]))\/[0-9]{2}$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccountFee3Description" nillable="true" type="xs:string" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccountFee4FlagRefValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="70" />
//                                 <xs:enumeration value="0" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                                 <xs:enumeration value="6" />
//                                 <xs:enumeration value="7" />
//                                 <xs:enumeration value="8" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccountFee4Charge" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccountFee4Start" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="5" />
//                                 <xs:pattern value="((^0[1-9])|(^1[0-2]))\/[0-9]{2}$" />
//                                 <xs:pattern value="((^0[1-9])|(^1[0-2]))\/[0-9]{2}$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccountFee4Stop" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="5" />
//                                 <xs:pattern value="((^0[1-9])|(^1[0-2]))\/[0-9]{2}$" />
//                                 <xs:pattern value="((^0[1-9])|(^1[0-2]))\/[0-9]{2}$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccountFee4Description" nillable="true" type="xs:string" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccountFee5FlagRefValue" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="70" />
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                                 <xs:enumeration value="6" />
//                                 <xs:enumeration value="7" />
//                                 <xs:enumeration value="8" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccountFee5Charge" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccountFee5Start" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="5" />
//                                 <xs:pattern value="((^0[1-9])|(^1[0-2]))\/[0-9]{2}$" />
//                                 <xs:pattern value="((^0[1-9])|(^1[0-2]))\/[0-9]{2}$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccountFee5Stop" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:maxLength value="5" />
//                                 <xs:pattern value="((^0[1-9])|(^1[0-2]))\/[0-9]{2}$" />
//                                 <xs:pattern value="((^0[1-9])|(^1[0-2]))\/[0-9]{2}$" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AccountFee5Description" nillable="true" type="xs:string" />
//                         </xs:sequence>
//                       </xs:complexType>
//                     </xs:element>
//                     <xs:element name="ClientExpense" minOccurs="0" maxOccurs="1" nillable="true">
//                       <xs:complexType>
//                         <xs:sequence>
//                           <xs:element minOccurs="0" maxOccurs="1" name="GGe4Setup" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="GGe4Monthly" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="ACHReject" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="BatchHeader" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999.9999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="ETCItemCost" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999999999999.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="TapeCost" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999.9999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="FixCost" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="TerminalCost" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="TerminalBillExpSchedule">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                                 <xs:enumeration value="6" />
//                                 <xs:enumeration value="7" />
//                                 <xs:enumeration value="8" />
//                                 <xs:enumeration value="9" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="PrinterCost" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999999999999.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="PrinterBillExpSchedule">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                                 <xs:enumeration value="6" />
//                                 <xs:enumeration value="7" />
//                                 <xs:enumeration value="8" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="OneTimeExpenseFlag">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="4" />
//                                 <xs:enumeration value="5" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="OneTimeExpenseAmount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999999999999.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="OtherVolPercentCost" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="OtherItemCost" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="0.99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="RCCost" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999999999999.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="ChargebackCost" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999999999999.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AuthExpenseGridLevel" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AuthExpenseGridId" nillable="true" type="xs:string" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="UserDefinedExpenseGridLevel" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                                 <xs:enumeration value="" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="UserDefinedExpenseGridID" nillable="true" type="xs:string" />
//                           <xs:element minOccurs="0" maxOccurs="1" name="HelpDeskCost" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999999999999.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AsstServiceCost" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999999999999.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="ETCConfLetterCost" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999999999999.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MerchantAdvCost" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="TwelveLetterCost" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999999999999.999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AVSCost" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999.9999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="TINTFNBlankInvalid" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="WebsiteUsage" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="IVRUsage" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="EidsCost" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="NonReceiptPCIValidationCost" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                         </xs:sequence>
//                       </xs:complexType>
//                     </xs:element>
//                     <xs:element name="Exception" minOccurs="0" maxOccurs="1" nillable="true">
//                       <xs:complexType>
//                         <xs:sequence>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AverageTicketAmount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="TicketBelowFloorPercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DailyDepositAmount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999999999999999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="WeeklyDepositAmount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999999999999999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="KeyEnteredPercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="ReturnVolumePercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="ReturnCountPercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MaxTKTOnly" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="NumberOfWeeklyBatches" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MaxAuthAmount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="9999999.99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="PercentVoiceAuths" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="100" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MaxSalesAmount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MaxReturnAmount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999999999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="BatchReturnAmount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999999999999999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DailyAuthAmount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999999999999999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DailyAuthPerCard" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DailyAuthDeclinePercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="100" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DailyAuths" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:int">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="MTDChargebackPercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="SameDollarAmountPercent" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="1" maxOccurs="1" name="DisbursementInclExclException">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:string">
//                                 <xs:enumeration value="1" />
//                                 <xs:enumeration value="2" />
//                                 <xs:enumeration value="3" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="CHOccursInBatch" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DailyTransPerCard" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:int">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="AuthsSameAmount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:int">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DailyRetrievalCount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:int">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="DailyRetrievalAmount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:decimal">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="999999999999999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                           <xs:element minOccurs="0" maxOccurs="1" name="BatchReturnCount" nillable="true">
//                             <xs:simpleType>
//                               <xs:restriction base="xs:int">
//                                 <xs:minInclusive value="0" />
//                                 <xs:maxInclusive value="99999" />
//                               </xs:restriction>
//                             </xs:simpleType>
//                           </xs:element>
//                         </xs:sequence>
//                       </xs:complexType>
//                     </xs:element>
//                   </xs:sequence>
//                 </xs:complexType>
//               </xs:element>
//             </xs:sequence>
//           </xs:complexType>
//         </xs:element>
//         <xs:element name="Attachments" minOccurs="0" maxOccurs="1" nillable="true">
//           <xs:complexType>
//             <xs:sequence>
//               <xs:element name="Attachment" minOccurs="1" maxOccurs="100">
//                 <xs:complexType>
//                   <xs:sequence>
//                     <xs:element name="OutletNumber" minOccurs="1" maxOccurs="1">
//                       <xs:simpleType>
//                         <xs:restriction base="xs:int">
//                           <xs:pattern value="^[1-9][0-9]?$|^99$" />
//                         </xs:restriction>
//                       </xs:simpleType>
//                     </xs:element>
//                     <xs:element name="DocumentType" minOccurs="1" maxOccurs="1">
//                       <xs:simpleType>
//                         <xs:restriction base="xs:string">
//                           <xs:enumeration value="W9" />
//                           <xs:enumeration value="Financials" />
//                           <xs:enumeration value="CurrStmnt" />
//                           <xs:enumeration value="VoidCheck" />
//                           <xs:enumeration value="SignedMpa" />
//                           <xs:enumeration value="CONF_PAGE" />
//                           <xs:enumeration value="Other" />
//                           <xs:enumeration value="PCIRCLWMA" />
//                  	        <xs:enumeration value="PG" />
//                           <xs:enumeration value="ClvAdden" />
//                           <xs:enumeration value="CusMPA" />
//                           <xs:enumeration value="ClvCareAdm" />
//                           <xs:enumeration value="DrvLicense" />
//                           <xs:enumeration value="LeasingAgr" />
//                           <xs:enumeration value="DNA" />
//                         </xs:restriction>
//                       </xs:simpleType>
//                     </xs:element>
//                     <xs:element name="DocumentName" minOccurs="1" maxOccurs="1">
//                       <xs:simpleType>
//                         <xs:restriction base="xs:string">
//                           <xs:maxLength value="150" />
//                         </xs:restriction>
//                       </xs:simpleType>
//                     </xs:element>
//                     <xs:element name="DocumentBase64" minOccurs="1" maxOccurs="1">
//                       <xs:simpleType>
//                         <xs:restriction base="xs:base64Binary">

// ''');
