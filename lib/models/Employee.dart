class Employee {
  String employee;
  bool isActive;
  int employeeAccountType;
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
      data["is_active"],
      data["employee_account_type"],
      data["company"],
      data["document"],
    );
  }

  Map<String, dynamic> toJson() => {
        'employee': employee,
        'is_active': isActive,
        'employee_account_type': employeeAccountType,
        'company': employeeCompany,
        'document': document,
      };
}
