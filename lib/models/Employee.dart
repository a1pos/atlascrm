class Employee {
  String employee;
  String role;
  bool isActive;
  int employeeAccountType;
  String company;
  String companyName;
  dynamic document;
  String created_at;
  String created_by;
  String updated_at;
  String updated_by;

  Employee(
      this.employee,
      this.role,
      this.isActive,
      this.employeeAccountType,
      this.company,
      this.companyName,
      this.document,
      this.created_at,
      this.created_by,
      this.updated_at,
      this.updated_by);

  static Employee getEmpty() {
    return Employee(
        null, null, false, null, null, null, null, null, null, null, null);
  }

  static Employee fromJson(Map<String, dynamic> data) {
    return Employee(
        data["employee"],
        data["role"],
        data["is_active"],
        data["employee_account_type"],
        data["company"],
        data["companyName"],
        data["document"],
        data["created_at"],
        data["created_by"],
        data["updated_at"],
        data["updated_by"]);
  }

  Map<String, dynamic> toJson() => {
        'employee': employee,
        'role': employee,
        'is_active': isActive,
        'employee_account_type': employeeAccountType,
        'company': company,
        'companyName': companyName,
        'document': document,
        'created_at': created_at,
        'created_by': created_at,
        'updated_at': updated_at,
        'updated_by': updated_by,
      };
}
