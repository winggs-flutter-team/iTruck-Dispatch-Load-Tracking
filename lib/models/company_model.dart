class CompanyModel {
  String? companyId;
  String? companyname;
  String? address;
  String? contactperson;

  CompanyModel(
      {this.companyId, this.companyname, this.address, this.contactperson});

  factory CompanyModel.fromJson(Map<String, dynamic> json, companyid) {
    return CompanyModel(companyname: json['name'], companyId: companyid);
  }
}
