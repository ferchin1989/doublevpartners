class Country { final String code; final String name; const Country(this.code, this.name); }
class Department { final String code; final String name; final String countryCode; const Department(this.code, this.name, this.countryCode); }
class Municipality { final String code; final String name; final String departmentCode; const Municipality(this.code, this.name, this.departmentCode); }
