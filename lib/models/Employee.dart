class Employee {
  String employee;
  bool isActive;
  String employeeAccountType;
  String employeeCompany;
  dynamic document;

  Employee(this.employee, this.isActive, this.employeeAccountType,
      this.employeeCompany, this.document);

  static Employee getEmptyLead() {
    return Employee(null, false, null, null, null);
  }

  static Employee fromJson(Map<String, dynamic> data) {
    return Employee(
      data["employee"],
      data["isactive"],
      data["employeeAccountType"],
      data["employeeCompany"],
      data["document"],
    );
  }

  Map<String, dynamic> toJson() => {
        'employee': employee,
        'isactive': isActive,
        'employeeAccountType': employeeAccountType,
        'employeeCompany': employeeCompany,
        'document': document,
      };
}
